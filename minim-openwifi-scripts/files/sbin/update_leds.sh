#!/bin/sh
. /lib/functions.sh
. /lib/functions/system.sh

AGENT_STATUS_UP_LED_FILE=/tmp/agent_status_up_led

opmode=`/sbin/uci -q get minim.@unum[-1].opmode`

INIT=2

get_root_port() {
    # find default gateway
    firstline=1
    for entry in `sed -e 's/\s/_/g' < /proc/net/route `; do
        [ $firstline -eq 1 ] && firstline=0 && continue
        flags=`echo $entry | awk -F_ '{print $4}'`
        default=$(( $flags & 3 ))
        [ $default -eq 3 ] || continue
        ip_hex=`echo $entry | awk -F_ '{print $3}'`
        break
    done

    # convert to decimal
    ip_hex_4="0x"`echo $ip_hex | cut -c 1-2`
    ip_4=$(( $ip_hex_4 ))
    ip_hex_3="0x"`echo $ip_hex | cut -c 3-4`
    ip_3=$(( $ip_hex_3 ))
    ip_hex_2="0x"`echo $ip_hex | cut -c 5-6`
    ip_2=$(( $ip_hex_2 ))
    ip_hex_1="0x"`echo $ip_hex | cut -c 7-8`
    ip_1=$(( $ip_hex_1 ))

    ip="$ip_1.$ip_2.$ip_3.$ip_4"

    # find matching mac address (of gateway)
    mac=`cat /proc/net/arp | grep $ip | tr -s " " | sed -e 's/\s/_/g' | cut -d_ -f 4`

    # find switch port on which mac was found
    port=`brctl showmacs br-lan | grep $mac | tr -s " " | sed -e 's/\s/_/g' | cut -d_ -f 2`

    echo 0x$port
}

get_port_num() {
	intf=$1
	cat /sys/class/net/$intf/brport/port_no
}

get_connection_type() {
	# default to wireless
	root=wireless

	# get per board list of ethernet ports
	case $(board_name) in
	motorola,r14)
		ethernet_ports="eth1 lan1 lan2 lan3 lan4"
		;;
	*)
		ethernet_ports="eth0 eth1"
		;;
	esac

	# get bridge root port number
	root_port=$(get_root_port)

	# compare bridge root port number with ethernet port numbers
	for port in $ethernet_ports ; do
		if [ "$root_port" = "$(get_port_num $port)" ] ; then
			root=ethernet
			break
		fi
	done

	echo $root
}

agent_status_curr=0
agent_status_prev=$INIT
rssi_status_ok_curr=0
rssi_status_ok_prev=$INIT

while true
do
    # check the agent status
    if [ -f $AGENT_STATUS_UP_LED_FILE ]; then
        agent_status_curr=1
    else
        agent_status_curr=0
    fi
    if [ "$opmode" != "mesh_11s_ap" ]; then
        # all modes but repeater
        if [ $agent_status_prev -ne $agent_status_curr ]; then
            # has changed so update the led
            if [ $agent_status_curr -eq 1 ]; then
                if [ $agent_status_prev -eq $INIT ]; then
                    # on startup, force the led to update in case
                    # the brightness has changed
                    /sbin/leds.sh "led_agent_up_base" "force"
                else
                    /sbin/leds.sh "led_agent_up_base"
                fi
            else
                /sbin/leds.sh "led_agent_down"
            fi
        fi
    else
        # repeater

        # figure out if we are connected via ethernet or wireless
        connection_type=$(get_connection_type)
        if [ "$connection_type" = "ethernet" ] ; then
            # for ethernet, set led status to ok
            rssi_status_ok_curr=1
        else
            # read and evaluate rssi
            rssi=`iwinfo wlan1 info | grep Signal | awk '{print $2}' 2>/dev/null`
            if [ "$rssi" == "" ]; then
                # Some error while getting RSSI
                sleep 1
                continue
            fi

            # add hysteresis
            if [ $rssi -ge -65 -a $rssi_status_ok_prev -ne 1 ]; then
                # now greater than threshold and was not ok before
                rssi_status_ok_curr=1
            elif [ $rssi -le -69 -a $rssi_status_ok_prev -ne 0 ]; then
                # now less than threshold and was ok before
                rssi_status_ok_curr=0
            fi
        fi

        # act only on change
        if [ $agent_status_prev -ne $agent_status_curr -o  $rssi_status_ok_curr -ne $rssi_status_ok_prev ]; then
            if [ $agent_status_curr -eq 1 ]; then
                if [ $rssi_status_ok_curr -eq 1 ]; then
                    # agent is up and signal is good
                    if [ $agent_status_prev -eq $INIT ]; then
                        # on startup, force the led to update in case
                        # the brightness has changed
                        /sbin/leds.sh "led_agent_up_satellite_threshold_ok" "force"
                    else
                        /sbin/leds.sh "led_agent_up_satellite_threshold_ok"
                    fi
                else
                    # agent is up but signal is poor
                    if [ $agent_status_prev -eq $INIT ]; then
                        # on startup, force the led to update in case
                        # the brightness has changed
                        /sbin/leds.sh "led_agent_up_satellite_threshold_low" "force"
                    else
                        /sbin/leds.sh "led_agent_up_satellite_threshold_low"
                    fi
                fi
            else
                # agent is down
                /sbin/leds.sh "led_agent_down"
            fi
        fi
    fi
    agent_status_prev=$agent_status_curr
    rssi_status_ok_prev=$rssi_status_ok_curr
    sleep 5
done
