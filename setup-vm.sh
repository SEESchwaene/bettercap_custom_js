#!/bin/sh

if [ -n "$1" ] && [ "$1" = "install" ]; then

      
        pacman -S python nmap wireshark-qt git base-devel libpcap libusb libnetfilter_queue wget net-tools

        wget -c https://go.dev/dl/go1.18.10.linux-amd64.tar.gz

        tar -xzf go1.18.10.linux-amd64.tar.gz

        go/bin/go install github.com/bettercap/bettercap@latest

        mv /root/go/bin/bettercap /usr/local/bin/

        rm -rf go
        rm go1.18.10.linux-amd64.tar.gz

        bettercap -eval "caplets.update; ui.update; q"
elif [ -n "$1" ] && [ "$1" = "remove" ]; then

        if [ -f "/usr/local/bin/bettercap" ]; then
                rm /usr/local/bin/bettercap
        fi

        if [ -f "/root/bettercap.history" ]; then
                rm /root/bettercap.history
        fi

        if [ -d "/usr/local/share/bettercap" ]; then
                rm -r /usr/local/share/bettercap
        fi
else
        echo "Please specify whether to install the setup ('sudo ./setup.sh install') or remove it ('sudo ./setup.sh remove')."
fi

