#!/bin/bash -e

# Script must be run as root

echo "Stopping and disabling dnsmasq.service ..."
systemctl stop dnsmasq.service > /dev/null 2>&1
systemctl disable dnsmasq.service > /dev/null 2>&1

echo "Stopping and disabling hostapd.service ..."
systemctl stop hostapd.service > /dev/null 2>&1
systemctl disable hostapd.service > /dev/null 2>&1

echo "Configuring /etc/network/interfaces ..."
if [ -e interfaces_restore ]
then
    cp interfaces_restore /etc/network/interfaces
else
    echo "Could not find file called interfaces_restore"
    exit 1
fi

echo "Removing packages dnsmasq hostapd iptables-persistent ..."

apt remove -y dnsmasq hostapd iptables-persistent > /dev/null 2>&1

echo "Restoring iptables to default ..."
if [ -e /etc/iptables/rules.v4 ]
then
    rm /etc/iptables/rules.v4
else
    echo "No /etc/iptables/rules.v4 found"
fi

echo "Starting and enabling dhcpd.service ..."
systemctl start dhcpcd.service > /dev/null 2>&1
systemctl enable dhcpcd.service > /dev/null 2>&1

echo "You should reboot now .."

exit 0
