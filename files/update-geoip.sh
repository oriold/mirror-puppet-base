#!/bin/sh

PATH="/bin:/usr/bin:/usr/local/bin"

cd /var/db/geoip
wget -q https://cnxnet.be/geoip/GeoLite2-City.mmdb
wget -q https://cnxnet.be/geoip/GeoLite2-Country.mmdb
rm *.mmdb.*
