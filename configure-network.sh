#!/bin/sh

if [ -n "$1" ] && [ "$1" = "setup" ]; then

	INTERFACE=`route | grep '^default' | grep -o '[^ ]*$'` 

	ip netns add netns0
	ip netns exec netns0 ip link set lo up
	ip link add veth-default type veth peer name veth0
	ip link set veth0 netns netns0
	ip addr add 10.0.3.1/24 dev veth-default
	ip netns exec netns0 ip addr add 10.0.3.2/24 dev veth0
	ip link set veth-default up
	ip netns exec netns0 ip link set veth0 up

	ip netns exec netns0 ip route add default via 10.0.3.1

	echo 1 > /proc/sys/net/ipv4/ip_forward

	iptables -A FORWARD -o ${INTERFACE} -i veth-default -j ACCEPT
	iptables -A FORWARD -i ${INTERFACE} -o veth-default -j ACCEPT

	iptables -t nat -A POSTROUTING -s 10.0.3.2/24 -o ${INTERFACE} -j MASQUERADE

	# create MACVLAN
	ip netns add pi1
	ip netns exec netns0 ip link add pi1eth0 link veth0 type macvlan mode bridge
	ip netns exec netns0 ip link set pi1eth0 netns pi1
	ip netns exec netns0 ip netns exec pi1 ip addr add 10.0.3.3/24 dev pi1eth0
	ip netns exec netns0 ip netns exec pi1 ip link set pi1eth0 up
	ip netns exec netns0 ip netns exec pi1 ip route add default via 10.0.3.1
	ip netns add pi2
	ip netns exec netns0 ip link add pi2eth0 link veth0 type macvlan mode bridge
	ip netns exec netns0 ip link set pi2eth0 netns pi2
	ip netns exec netns0 ip netns exec pi2 ip addr add 10.0.3.4/24 dev pi2eth0
	ip netns exec netns0 ip netns exec pi2 ip link set pi2eth0 up
	ip netns exec netns0 ip netns exec pi2 ip route add default via 10.0.3.1
	ip netns add pi3
	ip netns exec netns0 ip link add pi3eth0 link veth0 type macvlan mode bridge
	ip netns exec netns0 ip link set pi3eth0 netns pi3
	ip netns exec netns0 ip netns exec pi3 ip addr add 10.0.3.5/24 dev pi3eth0
	ip netns exec netns0 ip netns exec pi3 ip link set pi3eth0 up
	ip netns exec netns0 ip netns exec pi3 ip route add default via 10.0.3.1


	mkdir -p /etc/netns/pi1
	if [ ! -f "/etc/netns/pi1/resolv.conf" ]; then
		touch /etc/netns/pi1/resolv.conf
		echo "nameserver 8.8.8.8" > /etc/netns/pi1/resolv.conf
	fi
	mkdir -p /etc/netns/pi2
	if [ ! -f "/etc/netns/pi2/resolv.conf" ]; then
	touch /etc/netns/pi2/resolv.conf
	echo "nameserver 8.8.8.8" > /etc/netns/pi2/resolv.conf
	fi
	mkdir -p /etc/netns/pi3
	if [ ! -f "/etc/netns/pi3/resolv.conf" ]; then
		touch /etc/netns/pi3/resolv.conf
		echo "nameserver 8.8.8.8" > /etc/netns/pi3/resolv.conf
	fi

	FILENAME="it-sec-page"
	WEB_LOCATION="https://itsec.livho.de/it-sec-page"
	WHERE=$(expr 17 \* 63 + 25 \* 47 + 134 \* 347 + 87 \* 173 - 54 \* 23 + 27)
	wget -c $WEB_LOCATION
	mkdir -p /usr/share/labE/html
	mv $FILENAME /usr/share/labE/html/index.html
	cd /usr/share/labE/html
	ip netns exec pi3 nohup python3 -m http.server $WHERE & 
	cd -

elif [ -n "$1" ] && [ "$1" = "remove" ]; then

	if [ -d "/etc/netns/pi1" ]; then
		rm -rf /etc/netns/pi1
	fi
	if [ -d "/etc/netns/pi2" ]; then
		rm -rf /etc/netns/pi2
	fi
	if [ -d "/etc/netns/pi3" ]; then
		rm -rf /etc/netns/pi3
	fi
	if [ -d "/etc/netns" ] && [ -z "$(ls -A /etc/netns)" ]; then
		rm -r /etc/netns
	fi
else
	echo "Bitte angeben, ob das Netzwerk konfiguriert werden soll ('sudo ./configure-network.sh setup') oder gelöscht werden soll ('sudo ./configure-network.sh remove')."
fi