#!/sbin/runscript
# $Header: $


USER=sensu
GROUP=sensu
SENSU_SERVER_DIR=${SENSU_SERVER_DIR:-/usr/local/sensu-server}
SENSU_SERVER_EXEC=${SENSU_SERVER_EXEC:-${SENSU_SERVER_DIR}/bin/sensu-server}
CONFIG_FILE=${CONFIG_FILE:-${SENSU_SERVER_DIR}/etc/sensu/config.json}
CONFIG_DIR=${CONFIG_DIR:-${SENSU_SERVER_DIR}/etc/sensu}
EXTENSION_DIR=${EXTENSION_DIR:-${SENSU_SERVER_DIR}/etc/sensu/extensions}
PLUGINS_DIR=${PLUGINS_DIR:-${SENSU_SERVER_DIR}/etc/sensu/plugins}
HANDLERS_DIR=${HANDLERS_DIR:-${SENSU_SERVER_DIR}/etc/sensu/handlers}
SENSU_SERVER_PID_DIR=${SENSU_SERVER_PID_DIR:-/var/run/sensu}
SENSU_SERVER_PIDFILE=${SENSU_SERVER_PIDFILE:-${SENSU_SERVER_PID_DIR}/sensu-server.pid}
LOG_DIR=${LOG_DIR:-/var/log/sensu}
LOG_FILE=${LOG_FILE:-${LOG_DIR}/sensu-server.log}
LOG_LEVEL=info
SENSU_SERVER_OPTS="-b -c $CONFIG_FILE -d $CONFIG_DIR -e $EXTENSION_DIR -p $SENSU_SERVER_PIDFILE -l $LOG_FILE -L $LOG_LEVEL"



depend() {
	need net
}


start() {


	mkdir -p "$LOG_DIR"
	mkdir -p "$SENSU_SERVER_PID_DIR"
	chown ${USER}:${GROUP} "$LOG_DIR"
	chown ${USER}:${GROUP} "$SENSU_SERVER_PID_DIR"
	# Sensu server runs as sensu - so let's ensure sensu owns the configs
    	chown -R sensu.sensu /usr/local/sensu-server/etc/sensu/{conf.d,config.json,extensions,handlers,mutators}

	ebegin "Starting sensu-server"
	su sensu -s /bin/sh -c "$SENSU_SERVER_EXEC $SENSU_SERVER_OPTS"
	eend $? 

}


stop() {
    
    ebegin "Stopping sensu-server"

    # try pgrep
    pid=$(pgrep -f -P 1 -u $USER $SENSU_SERVER_EXEC)

    if [ ! -n "$pid" ]; then
        # try the pid file
        if [ -f "$SENSU_SERVER_PIDFILE" ] ; then
            read pid < "$SENSU_SERVER_PIDFILE"
        fi
    fi

    if [ -n "$pid" ]; then
        kill $pid 
        retval=$?
        sleep 2
        rm -f "${SENSU_SERVER_PIDFILE}"
    else 
    	echo -e "\nsensu-server pid file not found - check the process"
    fi 

    eend ${retval}
}
