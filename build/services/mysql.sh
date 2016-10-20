#!/bin/sh

chown -R mysql:mysql /var/lib/mysql
exec /usr/sbin/mysqld
