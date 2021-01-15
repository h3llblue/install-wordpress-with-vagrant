#!/bin/sh

# Actualizar
apt-get update
apt-get upgrade -y
# Instalar git
apt-get install git -y
# Instalar un firewall y configurarlo
apt-get install ufw -y
ufw allow in "Apache Full"
ufw allow in "OpenSSH"
# Instalar apache2
apt-get install apache2 -y
# Preparar la instalacion de Mariadb preconfigurando la contraseña root
echo "mysql mariadb-server/root_password password '12345';" | debconf-set-selections
echo "mysql mariadb-server/root_password_again password '12345';" | debconf-set-selections
#Instalar mariadb
apt-get install mariadb-server -y
# Crear el usuario root
mysql --user="root" --password="12345" -e "CREATE USER 'sysadmin' IDENTIFIED BY '12345';"
mysql --user="root" --password="12345" -e "GRANT ALL PRIVILEGES ON *.* TO 'sysadmin';"
mysql --user="root" --password="12345" -e "FLUSH PRIVILEGES;"
service mysql restart
# Instalar PHP7.0 ## ACTUALIZADO PARA PHP7.x LA MAS RECIENTE ##
add-apt-repository ppa:ondrej/php -y
apt-get update
apt-get install php libapache2-mod-php php-mysql -y
# Cambiar el orden apache para que los archivos .php sean leidos primero
cd /etc/apache2/mods-enabled/
echo "" > dir.conf
echo """<IfModule mod_dir.c>
   DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
</IfModule>

#vim: syntax=apache ts=4 sw=4 sts=4 sr noet""" > dir.conf
systemctl restart apache2
# Comprobar que este instalado el client de mariadb y zip 
apt-get install mariadb-client -y
apt-get install zip -y
# Descargar y instalar phpMyAdmin
wget https://files.phpmyadmin.net/phpMyAdmin/4.9.7/phpMyAdmin-4.9.7-all-languages.zip
unzip phpMyAdmin-4.9.7-all-languages.zip
mv phpMyAdmin-4.9.7-all-languages phpMyAdmin
mv phpMyAdmin/ /var/www/html/
apt-get install php-mbstring php-gettext -y
cd ~/
# Recargando todos los servicios
systemctl restart apache2
systemctl restart phpsessionclean.service
systemctl restart mariadb.service
cd /var/www/
# Descargando y instalando Wordpress
wget https://es-mx.wordpress.org/latest-es_MX.zip
unzip latest-es_MX.zip
mv wordpress/* html/
cd ~/
# Crear la base de datos para wordpress
mysql --user="sysadmin" --password="12345" -e "CREATE DATABASE wordpress;"
cd /var/www/html/
# Configurando el archivo wp-config.php para tener conexion directa con wordpress
sed -i "s/database_name_here/wordpress/g" wp-config-sample.php
sed -i "s/username_here/sysadmin/g" wp-config-sample.php
sed -i "s/password_here/12345/g" wp-config-sample.php
mv wp-config-sample.php wp-config.php
# Agregar a config.php comando para desactivar FTP
echo "/* Desactivar el uso de FTP en WordPress */ 
define('FS_METHOD','direct');" >> wp-config.php
# Asignar permisos
cd /var/www/
chmod -R 755 html
chmod 644 html/*.php
chmod 644 html/*.html
chmod 644 html/*.txt
chmod -R 755 html/wp-admin
chmod -R 777 html/wp-content
chmod -R 755 html/wp-includes
chmod -R 644 html/phpMyAdmin
chmod 444 html/wp-config.php
cd ~/
# Instalar FTP Pospuesto indefinidamente




