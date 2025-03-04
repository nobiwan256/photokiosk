#!/bin/bash
# Log the start of the script for easier debugging
exec > >(tee /var/log/wordpress-install.log) 2>&1
echo "Starting WordPress installation script at $(date)"

# Install required tools early (including netcat for DB connection check)
yum install -y nc wget unzip

# Update system and install PHP
echo "Updating system packages..."
yum update -y

# Install Apache and PHP (without removing existing packages first)
echo "Installing Apache, PHP and dependencies..."
amazon-linux-extras enable php7.4
yum install -y httpd php php-cli php-mysqlnd php-json php-opcache php-xml php-mbstring php-curl php-zip mysql

# Start and enable Apache
echo "Starting Apache web server..."
systemctl start httpd
systemctl enable httpd

# Check if Apache is running
if ! systemctl is-active --quiet httpd; then
    echo "ERROR: Apache failed to start. Attempting to start again..."
    systemctl start httpd
    if ! systemctl is-active --quiet httpd; then
        echo "ERROR: Apache still failed to start. Check Apache error logs."
    fi
fi

# Remove default Apache page
rm -f /var/www/html/index.html
rm -f /var/www/html/index.php

# Download WordPress
echo "Downloading WordPress..."
cd /tmp
if ! wget https://wordpress.org/latest.zip; then
    echo "Failed to download WordPress. Retrying..."
    sleep 5
    wget https://wordpress.org/latest.zip || { echo "Failed to download WordPress after retry. Exiting."; exit 1; }
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
max_attempts=60  # 10 minutes total

while ! nc -z ${db_endpoint} 3306 && [ $attempt -lt $max_attempts ]; do
    echo "Attempt $attempt: Database not available yet, waiting..."
    sleep 10
    attempt=$((attempt+1))
done

if [ $attempt -eq $max_attempts ]; then
    echo "Database connection timed out after $max_attempts attempts"
    # Don't exit, continue with setup
fi

echo "Successfully connected to database or timed out"

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

# Create .htaccess file
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

# Create a simple health check file for the load balancer
echo "Creating health check file..."
echo "OK" > /var/www/html/health.html
chmod 644 /var/www/html/health.html
chown apache:apache /var/www/html/health.html

# Restart Apache
echo "Restarting Apache..."
systemctl restart httpd

# Verify Apache is running
if ! systemctl is-active --quiet httpd; then
    echo "WARNING: Apache is not running after restart. Attempting to start again..."
    systemctl start httpd
    if ! systemctl is-active --quiet httpd; then
        echo "ERROR: Failed to start Apache. Check Apache error logs."
    else
        echo "Apache successfully started on second attempt."
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
