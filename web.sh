 #!/bin/bash -ex
 {
 # Update the system
 sudo dnf -y update
 # Install MySQL Community Server
 sudo dnf -y install https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm
 sudo dnf -y install mysql-community-server
 # Start and enable MySQL
 sudo systemctl start mysqld
 sudo systemctl enable mysqld
 # Install Apache and PHP
 sudo dnf -y install httpd php
 # Start and enable Apache
 sudo systemctl start httpd
 sudo systemctl enable httpd
 cd /var/www/html
 sudo wget https://aws-tc-largeobjects.s3-us-west-2.amazonaws.com/CUR-TF-200-ACACAD/studentdownload/lab-app.tgz
 sudo tar xvfz lab-app.tgz
 sudo chown apache:root /var/www/html/rds.conf.php
 } &> /var/log/user_data.log
