#!/bin/bash -e

# Script must be run as root

echo "Installing required packages dnsmasq hostapd iptables-persistent ..."

apt install -y dnsmasq hostapd iptables-persistent > /dev/null 2>&1

echo "Configuring /etc/network/interfaces ..."
cp /etc/network/interfaces /etc/network/interfaces.backup

if [ -e interfaces_router ]
then
    cp interfaces_router /etc/network/interfaces
else
    echo "Could not find file called interfaces_router"
    exit 1
fi

echo "Configuring hostapd ..."
if [ -e hostapd_router ]
then
   cp hostapd_router /etc/hostapd/hostapd.conf
else
   echo "Could not find required file called hostapd_router"
   exit 1
fi

echo "Configuring dnsmasq ..."
cp /etc/dnsmasq.conf /ect/dnsmasq.conf.backup

if [ -e dnsmasq_router ]
then
   cp dnsmasq_router /etc/dnsmasq.conf
else
   echo "Could not find required file called dnsmasq_router"
   exit 1
fi

echo "Enabling ipv4 fowarding ..."
if [ -e /etc/sysctl.conf ]
then
    echo "net.ipv4.ip_forward=1" > /etc/sysctl.conf
else
    echo "Something went wrong /etc/sysctl.conf not found"
    exit 1
fi

echo "Setting up iptables between wifi and ethernet network interfaces ..."
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE > /dev/null 2>&1
iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT > /dev/null 2>&1
iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT > /dev/null 2>&1
iptables-save > /etc/iptables/rules.v4

echo "Stopping and disabling dhcpd.service ..."
systemctl stop dhcpcd.service > /dev/null 2>&1
systemctl disable dhcpcd.service > /dev/null 2>&1

echo "Starting and enabling dnsmasq.service ..."
systemctl start dnsmasq.service > /dev/null 2>&1
systemctl enable dnsmasq.service > /dev/null 2>&1

echo "Starting and enabling hostapd.service ..."
systemctl start hostapd.service > /dev/null 2>&1
systemctl enable hostapd.service > /dev/null 2>&1

exit 0
