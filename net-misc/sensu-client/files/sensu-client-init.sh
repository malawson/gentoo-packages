#!/sbin/runscript
# $Header: $


USER=sensu
GROUP=sensu
SENSU_CLIENT_DIR=${SENSU_CLIENT_DIR:-/usr/local/sensu-client}
SENSU_CLIENT_EXEC=${SENSU_CLIENT_EXEC:-${SENSU_CLIENT_DIR}/bin/sensu-client}
CONFIG_FILE=${CONFIG_FILE:-${SENSU_CLIENT_DIR}/etc/sensu/config.json}
CONFIG_DIR=${CONFIG_DIR:-${SENSU_CLIENT_DIR}/etc/sensu}
EXTENSION_DIR=${EXTENSION_DIR:-${SENSU_CLIENT_DIR}/etc/sensu/extensions}
PLUGINS_DIR=${PLUGINS_DIR:-${SENSU_CLIENT_DIR}/etc/sensu/plugins}
HANDLERS_DIR=${HANDLERS_DIR:-${SENSU_CLIENT_DIR}/etc/sensu/handlers}
SENSU_CLIENT_PID_DIR=${SENSU_CLIENT_PID_DIR:-/var/run/sensu}
SENSU_CLIENT_PIDFILE=${SENSU_CLIENT_PIDFILE:-${SENSU_CLIENT_PID_DIR}/sensu-client.pid}
LOG_DIR=${LOG_DIR:-/var/log/sensu}
LOG_FILE=${LOG_FILE:-${LOG_DIR}/sensu-client.log}
LOG_LEVEL=info
SENSU_CLIENT_OPTS="-b -c $CONFIG_FILE -d $CONFIG_DIR -e $EXTENSION_DIR -p $SENSU_CLIENT_PIDFILE -l $LOG_FILE -L $LOG_LEVEL"



depend() {
	need net
}


start() {


	mkdir -p "$LOG_DIR"
	mkdir -p "$SENSU_CLIENT_PID_DIR"
	chown ${USER}:${GROUP} "$LOG_DIR"
	chown ${USER}:${GROUP} "$SENSU_CLIENT_PID_DIR"
    # Sensu client runs as sensu - so let's ensure sensu owns the configs
    chown -R sensu.sensu /usr/local/sensu-client/etc/sensu/{conf.d,config.json}

	ebegin "Starting sensu-client"
	su sensu -s /bin/sh -c "$SENSU_CLIENT_EXEC $SENSU_CLIENT_OPTS"
	eend $? 

}


stop() {
    
    ebegin "Stopping sensu-client"

    # try pgrep
    pid=$(pgrep -f -P 1 -u $USER $SENSU_CLIENT_EXEC)

    if [ ! -n "$pid" ]; then
        # try the pid file
        if [ -f "$SENSU_CLIENT_PIDFILE" ] ; then
            read pid < "$SENSU_CLIENT_PIDFILE"
        fi
    fi

    if [ -n "$pid" ]; then
        kill $pid 
        retval=$?
        sleep 2
        rm -f "${SENSU_CLIENT_PIDFILE}"
    else 
    	echo -e "\nsensu-client pid file not found - check the process"
    fi 

    eend ${retval}
}
