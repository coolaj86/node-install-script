#!/bin/bash
#
# description: DevShelf service
# processname: node
# pidfile: /var/run/devshelf.pid
# logfile: /var/log/devshelf.log
#
# Based on https://gist.github.com/jinze/3748766
#
# To use it as service on Ubuntu:
# sudo cp devshelf.sh /etc/init.d/devshelf
# sudo chmod a+x /etc/init.d/devshelf
# sudo update-rc.d devshelf defaults
#
# Then use commands:
# service devshelf <command (start|stop|etc)>

NAME=devshelf                            # Unique name for the application
SOUREC_DIR=/home/node-app				 # Location of the application source
COMMAND=node                             # Command to run
SOURCE_NAME=index.js                     # Name os the applcation entry point script
USER=root                                # User for process running
NODE_ENVIROMENT=production               # Node environment

pidfile=/var/run/$NAME.pid
logfile=/var/log/$NAME.log
forever=forever

start() {
    export NODE_ENV=$NODE_ENVIROMENT
    echo "Starting $NAME node instance : "

    touch $logfile
    chown $USER $logfile

    touch $pidfile
    chown $USER $pidfile

    iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8080
    sudo -H -u $USER $forever start --pidFile $pidfile -l $logfile -a --sourceDir $SOUREC_DIR -c $COMMAND $SOUREC_DIR/$SOURCE_NAME

    RETVAL=$?
}

restart() {
    echo -n "Restarting $NAME node instance : "
    sudo -H -u $USER $forever restart $SOUREC_DIR/$SOURCE_NAME
    RETVAL=$?
}

status() {
    echo "Status for $NAME:"
    sudo -H -u $USER $forever list
    RETVAL=$?
}

stop() {
    echo -n "Shutting down $NAME node instance : "
    sudo -H -u $USER $forever stop $SOUREC_DIR/$SOURCE_NAME
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        status
        ;;
    restart)
        restart
        ;;
    *)
        echo "Usage:  {start|stop|status|restart}"
        exit 1
        ;;
esac
exit $RETVAL
