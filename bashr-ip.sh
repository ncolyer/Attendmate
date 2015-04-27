#!/bin/bash
today=`date +%Y-%m-%d.%H:%M:%S`

echo -e "Backing up original configurations...\n"
cp /etc/resolv.conf /etc/resolv.conf.$today.bak

# Networking Section
echo -e "This auto-provisioning script will allow for the configuration of this new VMs network parameters.\n"
read -p "Is this network DHCP? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
        # DHCP
        echo -ne "\nEnter the device identifer (ex. eth0) and press [ENTER]: "
        read ethernet
		cp /etc/sysconfig/network-scripts/ifcfg-$ethernet /etc/sysconfig/network-scripts/ifcfg-$ethernet.$today.bak
        dhclient $ethernet
else
        # Not DHCP
        echo -n "Enter the device identifer (ex. eth0) and press [ENTER]: "
        read ethernet
        echo -n "Enter the broadcast address (ex. 10.0.2.255) and press [ENTER]: "
        read broadcast
        echo -n "Enter the device ip address (ex. 10.0.2.50) and press [ENTER]: "
        read ipaddress
        echo -n "Enter the device netmast (ex. 255.255.255.0) and press [ENTER]: "
        read netmask
        echo -n "Enter the device network (ex. 10.0.2.0) and press [ENTER]: "
        read network

		cp /etc/sysconfig/network-scripts/ifcfg-$ethernet /etc/sysconfig/network-scripts/ifcfg-$ethernet.$today.bak
        echo "# Generated via auto-provision script by ncolyer@gmail.com" > /etc/sysconfig/network-scripts/ifcfg-$ethernet
        echo "DEVICE=$ethernet" >> /etc/sysconfig/network-scripts/ifcfg-$ethernet
        echo "BOOTPROTO=static" >> /etc/sysconfig/network-scripts/ifcfg-$ethernet
        echo "BROADCAST=$broadcast">> /etc/sysconfig/network-scripts/ifcfg-$ethernet
        echo "IPADDRESS=$ipaddress">> /etc/sysconfig/network-scripts/ifcfg-$ethernet
        echo "NETMASK=$netmask">> /etc/sysconfig/network-scripts/ifcfg-$ethernet
        echo "NETWORK=$network">> /etc/sysconfig/network-scripts/ifcfg-$ethernet
        echo "ONBOOT=yes">> /etc/sysconfig/network-scripts/ifcfg-$ethernet
fi

# DNS Section
echo -n "Enter the search domain (ex. host.local) and press [ENTER]: "
read searchDomain
echo -n "Enter the primary nameserver (ex. 10.0.2.15) and press [ENTER]: "
read primaryDns
echo -n "Enter the secondary nameserver (ex. 10.0.2.16) and press [ENTER]: "
read secondaryDns
echo "# Generated via auto-provision script by ncolyer@gmail.com" > /etc/resolv.conf
echo "search $searchDomain" >> /etc/resolv.conf
echo "nameserver $primaryDns" >> /etc/resolv.conf
echo "nameserver $secondaryDns" >> /etc/resolv.conf

# Hostname Settings
echo -n "Enter the hostname (ex. server01.local) and press [ENTER]: "
read hostname
echo "# Generated via auto-provision script by ncolyer@gmail.com" > /etc/sysconfig/network
echo "NETWORKING=yes" >> /etc/sysconfig/network
echo "NETWORKING_IPV6=yes" >> /etc/sysconfig/network
echo "HOSTNAME=$hostname" >> /etc/sysconfig/network

# Restarting services...
service network restart
service hostname restart

echo "\nScript completed."
