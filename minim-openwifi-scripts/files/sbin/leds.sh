#!/bin/sh
# (C) 2008 openwrt.org

[ -f /etc/unum/features.sh ] && . /etc/unum/features.sh

. /lib/functions.sh
ACTION=$1
NAME=$2
do_led() {
	local name
	local sysfs
	config_get name $1 name
	config_get sysfs $1 sysfs
	[ "$name" = "$NAME" -o "$sysfs" = "$NAME" -a -e "/sys/class/leds/${sysfs}" ] && {
		[ "$ACTION" = "set" ] &&
			echo 1 >/sys/class/leds/${sysfs}/brightness \
			|| echo 0 >/sys/class/leds/${sysfs}/brightness
		exit 0
	}
}

[ "$1" = "clear" -o "$1" = "set" ] &&
	[ -n "$2" ] &&{
		config_load system
		config_foreach do_led
		exit 1
	}

[ "$1" = "test" ] && {
	[ -z "$2" -o ! -e "/sys/class/leds/$2" ] &&
		for fn in /sys/class/leds/*/trigger; do echo gpio > $fn; done \
                || echo gpio > /sys/class/leds/"$2"/trigger
}

#######################################################################
# led functionality
#
# All functions that are of the form led_* are
# part of the led spec and are intented to be
# called from other scripts.
#
# There is functionality to run this script on its own
# from the commandline such as:
# ./led.sh led
#
# Additionally there is demo functionality that can be
# run from the commandline:
# ./led.sh _demo
#######################################################################

if [ "$(board_name)" == "motorola,mh7020" ] ; then
	# On the 7020 the connected color is green
	# so change the WHITE defines to trick the
	# rest of the script
	readonly LED_WHITE_STANDARD_RED_LEVEL=0
	readonly LED_WHITE_STANDARD_GREEN_LEVEL=255
	readonly LED_WHITE_STANDARD_BLUE_LEVEL=0
	readonly LED_WHITE_DIM_RED_LEVEL=0
	readonly LED_WHITE_DIM_GREEN_LEVEL=13
	readonly LED_WHITE_DIM__BLUE_LEVEL=0
else
	# the LEDs are showing quite pink so we try to balance the colours here (SW-1299)
	readonly LED_WHITE_STANDARD_RED_LEVEL=120
	readonly LED_WHITE_STANDARD_GREEN_LEVEL=255
	readonly LED_WHITE_STANDARD_BLUE_LEVEL=120
	readonly LED_WHITE_DIM_RED_LEVEL=10
	readonly LED_WHITE_DIM_GREEN_LEVEL=13
	readonly LED_WHITE_DIM__BLUE_LEVEL=10
fi

readonly LED_AMBER_STANDARD_RED_LEVEL=255
readonly LED_AMBER_STANDARD_GREEN_LEVEL=120
readonly LED_AMBER_STANDARD_BLUE_LEVEL=0
readonly LED_AMBER_DIM_RED_LEVEL=10
readonly LED_AMBER_DIM_GREEN_LEVEL=10
readonly LED_AMBER_DIM__BLUE_LEVEL=0

# led_state location
# the intention is if any led_* function is triggered
# more than once we can ignore the duplicate calls
# effectively keeping the calls idempotent
readonly LED_STATE="/var/run/led.state"

# led_states
readonly LED_INIT="led_initial_state"
readonly LED_BOOT="led_boot"
readonly LED_AGENT_UP_BASE="led_agent_up_base"
readonly LED_AGENT_UP_SATELLITE_THRESHOLD_OK="led_agent_up_satellite_threshold_ok"
readonly LED_AGENT_UP_SATELLITE_THRESHOLD_LOW="led_agent_up_satellite_threshold_low"
readonly LED_AGENT_DOWN="led_agent_down"
readonly LED_FIRMWARE_UPDATE="led_firmware_update"
readonly LED_FACTORY_DEFAULTS="led_factory_defaults"
readonly LED_SATELLITE_CONNECTING="led_satellite_connecting"
readonly LED_REBOOT="led_reboot"
readonly LED_ACTIONS_OFF="led_actions_off"
readonly LED_OFF="led_off"
readonly LED_WPS="led_wps"
readonly LED_WLAN="led_wlan"
readonly LED_WLAN_OFF="led_wlan_off"
readonly LED_GET_STATE="led_get_state"
# The following value is read from /etc/config/minim which in fact is set
# from the server
BRIGHTNESS_THRESHOLD=255

# led sysfs names per uci
#readonly RED=$(uci get system.led_red.sysfs)
#readonly GREEN=$(uci get system.led_green.sysfs)
#readonly BLUE=$(uci get system.led_blue.sysfs)
readonly RED=red
readonly GREEN=green
readonly BLUE=blue
readonly AMBER=amber
readonly WIFI_2G=wifi_2g
readonly WIFI_5G=wifi_5g
readonly USB=usb
readonly POWER=power
readonly LAN1=lan1
readonly LAN2=lan2
readonly LAN3=lan3
readonly LAN4=lan4

# location of led node
readonly LEDS_NODE="/sys/class/leds"

# attributes that can be updated 
readonly TRIGGER="trigger"
readonly BRIGHTNESS="brightness"
readonly DELAY_ON="delay_on"
readonly DELAY_OFF="delay_off"

# time intervals in ms
readonly WHOLE="1000"
readonly QUARTER="250"

# $1 is a function
# $2 is a string of leds such as "$RED" or "$RED $BLUE"
# $3 is an optional value
# $4 param is an optional value
#
# for each of the leds run the function with provided parameters
_shift_while() {
    local ___fn="$1"
    [ "$#" -ge 1 ] && shift
    local ___params="$1"
    [ "$#" -ge 1 ] && shift
    local ___alpha="$1"
    [ "$#" -ge 1 ] && shift
    local ___beta="$1"

    for p in $___params; do
        eval "$___fn $p $___alpha $___beta"
    done
}

# Activate the `none` trigger for specified led
# This action automatically sets the brightness to zero
_none_trigger() {
    echo "none" > "$LEDS_NODE/$1/$TRIGGER"
}

# Activate the `usbport` trigger for the specified led and usb port
_usbport_trigger() {
    echo "usbport" > "$LEDS_NODE/$1/$TRIGGER"
    echo "1" > "$LEDS_NODE/$1/ports/$2"
}

# Activate the `netdev` trigger for the specified led and device
# with link trigger only
_netdev_link_trigger() {
    echo "netdev" > "$LEDS_NODE/$1/$TRIGGER"
    echo "1" > "$LEDS_NODE/$1/link"
    echo "$2" > "$LEDS_NODE/$1/device_name"
}

# Activate the `netdev` trigger for the specified led and device
# with link, rx, and tx triggers
_netdev_trigger() {
    echo "netdev" > "$LEDS_NODE/$1/$TRIGGER"
    echo "1" > "$LEDS_NODE/$1/link"
    echo "1" > "$LEDS_NODE/$1/rx"
    echo "1" > "$LEDS_NODE/$1/tx"
    echo "$2" > "$LEDS_NODE/$1/device_name"
}

# Activate the `default-on` trigger for the specified led
_default_on_trigger() {
    # don't update default-on if it's already set as it will
    # flicker the led
    grep -q "\[default-on\]" < "$LEDS_NODE/$1/$TRIGGER"
    [ $? -ne 0 ] && echo "default-on" > "$LEDS_NODE/$1/$TRIGGER"
}

# Set the brightness to the specified amount for the
# specfied led.
_brightness() {
    # Check if we have any desired value
    if [ "$2" != "" ]; then
        val=$2
    else
        val=$BRIGHTNESS_LEVEL
    fi
    # For some reason (possibly in the broadcom gpio driver),
    # a nonzero and non-255 brightness value does n't work 
    # if the current value is 0. In that case,
    # first set the brightness to 255 and then to the desired value
    cur_val=`cat "$LEDS_NODE/$1/$BRIGHTNESS"`
    if [ "$val" != 0 ] && [ "$val" != 255 ]; then
        if [ $cur_val -eq 0 ]; then
            echo "255" > "$LEDS_NODE/$1/$BRIGHTNESS"
        fi                           
    fi
    echo "$val" > "$LEDS_NODE/$1/$BRIGHTNESS"
}

# Set brightness of specified leds to 0.
# This may take a string of leds such as "$RED $BLUE"
_brightness_zero() {
    _shift_while _brightness "$1" "0"
}

# Set brighness of specified leds to one.
# This may take a string of leds such as "$RED $BLUE"
# This is useful to set the brightness of leds to
# a level that is not perceivable, and not zero.
#
# In the case that a trigger is set to `timer`
# and the brightness is set to 0 the trigger will
# automatically be set to `none`
_brightness_one() {
    _shift_while _brightness "$1" "1"
}

# Set brightness of specified leds to 255.
# This may take a string of leds such as "$RED $BLUE"
_brightness_full() {
    _shift_while _brightness "$1" "255"
}

# Activate the `timer` trigger for the specified led
_timer_trigger() {
    echo "timer" > "$LEDS_NODE/$1/$TRIGGER"
}

# Set delay on to the specified time in milliseconds
# for the specified led
_delay_on() {
    echo "$2" > "$LEDS_NODE/$1/$DELAY_ON"
}

# Set delay off to the specified time in milliseconds
# for the specified led
_delay_off() {
    echo "$2" > "$LEDS_NODE/$1/$DELAY_OFF"
}

# LED will blink 1s on; 1s off
_blink() {
    _shift_while _delay_on "$1" "$WHOLE"
    _shift_while _delay_off "$1" "$WHOLE"
}

# LED will rapidly blink .25s on; .25s off
_rapidly_blink() {
    _shift_while _delay_on "$1" "$QUARTER"
    _shift_while _delay_off "$1" "$QUARTER"
}

# Update current state of led
_set_state() {
    echo "$1" > "$LED_STATE"   
}

# Get current state of led
_get_state() {
    if [ ! -f "$LED_STATE" ]; then
        _set_state "$LED_INIT"
        # Wait as long as possible to call init led
        # as the HW boot blink has been initiated
        # by the bootloader and it is desirable
        # to let that carry on uninterrupted
        local ___discard=$( /etc/init.d/led "start" )
    fi

    echo $( cat "$LED_STATE" )
}

# Return if the state of the led 
# has changed
_is_new_state() {
    local ___current_state=$(_get_state)
    [ "$1" != "$___current_state" ]
    echo $?
}

# boot led sequence
led_boot() {  
    if [ $(_is_new_state "$LED_BOOT") -eq 0 ]; then
        if [ "$(board_name)" == "motorola,r14" ] ; then
            _none_trigger "$GREEN"
            _brightness_zero "$GREEN"
            _brightness_full "$AMBER"
            _netdev_link_trigger "$AMBER" eth1
            _default_on_trigger "$POWER"
            _brightness_full "$POWER"
            _usbport_trigger $USB usb1-port2
	    _netdev_trigger "$LAN1" lan1
	    _netdev_trigger "$LAN2" lan2
	    _netdev_trigger "$LAN3" lan3
	    _netdev_trigger "$LAN4" lan4
            led_wlan
	else
            led_actions_off
            _shift_while _timer_trigger "$RED $GREEN $BLUE"
            _brightness_one "$RED $GREEN $BLUE"
            _blink "$RED $GREEN $BLUE"
            _brightness_full "$RED $GREEN $BLUE"
        fi
        _set_state "$LED_BOOT"
    fi
}

# agent up on base led sequence
led_agent_up_base() {
    if [ $(_is_new_state "$LED_AGENT_UP_BASE") -eq 0 ]; then
        if [ "$(board_name)" == "motorola,r14" ] ; then
            _none_trigger "$AMBER"
            _brightness_zero "$AMBER"
            _brightness_full "$GREEN"
            _netdev_link_trigger "$GREEN" eth1
        else
            # default to off
            _red=0
            _green=0
            _blue=0
            if [ $BRIGHTNESS_LEVEL == "DIM" ]; then
                # dim white
                _red=$LED_WHITE_DIM_RED_LEVEL
                _green=$LED_WHITE_DIM_GREEN_LEVEL
                _blue=$LED_WHITE_DIM__BLUE_LEVEL
            elif [ $BRIGHTNESS_LEVEL == "STANDARD" ]; then
                # white
                _red=$LED_WHITE_STANDARD_RED_LEVEL
                _green=$LED_WHITE_STANDARD_GREEN_LEVEL
                _blue=$LED_WHITE_STANDARD_BLUE_LEVEL
            fi
            led_actions_off
            _shift_while _default_on_trigger "$RED $GREEN $BLUE"
            _shift_while _brightness "$RED" "$_red"
            _shift_while _brightness "$GREEN" "$_green"
            _shift_while _brightness "$BLUE" "$_blue"
        fi
        _set_state "$LED_AGENT_UP_BASE"
    fi
}

# agent up on satellite led sequence
led_agent_up_satellite_threshold_ok() {
    if [ "$(board_name)" == "motorola,r14" ] ; then
        _none_trigger "$AMBER"
        _brightness_zero "$AMBER"
        _default_on_trigger "$GREEN"
        _brightness_full "$GREEN"
    else
        # default to off
        _red=0
        _green=0
        _blue=0
        if [ $BRIGHTNESS_LEVEL == "DIM" ]; then
            # dim white
            _red=$LED_WHITE_DIM_RED_LEVEL
            _green=$LED_WHITE_DIM_GREEN_LEVEL
            _blue=$LED_WHITE_DIM__BLUE_LEVEL
        elif [ $BRIGHTNESS_LEVEL == "STANDARD" ]; then
            # white
            _red=$LED_WHITE_STANDARD_RED_LEVEL
            _green=$LED_WHITE_STANDARD_GREEN_LEVEL
            _blue=$LED_WHITE_STANDARD_BLUE_LEVEL
        fi
        led_actions_off
        _shift_while _default_on_trigger "$RED $GREEN $BLUE"
        _shift_while _brightness "$RED" "$_red"
        _shift_while _brightness "$GREEN" "$_green"
        _shift_while _brightness "$BLUE" "$_blue"
    fi
    _set_state "$LED_AGENT_UP_SATELLITE_THRESHOLD"
}

led_agent_up_satellite_threshold_low() {
    if [ "$(board_name)" == "motorola,r14" ] ; then
        _none_trigger "$GREEN"
        _brightness_zero "$GREEN"
        _default_on_trigger "$AMBER"
        _brightness_full "$AMBER"
    else
        # default to off
        _red=0
        _green=0
        _blue=0
        if [ $BRIGHTNESS_LEVEL == "DIM" ]; then
            # dim amber
            _red=$LED_AMBER_DIM_RED_LEVEL
            _green=$LED_AMBER_DIM_GREEN_LEVEL
            _blue=$LED_AMBER_DIM__BLUE_LEVEL
        elif [ $BRIGHTNESS_LEVEL == "STANDARD" ]; then
            # amber
            _red=$LED_AMBER_STANDARD_RED_LEVEL
            _green=$LED_AMBER_STANDARD_GREEN_LEVEL
            _blue=$LED_AMBER_STANDARD_BLUE_LEVEL
        fi

        led_actions_off
        _shift_while _default_on_trigger "$RED $GREEN $BLUE"
        _shift_while _brightness "$RED" "$_red"
        _shift_while _brightness "$GREEN" "$_green"
        _shift_while _brightness "$BLUE" "$_blue"
    fi
    _set_state "$LED_AGENT_UP_SATELLITE_THRESHOLD"
}

# agent down led sequence
# Default agent down led sequence
led_agent_down_default() {
    if [ $(_is_new_state "$LED_AGENT_DOWN") -eq 0 ]; then
        if [ "$(board_name)" == "motorola,r14" ] ; then
            _none_trigger "$GREEN"
            _brightness_zero "$GREEN"
            _brightness_full "$AMBER"
            _netdev_link_trigger "$AMBER" eth1
        else
            led_actions_off
            _shift_while _timer_trigger "$GREEN $BLUE"
            _brightness_one "$GREEN $BLUE"
            _blink "$GREEN $BLUE"
            _brightness "$RED" 0
            _brightness_full "$GREEN $BLUE"
        fi
        _set_state "$LED_AGENT_DOWN"
    fi
}

# Cable modem router led down sequence
led_agent_down_modemrouter() {
    if [ $(_is_new_state "$LED_AGENT_DOWN") -eq 0 ]; then
        led_actions_off
        _shift_while _timer_trigger "$RED $GREEN"
        _brightness_one "$BLUE"
        _blink "$RED $GREEN"
        _brightness "$BLUE" $LED_AMBER_STANDARD_BLUE_LEVEL
        _brightness "$GREEN" $LED_AMBER_STANDARD_GREEN_LEVEL
        _brightness "$RED" $LED_AMBER_STANDARD_RED_LEVEL
        _set_state "$LED_AGENT_DOWN"
    fi
}

led_agent_down() {
    if [ "$UNUM_FEATURE_CABLESTATUS_PIN_PRESENT" != "" ]; then
        led_agent_down_modemrouter
    else
        led_agent_down_default
    fi
}

# firmware update led sequence
led_firmware_update() {
    if [ $(_is_new_state "$LED_FIRMWARE_UPDATE") -eq 0 ]; then
        if [ "$(board_name)" == "motorola,q14" ] ; then
            echo ZW_CODE_05 > /dev/ttyMSM1
        elif [ "$(board_name)" == "motorola,r14" ] ; then
            _none_trigger "$AMBER"
            _brightness_zero "$AMBER"
            _timer_trigger "$GREEN"
            _rapidly_blink "$GREEN"
            _brightness_full "$GREEN"
        else
            led_actions_off
            _shift_while _timer_trigger "$GREEN $BLUE"
            _brightness_one "$GREEN $BLUE"
            _rapidly_blink "$GREEN $BLUE"
            _brightness "$RED" 0
            _brightness_full "$GREEN $BLUE"
        fi
        _set_state "$LED_FIRMWARE_UPDATE"
    fi
}

# factory defaults led sequence
led_factory_defaults() {
    if [ $(_is_new_state "$LED_FACTORY_DEFAULTS") -eq 0 ]; then
        if [ "$(board_name)" == "motorola,q14" ] ; then
	    echo ZW_CODE_05 > /dev/ttyMSM1
        elif [ "$(board_name)" == "motorola,r14" ] ; then
            _none_trigger "$AMBER"
            _brightness_zero "$AMBER"
            _timer_trigger "$POWER"
            _rapidly_blink "$POWER"
            _brightness_full "$POWER"
        else
            led_actions_off
            _shift_while _timer_trigger "$GREEN $BLUE"
            _brightness_one "$GREEN $BLUE"
            _rapidly_blink "$GREEN $BLUE"
            _brightness "$RED" 0
            _brightness_full "$GREEN $BLUE"
        fi
        _set_state "$LED_FACTORY_DEFAULTS"
    fi
}

# satellite connecting led sequence
led_satellite_connecting() {
    if [ $(_is_new_state "$LED_SATELLITE_CONNECTING") -eq 0 ]; then
        if [ "$(board_name)" == "motorola,r14" ] ; then
            _none_trigger "$AMBER"
            _brightness_zero "$AMBER"
            _timer_trigger "$GREEN"
            _blink "$GREEN"
            _brightness_full "$GREEN"
        else
            led_actions_off
            _shift_while _timer_trigger "$GREEN $BLUE"
            _brightness_one "$GREEN $BLUE"
            _blink "$GREEN $BLUE"
            _brightness "$RED" 0
            _brightness_full "$GREEN $BLUE"
        fi
        _set_state "$LED_SATELLITE_CONNECTING"
    fi
}

# reboot led sequence
led_reboot() {
    if [ $(_is_new_state "$LED_REBOOT") -eq 0 ]; then
        if [ "$(board_name)" == "motorola,q14" ] ; then
	    echo ZW_CODE_05 > /dev/ttyMSM1
        elif [ "$(board_name)" == "motorola,r14" ] ; then
            _none_trigger "$AMBER"
            _brightness_zero "$AMBER"
            _timer_trigger "$GREEN"
            _blink "$GREEN"
            _brightness_full "$GREEN"
        else
            led_actions_off
            _shift_while _timer_trigger "$GREEN $BLUE"
            _brightness_one "$GREEN $BLUE"
            _blink "$GREEN $BLUE"
            _brightness "$RED" 0
            _brightness_full "$GREEN $BLUE"
        fi
        _set_state "$LED_AGENT_DOWN"
    fi
}

# Turn the led actions off
led_actions_off() {
    if [ $(_is_new_state "$LED_ACTIONS_OFF") -eq 0 ]; then
        _shift_while _none_trigger "$RED $GREEN $BLUE"
        _set_state "$LED_ACTIONS_OFF"
    fi
}

# Turn the leds off
led_off() {
    if [ $(_is_new_state "$LED_OFF") -eq 0 ]; then
        if [ "$(board_name)" == "motorola,r14" ] ; then
            _shift_while _none_trigger "$GREEN $AMBER $USB $WIFI_2G $WIFI_5G $POWER $LAN1 $LAN2 $LAN3 $LAN4"
            _brightness_zero "$GREEN $AMBER $USB $WIFI_2G $WIFI_5G $POWER $LAN1 $LAN2 $LAN3 $LAN4"
        else
            _shift_while _none_trigger "$RED $GREEN $BLUE"
            _brightness_zero "$RED $GREEN $BLUE"
        fi
        _set_state "$LED_OFF"
    fi
}

# Blink wlan leds
led_wps() {
    _shift_while _timer_trigger "$WIFI_2G $WIFI_5G"
    _blink "$WIFI_2G $WIFI_5G"
    _brightness_full "$WIFI_2G $WIFI_5G"
}

# wlan leds on based on radio status
led_wlan() {
    _netdev_trigger "$WIFI_2G" wlan0
    _netdev_trigger "$WIFI_5G" wlan1
    _brightness_full "$WIFI_2G $WIFI_5G"
}

led_wlan_off() {
    _shift_while _none_trigger "$WIFI_2G $WIFI_5G"
    _brightness_zero "$WIFI_2G $WIFI_5G"
}

# A demo of the blink sequences
_demo() {
    
    echo "Starting LED Demo"
    led_switch "$LED_OFF"
    sleep 1

    if [ "$(board_name)" == "motorola,r14" ] ; then
        echo "$LED_WPS"
        led_switch "$LED_WPS"
        sleep 1

        echo "$LED_WLAN"
        led_switch "$LED_WLAN"
        sleep 1

        echo "$LED_WLAN_OFF"
        led_switch "$LED_WLAN_OFF"
        sleep 1
    fi

    echo "$LED_FACTORY_DEFAULTS"
    led_switch "$LED_FACTORY_DEFAULTS"
    sleep 5

    echo "$LED_BOOT"
    led_switch "$LED_BOOT"
    sleep 5

    echo "$LED_AGENT_UP_BASE 32"
    led_switch "$LED_AGENT_UP_BASE"
    sleep 5

    echo "$LED_SATELLITE_CONNECTING"
    led_switch "$LED_SATELLITE_CONNECTING"
    sleep 5

    echo "$LED_AGENT_UP_SATELLITE_THRESHOLD_OK"
    led_switch "$LED_AGENT_UP_SATELLITE_THRESHOLD_OK"
    sleep 5

    echo "$LED_AGENT_UP_SATELLITE_THRESHOLD_LOW"
    led_switch "$LED_AGENT_UP_SATELLITE_THRESHOLD_LOW"
    sleep 5

    echo "$LED_AGENT_DOWN"
    led_switch "$LED_AGENT_DOWN"
    sleep 5

    echo "$LED_FIRMWARE_UPDATE"
    led_switch "$LED_FIRMWARE_UPDATE"
    sleep 5
    
    echo "$LED_REBOOT"
    led_switch "$LED_REBOOT"
    sleep 5

    led_switch "$LED_OFF"
}

# choose the sequence to run
led_switch() {
    case "$1" in
        $LED_BOOT) led_boot;;
        $LED_AGENT_UP_BASE) led_agent_up_base;;
        $LED_AGENT_UP_SATELLITE_THRESHOLD_OK) led_agent_up_satellite_threshold_ok;;
        $LED_AGENT_UP_SATELLITE_THRESHOLD_LOW) led_agent_up_satellite_threshold_low;;
        $LED_AGENT_DOWN) led_agent_down;;
        $LED_FIRMWARE_UPDATE) led_firmware_update;;
        $LED_FACTORY_DEFAULTS) led_factory_defaults;;
        $LED_SATELLITE_CONNECTING) led_satellite_connecting;;
        $LED_REBOOT) led_reboot;;
        $LED_OFF) led_off;;
        $LED_WPS) led_wps;;
        $LED_WLAN) led_wlan;;
        $LED_WLAN_OFF) led_wlan_off;;
        $LED_GET_STATE) _get_state;;
        _demo) led_off && _demo;;
        *) echo "$1 Action not recognized";;
    esac
}

_uci_brightness=`/sbin/uci -q get minim.@unum[0].led_brightness`
BRIGHTNESS_LEVEL=STANDARD
if [ "$_uci_brightness" != "" ]; then
    if [ $_uci_brightness -le 33 ]; then
        # 0 to 33 should be off
        BRIGHTNESS_LEVEL=OFF
    elif [ $_uci_brightness -le 66 ]; then
        # 34 to 66 should be dim
        BRIGHTNESS_LEVEL=DIM
    fi
fi

# do nothing on cablemodem routers where the cable status is not up (LED is shared with modem)
[ -f /etc/unum/features.sh ] && . /etc/unum/features.sh
[ "$UNUM_FEATURE_CABLESTATUS_PIN_PRESENT" == "1" ] && [ ! -f /tmp/cablestatus_up ] && [ "$1" != "$LED_OFF" ] && exit

# remove existing state where a force is desired
[ "$2" == "force" ] && _set_state ""

# run the command
[ -n "$1" ] && led_switch "$1" && exit 0

