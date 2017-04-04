#!/bin/sh

chown -R clamav:clamav /var/lib/clamav
exec /usr/sbin/clamd -c /etc/clamav/clamd.conf
