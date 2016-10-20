#!/bin/sh

chown -R vmail:vmail /var/vmail/vmail1
exec /usr/sbin/dovecot -F -c /etc/dovecot/dovecot.conf
