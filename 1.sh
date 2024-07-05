#!/bin/bash

host () {
apt update && apt upgrade -y
apt install nano git curl zip unzip sed -y
sudo apt install apache2 -y
sudo systemctl stop apache2
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
sudo apt install php8.3-fpm php8.3-common php8.3-mysql php8.3-xml php8.3-xmlrpc php8.3-curl php8.3-gd php8.3-imagick php8.3-cli php8.3-dev php8.3-imap php8.3-mbstring php8.3-soap php8.3-zip php8.3-bcmath -y
sudo a2dissite 000-default
sudo a2dismod mpm_prefork
sudo a2enmod mpm_event proxy_fcgi setenvif http2
sudo a2enconf php8.3-fpm
systemctl start apache2
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 128M/' /etc/php/8.3/fpm/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 128M/' /etc/php/8.3/fpm/php.ini
sed -i 's/memory_limit = 128M/memory_limit = 512M/' /etc/php/8.3/fpm/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 600/' /etc/php/8.3/fpm/php.ini
sed -i 's/;max_input_vars = 1000/max_input_vars = 3000/' /etc/php/8.3/fpm/php.ini
sed -i 's/max_input_time = 60/max_input_time = 1000/' /etc/php/8.3/fpm/php.ini
sudo service php8.3-fpm restart
cat <<EOF > /etc/apache2/sites-available/mysite.conf
<VirtualHost *:80>
     ServerName $domain
     ServerAlias www.$domain
     Protocols h2 http/1.1
     DocumentRoot /var/www/html/
     <Directory /var/www/html/>
         Options -Indexes +FollowSymLinks
         AllowOverride All
         Require all granted
     </Directory>
 RewriteCond %{REQUEST_FILENAME} !-d
RewriteCond %{REQUEST_FILENAME} !-f
RewriteRule ^(.+)$ /index.php/$1 [L]
      ErrorLog ${APACHE_LOG_DIR}/error.log
      CustomLog ${APACHE_LOG_DIR}/access.log combined  
</VirtualHost> 
EOF
sudo a2ensite mysite.conf
sudo service apache2 restart
echo "<?php phpinfo();?>" > /var/www/html/index.php
}

mysql(){
apt install mysql-server -y
mysql --user=root e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password by $passdb;"
mysql -u root -p558416as -Bse "CREATE USER 'phenom'@'localhost' IDENTIFIED BY '558416as'; GRANT ALL ON *.* TO 'phenom'@'localhost' WITH GRANT OPTION;FLUSH PRIVILEGES;exit;"
a2enmod rewrite
systemctl restart apache2
sudo chown -R www-data:www-data /var/www/html/
find /var/www/ -type d -exec chmod 755 {} \;
find /var/www/ -type f -exec chmod 644 {} \;
echo ya solo faltaria ejecutar el comando certbot --apache
}

ssl(){
sudo apt install python3 python3-venv libaugeas0 -y
sudo python3 -m venv /opt/certbot/
sudo /opt/certbot/bin/pip install --upgrade pip
sudo /opt/certbot/bin/pip install certbot certbot-apache
sudo ln -s /opt/certbot/bin/certbot /usr/bin/certbot
}


read -r -p "Escribe el dominio a configurar:" domain
read -r -p "Usaras Base de datos [S/N] " response
read -r -p "Necesitaras SSL? [S/N]" ssl
if [ $response = y]
then
read -r -p "Teclea la contraseña de la base de datos:" passdb
     host
     mysql
elif [ $response = n];
	quit
if

if [$ssl = y];
then
ssl
elif [$ssl = n]; 
quit
fi
