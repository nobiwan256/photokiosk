#!/bin/bash
yum update -y
amazon-linux-extras enable php7.4
yum remove -y php php-cli httpd
yum install -y php php-cli php-mysqlnd php-json php-opcache php-xml php-mbstring php-curl php-zip httpd wget unzip
systemctl start httpd
systemctl enable httpd
rm -f /var/www/html/index.html
rm -f /var/www/html/index.php
cd /tmp
wget https://wordpress.org/latest.zip
unzip latest.zip
cp -r wordpress/* /var/www/html/
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html
cd /var/www/html
cp wp-config-sample.php wp-config.php
sed -i 's/database_name_here/wordpress_db/' wp-config.php
sed -i 's/username_here/sriwp_dbuser/' wp-config.php
sed -i 's/password_here/Password123!#$/' wp-config.php
sed -i "s/localhost/${db_endpoint}/" wp-config.php
SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt/)
sed -i "/#@-/,/#@+/c\\$SALT" wp-config.php
cat > /etc/httpd/conf.d/wordpress.conf << 'EOF'
<Directory /var/www/html/>
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>
EOF
cat > /var/www/html/.htaccess << 'EOF'
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
EOF
chown apache:apache /var/www/html/.htaccess
chmod 644 /var/www/html/.htaccess
sed -i 's/#LoadModule rewrite_module/LoadModule rewrite_module/' /etc/httpd/conf.modules.d/00-base.conf
systemctl restart httpd
rm -rf /tmp/wordpress
rm -f /tmp/latest.zip
echo "WordPress installation completed"
