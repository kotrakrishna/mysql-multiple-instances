mysql-multiple-instances
========================

Step 1:
```
git clone https://github.com/kotrakrishna/mysql-multiple-instances.git
cd mysql-multiple-instances

# Login as root
sudo su

# Copy the apparmour settings for 
cp etc/apparmor.d/local/usr.sbin.mysqld3306 /etc/apparmor.d/local/usr.sbin.mysqld3306
```
Step 2:
```
# Change apparmor settings in etc/apparmor.d/usr.sbin.mysqld3306 appropriately
# Open /etc/apparmor.d/usr.sbin.mysqld
# #include <local/user.sbin.mysqld3306> before the closing brace
# Restart 
/etc/init.d/apparmor restart
```
Step 3:
```
# Exit from root shell
exit
```
Script to create multiple mysql instances on same machine running at different ports
```
./configureMultiple.sh --port=3306 --root-passoword=password
```
Connect to mysql using 
```
mysql  -uroot -h127.0.0.1 --port=3306 -ppassword
```
