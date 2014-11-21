#!/bin/bash

#
# Output stuff in cyan
#
message_info() {
    if [ "$1" == "-n" ]; then arg="n"; shift; fi
    echo -${arg}e "\033[0;36m$1\033[0m"
}

#
# Output stuff in white color with a red background
#
message_error() {
    if [ "$1" == "-n" ]; then arg="n"; shift; fi
    echo -${arg}e "\033[0;41m$1\033[0m"
}

#
#   Print help text
#
printHelp() {
    me=`basename $0`
    echo -e "Usage: ./${me} PORT [--password=OPTIONAL-PASSWORD|--help]\n"

    echo "The script runs commands to setup a new db server at the specified port. It can optionally
    set the specified password for root user

    It create server with
    logs at /var/log/mysql/ directory
    data at /database/ directory
    "

    echo "Required arguments are:
    --port      Port at which mysql db server needs to run
    "

    echo "Available options are:
    -h --help           Print this help message
    --log-dir           Log directory for the mysql server
    --data-dir          Data directory for the mysql server
    --root-password     Password that needs to be set to the root user
    --force             Pass if the existing data directory is to be removed and created afresh.
    "

    exit 0;
}

# Defaults
logDir="/var/log/mysql"
dataDir="/database"
force='false'

while [[ $# -gt 0 ]] ;
do
    opt=$(echo $1 | cut -d '=' -f1); # grab the first value. '--secret-key' out of "--secret-key=test"
    val=$(echo $1 | cut -d '=' -f2); # grab the second value. 'test' out of "--secret-key=test"
    shift;
    case "$opt" in
        "--help")
            printHelp
            ;;
        "-h")
            printHelp
            ;;
        "--log-dir")
            logDir=$val
            ;;
        "--data-dir")
            dataDir=$val
            ;;
        "--root-password")
            password=$val
            ;;
        "--port")
            PORT=$val
            ;;
        "--force")
            force='true'
            ;;    
   esac
done

if [ -z ${PORT} ]; then
    message_error "Port not specified. Exiting"
    exit 1;
fi

if [ $(sudo lsof -i :$PORT| wc -l) -gt 0 ]; then
    message_error "process running at port $PORT. Please stop and re-run the script"
    exit 1
fi


# cd to the directory containing supervisor configurations
cd "$(dirname "$0")"

# SET Log folders and permissions
sudo mkdir -p $logDir/mysql$PORT
sudo touch $logDir/mysql$PORT/mysql.log
sudo touch $logDir/mysql$PORT/error.log
sudo touch $logDir/mysql$PORT/mysql-slow.log
sudo chown -R mysql:mysql $logDir

sudo setfacl -R -m u:mysql:rwX -m u:`whoami`:rwX $logDir
sudo setfacl -dR -m u:mysql:rwX -m u:`whoami`:rwX $logDir

# SET Database folders and permissions
if [ -d "$dataDir/mysql$PORT" ]; then
    if [ ${force} == 'true' ]  ; then
        # Force specified. Go ahead and delete the dir
        sudo rm -rf $dataDir/mysql$PORT
    else
        message_error "Directory $dataDir/mysql$PORT already exists. Use --force to remove and continue. Exiting"
        exit 1
    fi
fi
sudo mkdir -p $dataDir/mysql$PORT
sudo chown -R mysql:mysql $dataDir/mysql$PORT

# Get mysql configuration file
sudo cp ./mysql/my3306.cnf /etc/mysql/my$PORT.cnf
sudo sed -i "s/3306/$PORT/g" /etc/mysql/my$PORT.cnf


# install MySQL files into the new data dirs
sudo mysql_install_db --user=mysql --basedir=/usr --datadir=$dataDir/mysql$PORT --defaults-file=/etc/mysql/my$PORT.cnf > /dev/null 2>&1

# Get script to start/stop
sudo cp ./init.d/mysql3306 /etc/init.d/mysql$PORT 
sudo sed -i "s/3306/$PORT/g" /etc/init.d/mysql$PORT
sudo update-rc.d mysql$PORT defaults

#start mysql
sudo -b mysqld_safe --defaults-file=/etc/mysql/my$PORT.cnf --user=mysql > /dev/null 2>&1

echo "..."
sleep 5;

# Create debian user and passoword in the new db for maintainance
debianUser=$(sudo cat /etc/mysql/debian.cnf | grep "user" | tail -1| cut -d'=' -f2 | sed 's/ //g')
debianPass=$(sudo cat /etc/mysql/debian.cnf | grep "password" | tail -1| cut -d'=' -f2 | sed 's/ //g')
echo "GRANT ALL PRIVILEGES ON *.* TO '$debianUser'@'127.0.0.1' IDENTIFIED BY '$debianPass'; FLUSH PRIVILEGES;" | mysql -uroot -h 127.0.0.1 --port=$PORT

# Optionally set password
if [ ! -z ${password} ]; then
    message_info "Setting root password $password"
    sudo /usr/bin/mysqladmin -u root -h 127.0.0.1 --port=$PORT password "$password"
fi

message_info "Mysql running at port $PORT"
message_info "IMPORTANT: Specify host while logging in."
