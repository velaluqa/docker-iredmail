FROM phusion/baseimage
MAINTAINER velaluqa GmbH <info@velalu.qa>

ENV DEBIAN_FRONTEND noninteractive
RUN echo "APT::Install-Recommends 0;" >> /etc/apt/apt.conf.d/01-no-recommends \
    && echo "APT::Install-Suggests 0;" >> /etc/apt/apt.conf.d/01-no-recommends

RUN apt-get -q update \
    && apt-get install -y -q \
      apt-utils \
    && apt-get install -y -q \
      wget \
      bzip2 \
      dovecot-core \
      dovecot-imapd \
      dovecot-ldap \
      dovecot-lmtpd \
      dovecot-managesieved \
      dovecot-mysql \
      dovecot-pop3d \
      dovecot-sieve \
      iptables \
      augeas-tools

ENV IREDMAIL_VERSION 0.9.2
ARG HOSTNAME=mail
ARG DOMAIN

RUN echo $DOMAIN > /etc/mailname \
    && echo $HOSTNAME > /opt/hostname

RUN mv /bin/uname /bin/uname_
COPY ./uname /bin/uname

RUN mv /bin/hostname /bin/hostname_
COPY ./hostname /bin/hostname

WORKDIR /opt/iredmail

RUN wget -O - https://bitbucket.org/zhb/iredmail/downloads/iRedMail-"${IREDMAIL_VERSION}".tar.bz2 | \
    tar xvj --strip-components=1

COPY ./config ./

RUN sed s/$(hostname_)/$(cat /opt/hostname | xargs echo -n).$(cat /etc/mailname | xargs echo -n)/ /etc/hosts > /tmp/hosts_ \
    && cat /tmp/hosts_ > /etc/hosts \
    && rm /tmp/hosts_ \
    && echo $HOSTNAME > /etc/hostname \
    && IREDMAIL_DEBUG='NO' \
      CHECK_NEW_IREDMAIL='NO' \
      AUTO_USE_EXISTING_CONFIG_FILE=y \
      AUTO_INSTALL_WITHOUT_CONFIRM=y \
      AUTO_CLEANUP_REMOVE_SENDMAIL=y \
      AUTO_CLEANUP_REMOVE_MOD_PYTHON=y \
      AUTO_CLEANUP_REPLACE_FIREWALL_RULES=n \
      AUTO_CLEANUP_RESTART_IPTABLES=n \
      AUTO_CLEANUP_REPLACE_MYSQL_CONFIG=y \
      AUTO_CLEANUP_RESTART_POSTFIX=n \
      bash iRedMail.sh \
    ; service nginx stop \
    ; service clamav-freshclam stop \
    ; service clamav-daemon stop \
    ; service amavis stop \
    ; pkill -sigterm master \
    ; service php5-fpm stop \
    ; service mysql stop \
    ; pkill -sigterm slapd \
    ; sleep 30 \
    ; ps aux

WORKDIR /opt

RUN mv /opt/iredmail/iRedMail.tips /opt \
    && rm -rf /opt/iredmail /root/.bash_history \
    && mv -f /bin/uname_ /bin/uname \
    && mv -f /bin/hostname_ /bin/hostname

# Disable SSH and SSH fail2ban
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh \
    && echo set /augeas/load/Puppet/incl[1] /etc/fail2ban/jail.local > /tmp/augscript \
    && echo load >> /tmp/augscript \
    && echo set /files/etc/fail2ban/jail.local/sshd/enabled false >> /tmp/augscript \
    && echo set /files/etc/fail2ban/jail.local/sshd-ddos/enabled false >> /tmp/augscript \
    && echo save >> /tmp/augscript \
    && augtool -L -f /tmp/augscript \
    && rm /tmp/augscript

# Disable backups
RUN sed -i '/\/var\/vmail\/backup/d' /var/spool/cron/crontabs/root

RUN sed -i '/init.d/c /etc/init.d/iredapd stop' /etc/logrotate.d/iredapd

# Use one DKIM key for all domains
RUN sed -i s/^dkim_key\(\"$DOMAIN\"/dkim_key\(\"*\"/ /etc/amavis/conf.d/50-user

# Amend config files for runsv compatibility
RUN sed -i '/^Foreground /c Foreground true' /etc/clamav/clamd.conf \
    && sed -i '/init.d/c pkill -sighup clamd' /etc/logrotate.d/clamav-daemon \
    && sed -i '/^Foreground /c Foreground true' /etc/clamav/freshclam.conf

# Copy runsv files
ADD services/iredapd.sh /etc/service/iredapd/run
ADD services/slapd.sh /etc/service/slapd/run
ADD services/mysql.sh /etc/service/mysql/run
ADD services/nginx.sh /etc/service/nginx/run
ADD services/dovecot.sh /etc/service/dovecot/run
ADD services/php5-fpm.sh /etc/service/php5-fpm/run
ADD services/postfix.sh /etc/service/postfix/run
ADD services/clamav-daemon.sh /etc/service/clamav-daemon/run
ADD services/amavis.sh /etc/service/amavis/run
ADD services/clamav-freshclam.sh /etc/service/clamav-freshclam/run
ADD services/uwsgi-iredadmin.sh /etc/service/uwsgi-iredadmin/run
ADD services/fail2ban.sh /etc/service/fail2ban/run
ADD services/postfix-cluebringer.sh /etc/service/postfix-cluebringer/run

# Purge some packets and save disk space
RUN apt-get purge -y -q dialog apt-utils augeas-tools \
    && apt-get autoremove -y -q \
    && apt-get clean -y -q \
    && rm -rf /var/lib/apt/lists/*
