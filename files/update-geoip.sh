#!/bin/sh

PATH="/bin:/usr/bin:/usr/local/bin"

cd /var/db/geoip
wget -q https://the-grid.xyz/geoip/GeoLite2-City.mmdb
wget -q https://the-grid.xyz/geoip/GeoLite2-Country.mmdb
