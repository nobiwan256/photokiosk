#!/bin/bash
# Log the start of the script for easier debugging
echo "Starting WordPress installation script" > /var/log/wordpress-install.log

# Update system and install PHP
yum update -y
amazon-linux-extras enable php7.4
yum remove -y php php-cli httpd
yum install -y php php-cli php-mysqlnd php-json php-opcache php-xml php-mbstring php-curl php-zip httpd wget unzip

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Remove default Apache page
rm -f /var/www/html/index.html
rm -f /var/www/html/index.php

# Download WordPress
cd /tmp
wget https://wordpress.org/latest.zip
unzip latest.zip
cp -r wordpress/* /var/www/html/

# Set permissions
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# Configure wp-config.php
cd /var/www/html
cp wp-config-sample.php wp-config.php

# Update WordPress configuration
sed -i "s/database_name_here/${db_name}/" wp-config.php
sed -i "s/username_here/${db_user}/" wp-config.php
sed -i "s/password_here/${db_password}/" wp-config.php

# Wait for the RDS instance to be available
echo "Waiting for database to become available at ${db_endpoint}" >> /var/log/wordpress-install.log
attempt=0
max_attempts=30

while ! nc -z ${db_endpoint} 3306 && [ $attempt -lt $max_attempts ]; do
    echo "Attempt $attempt: Database not available yet, waiting..." >> /var/log/wordpress-install.log
    sleep 10
    attempt=$((attempt+1))
done

if [ $attempt -eq $max_attempts ]; then
    echo "Database connection timed out after $max_attempts attempts" >> /var/log/wordpress-install.log
    exit 1
fi

echo "Successfully connected to database" >> /var/log/wordpress-install.log

# Update the database host
sed -i "s/localhost/${db_endpoint}/" wp-config.php

# Add WordPress salts
SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt/)
sed -i "/#@-/,/#@+/c\\$SALT" wp-config.php

# Configure Apache for WordPress
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
sed -i 's/#LoadModule rewrite_module/LoadModule rewrite_module/' /etc/httpd/conf.modules.d/00-base.conf

# Install nc if not available (for the waiting loop)
yum install -y nc

# Restart Apache
systemctl restart httpd

# Clean up
rm -rf /tmp/wordpress
rm -f /tmp/latest.zip

echo "WordPress installation completed" >> /var/log/wordpress-install.log
