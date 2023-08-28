#!/bin/bash
clear

read -p "Project name: " projectName
read -p "Repository url: " repository

projectFolderName=/var/www/$projectName

sudo mkdir $projectFolderName
sudo chown -R faysal:faysal $projectFolderName

git clone $repository $projectFolderName

cd $projectFolderName

composer install

cp .env.example .env

php artisan key:generate

mysql -u root -p663399 -e "create database $projectName"
sed -i "s/DB_DATABASE=.*/DB_DATABASE=$projectName/g" $projectFolderName/.env
sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=663399/g" $projectFolderName/.env
php $projectFolderName/artisan migrate
documentRoot=$projectFolderName/public
sudo chown www-data:www-data -R $projectFolderName/storage
sudo chown www-data:www-data -R $projectFolderName/bootstrap/cache

domain=$projectName.test

confFile=$domain.conf

conf=/etc/apache2/sites-available/$confFile

sudo touch $conf

sudo sh -c "cat > $conf <<EOF
    <VirtualHost *:80>
        ServerAdmin webmaster@localhost
        ServerName $domain
        DocumentRoot $documentRoot

        <Directory $documentRoot>
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

cd $projectFolderName

code .

echo "All Done. Visit $domain"
