#!/usr/bin/env bash

PATH="/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin"

puppet agent -t
shutdown -r now
