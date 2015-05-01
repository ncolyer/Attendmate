#!/bin/bash
today=`date +%Y-%m-%d.%H:%M:%S`

echo -ne "\n\n\n\033[0;32mThis auto-provisioning script will allow for the configuration of this device's network and system configuration parameters.\n\n\n\033[0m"
sleep 3

# Set XEN vm console password?
read -p "Would you like to change the default xvnc console password? (Existing password is password) " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
cp /root/.vnc/passwd /root/.vnc/.$today.bak
echo -ne "\nBelow you will be prompted to specify a password for the vm console window [ex. password]:\n\n"
vncpasswd
fi

# Set root password?
echo
read -p "Would you like to change the root password? (Existing password is password) " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
cp /etc/shadow /etc/shadow./$today.bak
echo -ne "\nBelow you will be prompted to specify a new root password [ex. password]:\n\n"
passwd
fi


# Networking Section
echo 
read -p "Is this network DHCP? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
	# DHCP
	echo -ne "\nEnter the device identifer (ex. eth0) and press [ENTER]: "
	read ethernet
	if [ -z "$ethernet" ]; then
		ethernet="eth0"
	fi
	dhclient $ethernet
	cp /etc/sysconfig/network-scripts/ifcfg-$ethernet /etc/sysconfig/network-scripts/ifcfg-$ethernet.$today.bak
else
	# Not DHCP
	echo -ne "\nEnter the device identifer (ex. eth0) and press [ENTER]: "
	read ethernet
	echo -n "Enter the device ip address (ex. 10.0.2.50) and press [ENTER]: "
	read ipaddress
	echo -n "Enter the device netmast (ex. 255.255.255.0) and press [ENTER]: "
	read netmask
	echo -n "Enter the device network (ex. 10.0.2.0) and press [ENTER]: "
	read network

	if [ -z "$ipaddress"] || ["$netmask"]; then	
		echo -ne "\n\n\n\n\033[0;31mMissing required parameters. Please run the setup.sh shell script again to re-start provisioning.\033[0m"
		echo -ne "\n\n\nExiting...\n\n"
		sleep 2
		exit
	fi

	cp /etc/sysconfig/network-scripts/ifcfg-$ethernet /etc/sysconfig/network-scripts/ifcfg-$ethernet.$today.bak
	echo "# Generated via auto-provision script by ncolyer@gmail.com" > /etc/sysconfig/network-scripts/ifcfg-$ethernet
	if [ -z "$ethernet" ]; then
		echo "DEVICE=eth0" >> /etc/sysconfig/network-scripts/ifcfg-$ethernet
	else
		echo "DEVICE=$ethernet" >> /etc/sysconfig/network-scripts/ifcfg-$ethernet
	fi
	echo "BOOTPROTO=static" >> /etc/sysconfig/network-scripts/ifcfg-$ethernet
	echo "IPADDRESS=$ipaddress">> /etc/sysconfig/network-scripts/ifcfg-$ethernet
	echo "NETMASK=$netmask">> /etc/sysconfig/network-scripts/ifcfg-$ethernet
	echo "NETWORK=$network">> /etc/sysconfig/network-scripts/ifcfg-$ethernet
	echo "ONBOOT=yes">> /etc/sysconfig/network-scripts/ifcfg-$ethernet

	# DNS Section
	echo -n "Enter the search domain (ex. yourdomain.local) and press [ENTER]: "
	read searchDomain
	echo -n "Enter the primary nameserver (ex. 10.0.2.15) and press [ENTER]: "
	read primaryDns
	echo -n "Enter the secondary nameserver (ex. 10.0.2.16) and press [ENTER]: "
	read secondaryDns
	cp /etc/resolv.conf /etc/resolv.conf.$today.bak
	echo "# Generated via auto-provision script by ncolyer@gmail.com" > /etc/resolv.conf
	echo "search $searchDomain" >> /etc/resolv.conf
	echo "nameserver $primaryDns" >> /etc/resolv.conf
	echo "nameserver $secondaryDns" >> /etc/resolv.conf
fi

# Hostname Settings
echo -n "Enter the hostname (ex. server01.local) and press [ENTER]: "
read hostname
echo "# Generated via auto-provision script by ncolyer@gmail.com" > /etc/sysconfig/network
echo "NETWORKING=yes" >> /etc/sysconfig/network
echo "NETWORKING_IPV6=yes" >> /etc/sysconfig/network
echo "HOSTNAME=$hostname" >> /etc/sysconfig/network

echo -ne "\nScript completed. Rebooting..."
shutdown -r 10
