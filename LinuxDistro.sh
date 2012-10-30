#!/bin/bash




KERNEL=`uname -s`
KERNELRELEASE=`uname -r`


if [ "$KERNEL" = "Linux" ]
then
	if [ -f /etc/redhat-release ]
	then
		LINUXDISTRO=RedHat

	elif [ -f cat /etc/centos-release ]
	then
		LINUXDISTRO=CentOS

	elif [ -f /etc/fedora-release ]
	then
		LINUXDISTRO=Fedora

	elif [ -f /etc/lsb-release ]
	then
		LINUXDISTRO=Ubuntu

	elif [ -f  /etc/debian_version ]
	then
		LINUXDISTRO=Debian

	elif [ -f /etc/SUSE-release ]
	then
		LINUXDISTRO=SUSE

	elif [ -f /etc/mandrake-release ]
	then
		LINUXDISTRO=Mandrake

fi
