#!/bin/bash -ex
sudo yum -y install httpd php mysql php-mysql
sudo chkconfig httpd on
sudo service httpd start
if [ ! -f /var/www/html/lab-app.tgz ]; then
cd /var/www/html
sudo wget https://aws-tc-largeobjects.s3-us-west-2.amazonaws.com/CUR-TF-200-ACACAD/studentdownload/lab-app.tgz
sudo tar xvfz lab-app.tgz
sudo chown apache:root /var/www/html/rds.conf.php
fi