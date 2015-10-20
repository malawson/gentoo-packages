#!/sbin/runscript
# $Header: $


USER=grafana
GROUP=grafana
GRAFANA_SERVER_DIR=${GRAFANA_SERVER_DIR:-/usr/local/grafana}
GRAFANA_SERVER_EXEC=${GRAFANA_SERVER_EXEC:-${GRAFANA_SERVER_DIR}/bin/grafana-server}
CONFIG_FILE=${CONFIG_FILE:-${GRAFANA_SERVER_DIR}/conf/defaults.ini}
GRAFANA_SERVER_PID_DIR=${GRAFANA_SERVER_PID_DIR:-/var/run/grafana}
GRAFANA_SERVER_PIDFILE=${GRAFANA_SERVER_PIDFILE:-${GRAFANA_SERVER_PID_DIR}/grafana-server.pid}
GRAFANA_SERVER_OPTS="-config="${CONFIG_FILE}" -homepath="${GRAFANA_SERVER_DIR}" -pidfile="${GRAFANA_SERVER_PIDFILE}""




depend() {
	need net
}


start() {

	mkdir -p "$GRAFANA_SERVER_PID_DIR"
	chown ${USER}:${GROUP} "$GRAFANA_SERVER_PID_DIR"
    # grafana server runs as grafana - so let's ensure grafana owns the configs
    chown -R grafana.grafana /usr/local/grafana

	ebegin "Starting grafana-server"
	nohup su grafana -s /bin/sh -c "$GRAFANA_SERVER_EXEC $GRAFANA_SERVER_OPTS" >/dev/null 2>&1 &
	eend $? 

}


stop() {
    
    ebegin "Stopping grafana-server"

    # try pgrep
    pid=$(pgrep -f -P 1 -u $USER $GRAFANA_SERVER_EXEC)

    if [ ! -n "$pid" ]; then
        # try the pid file
        if [ -f "$GRAFANA_SERVER_PIDFILE" ] ; then
            read pid < "$GRAFANA_SERVER_PIDFILE"
        fi
    fi

    if [ -n "$pid" ]; then
        kill $pid 
        retval=$?
        sleep 2
        rm -f "${GRAFANA_SERVER_PIDFILE}"
    else 
    	echo -e "\ngrafana-server pid file not found - check the process"
    fi 

    eend ${retval}
}
