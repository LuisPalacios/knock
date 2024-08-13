#!/bin/bash
#
# Knocker Client helper, by LuisPa 2024
#
# Dependencies: netcat-openbs, knock

# This script knocks in a server using the following parameters
# This is a helper sample related to the "Advanced example with DNAT"
# that you can find in the ../knockd.conf file
# Our target entry point...
SERVER="www.mypublicsite.com"
PORT="2443"

# SYNs we'll send, so knockd opens the above port
KNOCK1="12345"
KNOCK2="23456"
KNOCK3="34567"

# Pretty echos
VERDE=$(tput setaf 2)
AMARILLO=$(tput setaf 3)
ROJO=$(tput setaf 1)
# Messaging
spaces=0
width=$(tput cols)
echo_message() {
    message=${1}
    message_len=${#message}
    printf "%s " "$message"
}
echo_status() {
    case ${1} in
        ok)
            status_msg="OK"
            status_color=${VERDE}
            ;;
        warning)
            status_msg="WARNING"
            status_color=${AMARILLO}
            ;;
        error)
            status_msg="ERROR"
            status_color=${ROJO}
            ;;
        *)
            status_msg="???"
            status_color=${ROJO}
            ;;
    esac
    status_len=${#status_msg}
    spaces=$((width - message_len - status_len - 2 ))
    printf "%${spaces}s" "["
    printf "${status_color}${status_msg}\e[0m"
    echo "]"
}

# Openess
is_port_open() {
    echo_message "Checking ${SERVER}:${PORT}"
    nc -z -w 1 ${SERVER} ${PORT} 2> /dev/null
    if [ "${?}" == "1" ] ; then
        echo_status warning
        return 1
    else
        echo_status ok
        return 0
    fi
}

# Wait till we have internet
echo_message "Checking my service"
while ! ping -c 1 8.8.8.8 >/dev/null 2>&1; do echo "Waiting for internet access"; sleep 1; done;
echo_status ok

# Knock Knock
#
keep_trying=true
retry=1
door_is_open=false
while [ $retry -le 3 ]; do
    if $keep_trying; then
        is_port_open
        if [ "${?}" != "0" ] ; then
            echo "Door is closed. Knocking..."
            knock -4 -d 1000 -v ${SERVER} ${KNOCK1} ${KNOCK2} ${KNOCK3}
            sleep 1
        else
            door_is_open=true
            keep_trying=false
        fi
    fi
    retry=$(( retry + 1 ))
done

if ! $door_is_open; then
    exit 1
fi

exit 0

