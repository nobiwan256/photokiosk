#! /bin/bash
sudo yum update -y
sudo yum install -y httpd mariadb105-server php php-mysqlnd unzip

sudo systemctl start httpd
sudo systemctl enable httpd

sudo systemctl start mariadb
sudo systemctl enable mariadb

cd /var/www/html
sudo aws s3 sync s3://{{bucket_name}}/
