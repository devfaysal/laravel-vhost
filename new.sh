#!/bin/bash
clear

read -p "Please enter the project name: " projectName

composer create-project --prefer-dist laravel/laravel /var/www/html/laravel/$projectName

sudo chmod 777 -R /var/www/html/laravel/$projectName/storage

domain=$projectName.test

confFile=$domain.conf

conf=/etc/apache2/sites-available/$confFile

sudo touch $conf

sudo sh -c "cat > $conf <<EOF
    <VirtualHost *:80>
        ServerAdmin webmaster@localhost
        ServerName $domain
        DocumentRoot /var/www/html/laravel/$projectName/public

        <Directory /var/www/html/laravel/$projectName/public>
            Options Indexes FollowSymLinks
            AllowOverride All
            Require all granted
        </Directory>
    </VirtualHost>
EOF
"

sudo a2ensite $confFile

sudo service apache2 restart

content="127.0.0.1 $domain"

sudo sh -c "echo $content >> /etc/hosts"

cd /var/www/html/laravel/$projectName

code .

echo "All Done. Visit $domain"