#!/bin/sh /etc/rc.common
# Copyright (C) 2022 Minim Inc

START=99
STOP=99

boot() {
    # disable SIP nat module
    sed -i -e 's/nf_nat_sip//g' /etc/modules.d/nf-nathelper-extra
    rmmod nf_nat_sip 2>/dev/null
}
