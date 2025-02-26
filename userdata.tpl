#!/bin/bash
# Log the start of the script for easier debugging
exec > >(tee /var/log/wordpress-install.log) 2>&1
echo "Starting WordPress installation script at $(date)"

# Install required tools early (including netcat for DB connection check)
yum install -y nc wget unzip

# Update system and install PHP
echo "Updating system packages..."
yum update -y
amazon-linux-extras enable php7.4
yum remove -y php php-cli httpd
yum install -y php php-cli php-mysqlnd php-json php-opcache php-xml php-mbstring php-curl php-zip httpd wget unzip

# Start and enable Apache
echo "Starting Apache web server..."
systemctl start httpd
systemctl enable httpd

# Remove default Apache page
rm -f /var/www/html/index.html
rm -f /var/www/html/index.php

# Download WordPress
echo "Downloading WordPress..."
cd /tmp
if ! wget https://wordpress.org/latest.zip; then
    echo "Failed to download WordPress. Exiting."
    exit 1
fi

echo "Extracting WordPress..."
if ! unzip latest.zip; then
    echo "Failed to extract WordPress. Exiting."
    exit 1
fi

echo "Copying WordPress files to web root..."
cp -r wordpress/* /var/www/html/

# Set permissions
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# Configure wp-config.php
cd /var/www/html
cp wp-config-sample.php wp-config.php

# Update WordPress configuration
echo "Configuring WordPress..."
sed -i "s/database_name_here/${db_name}/" wp-config.php
sed -i "s/username_here/${db_user}/" wp-config.php
sed -i "s/password_here/${db_password}/" wp-config.php

# Wait for the RDS instance to be available
echo "Waiting for database to become available at ${db_endpoint}"
attempt=0
max_attempts=60  # Increased from 30 to 60 attempts (10 minutes total)

while ! nc -z ${db_endpoint} 3306 && [ $attempt -lt $max_attempts ]; do
    echo "Attempt $attempt: Database not available yet, waiting..."
    sleep 10
    attempt=$((attempt+1))
done

if [ $attempt -eq $max_attempts ]; then
    echo "Database connection timed out after $max_attempts attempts"
    exit 1
fi

echo "Successfully connected to database"

# Verify database connection
echo "Testing database connection with MySQL client..."
if ! yum install -y mysql; then
    echo "Warning: Could not install MySQL client for verification"
else
    # Try to connect to the database
    if mysql -h ${db_endpoint} -u ${db_user} -p${db_password} -e "SHOW DATABASES;" > /dev/null 2>&1; then
        echo "MySQL connection test successful"
        
        # Create WordPress database if it doesn't exist
        echo "Creating database if it doesn't exist..."
        mysql -h ${db_endpoint} -u ${db_user} -p${db_password} -e "CREATE DATABASE IF NOT EXISTS ${db_name};"
    else
        echo "MySQL connection test failed, but continuing with setup"
    fi
fi

# Update the database host
sed -i "s/localhost/${db_endpoint}/" wp-config.php

# Add WordPress salts
echo "Adding WordPress security keys..."
SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt/)
sed -i "/#@-/,/#@+/c\\$SALT" wp-config.php

# Configure Apache for WordPress
echo "Configuring Apache for WordPress..."
cat > /etc/httpd/conf.d/wordpress.conf << 'EOF'
<Directory /var/www/html/>
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>
EOF

# Create .htaccess file with properly escaped template markers (%% instead of %)
cat > /var/www/html/.htaccess << 'EOF'
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %%{REQUEST_FILENAME} !-f
RewriteCond %%{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
EOF

# Set proper permissions for .htaccess
chown apache:apache /var/www/html/.htaccess
chmod 644 /var/www/html/.htaccess

# Enable mod_rewrite
echo "Enabling mod_rewrite..."
sed -i 's/#LoadModule rewrite_module/LoadModule rewrite_module/' /etc/httpd/conf.modules.d/00-base.conf

# Restart Apache
echo "Restarting Apache..."
systemctl restart httpd

# Verify Apache is running
if ! systemctl is-active --quiet httpd; then
    echo "WARNING: Apache is not running. Attempting to start again..."
    systemctl start httpd
    if ! systemctl is-active --quiet httpd; then
        echo "ERROR: Failed to start Apache. Check Apache error logs."
    else
        echo "Apache successfully restarted on second attempt."
    fi
else
    echo "Apache is running successfully."
fi

# Check if WordPress files exist and are accessible
if [ -f "/var/www/html/wp-login.php" ]; then
    echo "WordPress files correctly installed."
else
    echo "WARNING: WordPress files may not be correctly installed."
fi

# Clean up
echo "Cleaning up temporary files..."
rm -rf /tmp/wordpress
rm -f /tmp/latest.zip

echo "WordPress installation completed at $(date)"

# Create a simple health check file for the load balancer
echo "Creating health check file..."
echo "OK" > /var/www/html/health.html
chmod 644 /var/www/html/health.html
