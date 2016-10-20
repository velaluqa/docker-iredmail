#!/bin/sh

ulimit -n 1024

chown -R openldap:openldap /var/lib/ldap
exec /usr/sbin/slapd -h "ldap:/// ldapi:///" -u openldap -g openldap -f /etc/ldap/slapd.conf -d 0
