#!/bin/sh
set -e

# watch settings
apache2ctl -S

/usr/sbin/apachectl -D FOREGROUND