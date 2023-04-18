#!/bin/sh

# for OPENWRT_DEVICE_PRODUCT and VERSION
. /etc/os-release

filename=$1
upload=`basename $filename`
mac=`fw_printenv -n ethaddr | tr '[A-F]' '[a-f]'`

if [ -z $mac ] ; then
	mac=`fw_printenv -n mfg_base_mac | tr '[A-F]' '[a-f]'`
fi

if [ -z $mac ] ; then
	mac="unknown"
fi

ping -q -c 1 s3.amazonaws.com > /dev/null 2>&1
while [ $? != 0 ] ; do
	sleep 10
	ping -q -c 1 s3.amazonaws.com > /dev/null 2>&1
done

curl -s --header "x-amz-acl: bucket-owner-full-control" -T $filename -X PUT \
https://s3.amazonaws.com/crash-reports.minim.co/$OPENWRT_DEVICE_PRODUCT/$VERSION/$mac/$upload
