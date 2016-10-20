#!/bin/sh

chown -R amavis:amavis /var/lib/dkim
exec /usr/sbin/amavisd-new foreground
