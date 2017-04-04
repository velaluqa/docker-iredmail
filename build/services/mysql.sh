#!/bin/sh

chown -R mysql:mysql /var/lib/mysql

env HOME=/etc/mysql
umask 007

exec /usr/sbin/mysqld
