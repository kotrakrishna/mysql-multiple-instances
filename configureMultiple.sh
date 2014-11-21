
sudo mkdir -p /var/log/mysql/mysql3306
sudo mkdir -p /var/log/mysql/mysql3307
sudo mkdir -p /var/log/mysql/mysql3308
sudo mkdir -p /var/log/mysql/mysql3309

sudo touch /var/log/mysql/mysql3306/mysql.log
sudo touch /var/log/mysql/mysql3307/mysql.log
sudo touch /var/log/mysql/mysql3308/mysql.log
sudo touch /var/log/mysql/mysql3309/mysql.log


sudo touch /var/log/mysql/mysql3306/error.log
sudo touch /var/log/mysql/mysql3307/error.log
sudo touch /var/log/mysql/mysql3308/error.log
sudo touch /var/log/mysql/mysql3309/error.log

sudo touch /var/log/mysql/mysql3306/mysql-slow.log
sudo touch /var/log/mysql/mysql3307/mysql-slow.log
sudo touch /var/log/mysql/mysql3308/mysql-slow.log
sudo touch /var/log/mysql/mysql3309/mysql-slow.log


sudo chown -R mysql:mysql /var/log/mysql

sudo setfacl -R -m u:mysql:rwX -m u:`whoami`:rwX /var/log/mysql
sudo setfacl -dR -m u:mysql:rwX -m u:`whoami`:rwX /var/log/mysql

#sudo cp /etc/mysql/my.cnf /etc/mysql/my3306.cnf
## Edit all the ports, sockets, logs dirs, data dirs
sudo sed -i 's/3306/3307/g' my3307.cnf 
sudo sed -i 's/3306/3308/g' my3308.cnf 
sudo sed -i 's/3306/3309/g' my3309.cnf

sudo mkdir -p /databases/mysql3306
sudo mkdir -p /databases/mysql3307
sudo mkdir -p /databases/mysql3308
sudo mkdir -p /databases/mysql3309

sudo chown -R mysql:mysql /databases/mysql3306
sudo chown -R mysql:mysql /databases/mysql3307
sudo chown -R mysql:mysql /databases/mysql3308
sudo chown -R mysql:mysql /databases/mysql3309

sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/database/mysql3306 --defaults-file=/etc/mysql/my3306.cnf
sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/database/mysql3307 --defaults-file=/etc/mysql/my3307.cnf
sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/database/mysql3308 --defaults-file=/etc/mysql/my3308.cnf
sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/database/mysql3309 --defaults-file=/etc/mysql/my3309.cnf

#start
sudo -b mysqld_safe --defaults-file=/etc/mysql/my3306.cnf --user=mysql
sudo -b mysqld_safe --defaults-file=/etc/mysql/my3307.cnf --user=mysql
sudo -b mysqld_safe --defaults-file=/etc/mysql/my3308.cnf --user=mysql
sudo -b mysqld_safe --defaults-file=/etc/mysql/my3309.cnf --user=mysql

debianUser=$(sudo cat /etc/mysql/debian.cnf | grep "user" | tail -1| cut -d'=' -f2 | sed 's/ //g')
debianPass=$(sudo cat /etc/mysql/debian.cnf | grep "password" | tail -1| cut -d'=' -f2 | sed 's/ //g')
echo "GRANT ALL PRIVILEGES ON *.* TO '$debianUser'@'127.0.0.1' IDENTIFIED BY '$debianUser'" | mysql -uroot -h127.0.0.1 --port=3306 -pbb321
echo "GRANT ALL PRIVILEGES ON *.* TO '$debianUser'@'127.0.0.1' IDENTIFIED BY '$debianPass'" | mysql -uroot -h127.0.0.1 --port=3307 -pbb321
echo "GRANT ALL PRIVILEGES ON *.* TO '$debianUser'@'127.0.0.1' IDENTIFIED BY '$debianPass'" | mysql -uroot -h127.0.0.1 --port=3308 -pbb321
echo "GRANT ALL PRIVILEGES ON *.* TO '$debianUser'@'127.0.0.1' IDENTIFIED BY '$debianPass'" | mysql -uroot -h127.0.0.1 --port=3309 -pbb321

/usr/bin/mysqladmin -u root -h 127.0.0.1 --port=3306 password 'bb321'
/usr/bin/mysqladmin -u root -h 127.0.0.1 --port=3307 password 'bb321'
/usr/bin/mysqladmin -u root -h 127.0.0.1 --port=3308 password 'bb321'
/usr/bin/mysqladmin -u root -h 127.0.0.1 --port=3309 password 'bb321'


sudo sed -i 's/3306/3307/g' mysql3307 
sudo sed -i 's/3306/3308/g' mysql3308 
sudo sed -i 's/3306/3309/g' mysql3309

sudo update-rc.d mysql3306 defaults
sudo update-rc.d mysql3307 defaults
sudo update-rc.d mysql3308 defaults
sudo update-rc.d mysql3309 defaults
