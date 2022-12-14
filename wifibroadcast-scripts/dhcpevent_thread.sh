#!/bin/bash

COMMAND="${1}"
IP="${2}"

export PATH=/usr/local/bin:${PATH}

#if [ ! -f /tmp/mavlink_router_pipe ]; then 
#    sleep 1
#fi

if [[ ${COMMAND} == "old" || ${COMMAND} == "add" ]]; then
    qstatus "Adding ${IP} to udp endpoint" 5
    qstatus "Video" 5
    echo "add:${IP}" > /dev/udp/127.0.0.1/9523
    qstatus "Mavlink" 5
    echo "add:${IP}:14550" > /dev/udp/127.0.0.1/9520
    qstatus "Microservice" 5
    echo "add:${IP}:15550" > /dev/udp/127.0.0.1/9521
    qstatus "External device connected: ${IP}" 5
    PINGFAIL=0
    IPTHERE=1
    while [ ${IPTHERE} -eq 1 ]; do
        ping -c 3 -W 1 -n -q ${IP} > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            IPTHERE=1
            PINGFAIL=0
        else
	    echo "GroundIP" > /dev/udp/${IP}/5115
            ping -c 1 -W 10 -n -q ${IP} > /dev/null 2>&1
            if [ $? -ne 0 ]; then
                if [ ${PINGFAIL} -ge 6 ]; then
                    IPTHERE=0
		    echo "del:${IP}:14550" > /dev/udp/127.0.0.1/9520
		    echo "del:${IP}:15550" > /dev/udp/127.0.0.1/9521
		    echo "del:${IP}" > /dev/udp/127.0.0.1/9523
		    qstatus "{IP} removed from endpoints"
                else
                    PINGFAIL=$((PINGFAIL+1))
                fi
            fi
        fi
        sleep 1
    done
    qstatus "External device gone: ${IP}" 5
else
                    echo "del:${IP}:14550" > /dev/udp/127.0.0.1/9520
                    echo "del:${IP}:15550" > /dev/udp/127.0.0.1/9521
                    echo "del:${IP}" > /dev/udp/127.0.0.1/9523
                    qstatus "{IP} removed from endpoints"
fi
