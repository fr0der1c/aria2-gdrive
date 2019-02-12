#!/bin/bash
/usr/sbin/service aria2 stop
list=`wget -qO- https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_best.txt|awk NF|sed ":a;N;s/\n/,/g;ta"`
if [[ -z "`grep "bt-tracker" /root/.aria2/aria2.conf`" ]]; then
    sed -i '$a bt-tracker='${list} /root/.aria2/aria2.conf
    echo "Add bt-trackers to aria2.conf"
else
    sed -i "s@bt-tracker.*@bt-tracker=$list@g" /root/.aria2/aria2.conf
    echo "Update bt-trackers in aria2.conf"
fi