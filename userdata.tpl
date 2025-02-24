#!/bin/bash
# Update system and install necessary packages
yum update -y
amazon-linux-extras enable php7.4
yum remove -y php php-cli httpd
yum install -y php php-cli php-mysqlnd php-json php-opcache php-xml php-mbstring php-curl php-zip httpd wget unzip mariadb-server

# Start services and enable auto-start
systemctl start httpd
systemctl enable httpd
systemctl start mariadb
systemctl enable mariadb

# Clean up default Apache files
rm -f /var/www/html/index.html
rm -f /var/www/html/index.php

# Download WordPress
cd /tmp
wget https://wordpress.org/latest.zip
unzip latest.zip
cp -r wordpress/* /var/www/html/

# Set permissions correctly
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# Configure WordPress
cd /var/www/html
cp wp-config-sample.php wp-config.php

# Create MySQL database and user
mysql -e "CREATE DATABASE wordpress_db;"
mysql -e "CREATE USER 'sriwp_dbuser'@'localhost' IDENTIFIED BY 'Password123!#$';"
mysql -e "GRANT ALL PRIVILEGES ON wordpress_db.* TO 'sriwp_dbuser'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Update wp-config.php
sed -i 's/database_name_here/wordpress_db/' wp-config.php
sed -i 's/username_here/sriwp_dbuser/' wp-config.php
sed -i 's/password_here/Password123!#$/' wp-config.php
sed -i "s/localhost/${wordpress_rds_endpoint}/" wp-config.php

# Set WordPress salts
SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt/)
echo "$SALT" >> wp-config.php

# Configure Apache for WordPress
cat > /etc/httpd/conf.d/wordpress.conf << 'EOF'
<Directory /var/www/html/>
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>
EOF

# Enable mod_rewrite
sed -i 's/#LoadModule rewrite_module/LoadModule rewrite_module/' /etc/httpd/conf.modules.d/00-base.conf

# Create .htaccess with rewrite rules
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

chown apache:apache /var/www/html/.htaccess
chmod 644 /var/www/html/.htaccess

# Restart Apache
systemctl restart httpd

# Clean up
rm -rf /tmp/wordpress
rm -f /tmp/latest.zip

echo "WordPress installation completed successfully"
