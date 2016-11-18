# docker-iredmail

This is an all-in-one container for [iRedMail](http://www.iredmail.org) with OpenLDAP backend. It
uses Phusion's
[baseimage-docker](https://github.com/phusion/baseimage-docker) to
make sure all processes shut down correctly.

Backups are disabled, because I snapshot my Docker volumes with ZFS
regularily. To reenable them, just comment out one line from the
Dockerfile.

**If you like or use this project, please star it ★ on Github and
  Docker Hub.**

## Usage

Replace ```{variables}``` properly.

1. Generate your iRedMail config file using the @configure@ script.
   Amend passwords and LDAP nodes as you wish afterwards.
2. Build your image with ```docker build -t iredmail:0.9.5-1
   --build-arg DOMAIN={first domain} build/```. Note that this step
   will take some time.
3. Create an intermediate container with ```docker create
   --name=iredmail iredmail:0.9.5-1```.
4. Extract some folders from the intermediate container and fix the
   owners:

   ```
   docker cp iredmail:/var/lib/ldap/{dn2dnsname} slapd-data
   docker cp iredmail:/var/vmail/vmail1 mails
   docker cp iredmail:/var/lib/dkim mail-domain-keys
   docker cp iredmail:/var/lib/mysql mail-mysql-data
   docker cp iredmail:/var/lib/clamav mail-clamav-data
   chown -R 107:111 slapd-data
   chown -R 2000:2000 mails
   chown -R 110:115 mail-domain-keys
   chown -R 105:109 mail-mysql-data
   chown -R 109:114 mail-clamav-data
   ```
5. Remove the intermediate container with ```docker rm iredadmin```.
6. Start your permanent container with volumes properly attached. You
   will need a couple of docker arguments. Here's an example
   docker-compose file:

   ```
   mail:
     image: iredmail
     hostname: mail
     domainname: {first domain}
     ports:
       - "25:25"
       - "587:587"
       - "993:993"
     volumes:
       - /path/to/slapd-data:/var/lib/ldap/{dn2dnsname}
       - /path/to/mails:/var/vmail/vmail1
       - /path/to/mail-domain-keys:/var/lib/dkim
       - /path/to/mail-mysql-data:/var/lib/mysql
       - /path/to/mail-clamav-data:/var/lib/clamav
       - /path/to/ssl.key:/etc/ssl/private/iRedMail.key:ro # user: root, group: root, rights: 644
       - /path/to/ssl.crt:/etc/ssl/certs/iRedMail.crt:ro # user: root, group: root, rights: 644
     cap_add:
       - SYS_PTRACE # for UWSGI-iRedAdmin runsv script
       - NET_ADMIN
   ```

## Contribution

Pull requests very welcome! :-)
