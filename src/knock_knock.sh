#!/bin/bash
#
# Knocker, by LuisPa 2024
#
# Dependencies: netcat-openbsd, knock

# Configuration: Server and Port details
SERVER="www.mypublicsite.com"
PORT="2443"

# Port knock sequence
KNOCK_SEQUENCE=("12345" "23456" "34567")

# Global configuration for the number of attempts
MAX_ATTEMPTS=3

# ----------------------------------------------------------------------------------------
# Pretty Messaging Setup
# ----------------------------------------------------------------------------------------

# Colors for status messages
COLOR_GREEN=$(tput setaf 2)
COLOR_YELLOW=$(tput setaf 3)
COLOR_RED=$(tput setaf 1)

# Terminal width
width=$(tput cols)
message_len=0

# Function to print a message
echo_message() {
    local message=$1
    message_len=${#message}
    printf "%s " "$message"
}

# Function to print a status message (OK, WARNING, ERROR) right-justified
echo_status() {
    local status=$1
    local status_msg
    local status_color

    case $status in
        ok)
            status_msg="OK"
            status_color=${COLOR_GREEN}
            ;;
        warning)
            status_msg="WARNING"
            status_color=${COLOR_YELLOW}
            ;;
        error)
            status_msg="ERROR"
            status_color=${COLOR_RED}
            ;;
        *)
            status_msg="UNKNOWN"
            status_color=${COLOR_RED}
            ;;
    esac

    local status_len=${#status_msg}
    local spaces=$((width - message_len - status_len - 2))

    printf "%${spaces}s" "["
    printf "${status_color}${status_msg}\e[0m"
    echo "]"
}

# ----------------------------------------------------------------------------------------
# Utility Functions
# ----------------------------------------------------------------------------------------

# Function to check if a port is open on a server
is_port_open() {
    echo_message "Checking ${SERVER}:${PORT}"
    nc -z -w 1 ${SERVER} ${PORT} 2> /dev/null
    if [ $? -ne 0 ]; then
        echo_status warning
        return 1
    else
        echo_status ok
        return 0
    fi
}

# Function to wait for internet connectivity
wait_for_internet() {
    echo_message "Checking internet connectivity"
    while ! ping -c 1 8.8.8.8 >/dev/null 2>&1; do
        echo "Waiting for internet access"
        sleep 1
    done
    echo_status ok
}

# Function to flush DNS cache
flush_dns_cache() {
    echo_message "Flushing DNS cache"
    resolvectl flush-caches
    echo_status ok
}


# Function to perform the knock sequence
perform_knock() {
    echo_message "Performing knock sequence"
    knock -4 -d 1000 -v ${SERVER} "${KNOCK_SEQUENCE[@]}"
    sleep 1
}

# ----------------------------------------------------------------------------------------
# Main Script Execution
# ----------------------------------------------------------------------------------------

# Step 1: Wait for internet access
wait_for_internet

# Step 2: Flush DNS cache
flush_dns_cache

# Step 3: Attempt to open the port with knocking
keep_trying=true
retry=1
door_is_open=false

while [ $retry -le $MAX_ATTEMPTS ]; do
    if $keep_trying; then
        is_port_open
        if [ $? -ne 0 ]; then
            echo "Door is closed. Knocking..."
            perform_knock
        else
            door_is_open=true
            keep_trying=false
        fi
    fi
    retry=$(( retry + 1 ))
done

# Exit with an error if the port was not opened
if ! $door_is_open; then
    echo "Failed to open port after 3 attempts."
    exit 1
fi

exit 0
