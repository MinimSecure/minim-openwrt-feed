#!/bin/sh

AGENT_STATUS_UP_LED_FILE=/tmp/agent_status_up_led

#opmode=`/bin/nvram get multiap_mode`
opmode=`uci get minim.@unum[-1].opmode`
INIT=2

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
    if [ $opmode != "ap" ]; then
        # all modes but repeater
        if [ $agent_status_prev -ne $agent_status_curr ]; then
            # has changed so update the led
            if [ $agent_status_curr -eq 1 ]; then
                if [ $agent_status_prev -eq $INIT ]; then
                    # on startup, force the led to update in case
                    # the brightness has changed
                    /sbin/led_minim.sh "led_7020_agent_up_base" "force"
                else
                    /sbin/led_minim.sh "led_7020_agent_up_base"
                fi
            else
                /sbin/led_minim.sh "led_7020_agent_down"
	    fi
        fi
    else
        # repeater
	# read and evaluate rssi
        rssi=`wl -i wl1 rssi 2>/dev/null`
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

        # act only on change
        if [ $agent_status_prev -ne $agent_status_curr -o  $rssi_status_ok_curr -ne $rssi_status_ok_prev ]; then
            if [ $agent_status_curr -eq 1 ]; then
                if [ $rssi_status_ok_curr -eq 1 ]; then
                    # agent is up and signal is good
                    if [ $agent_status_prev -eq $INIT ]; then
                        # on startup, force the led to update in case
                        # the brightness has changed
                        /sbin/led_minim.sh "led_7020_agent_up_satellite_threshold_ok" "force"
                    else
			/sbin/led_minim.sh "led_7020_agent_up_satellite_threshold_ok"
                    fi
                else
                    # agent is up but signal is poor
                    if [ $agent_status_prev -eq $INIT ]; then
                        # on startup, force the led to update in case
                        # the brightness has changed
                        /sbin/led_minim.sh "led_7020_agent_up_satellite_threshold_low" "force"
                    else
                        /sbin/led_minim.sh "led_7020_agent_up_satellite_threshold_low"
                    fi
                fi
            else
                # agent is down
                /sbin/led_minim.sh "led_7020_agent_down"
            fi
        fi
    fi
    agent_status_prev=$agent_status_curr
    rssi_status_ok_prev=$rssi_status_ok_curr
    sleep 5
done
