#!/bin/sh /etc/rc.common
# Copyright (C) 2022 Minim Inc

START=99
STOP=99

boot() {
    # disable SIP nat module
    sed -i -e 's/nf_nat_sip//g' /etc/modules.d/nf-nathelper-extra
    rmmod nf_nat_sip 2>/dev/null
    # add support for helpers over ipv6 (SW-2714)
    insmod /lib/modules/`uname -r`/kernel/net/ipv6/netfilter/ip6table_raw.ko
}
