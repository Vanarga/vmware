#!/bin/bash

if [ $# -lt 6 ]; then
    echo "Command Syntax: ./config <AD username> <AD password> <fqdn of host> <IP of host> <netmask> <IP of Gateway>"
    exit 1
fi

USERNAME=$1
USERPASS=$2
FQDN=$3
IP=$4
NETMASK=$5
GATEWAY=$6

MSCA='< Enter fqdn of Microsoft Certificate Authority'
VCSA='< Enter fqdn of vCenter>'
DNS='< IP of DNS Server >'
NTP='< NTP Server >'
HOSTNDOMAIN=`echo $FQDN | cut -d "." -f 1,3,4`
DOMAINNAME=`echo $FQDN | cut -d "." -f 3,4`
HOSTNAME=`echo $FQDN | cut -d "." -f 1`
TIMEZONE='< Enter valid NTP timezone string >'
COUNTRY='< Enter Country Name for Cert >'
STATEPROV='< Enter State or Province for Cert >'
LOCALITY='< Enter Locality for Cert >'
COMPANY='< Enter Organization Name for Cert >'
OUNAME='< Enter OU Name for Cert >'

# Set the hostname
hostnamectl set-hostname $FQDN
# Check the hostname
hostnamectl status

# Set static networking for host.
echo "
[Match]
Name=eth0

[Network]
Address=${IP}/${NETMASK}
Gateway=${GATEWAY}
DNS=${DNS}
Domains=${DOMAINNAME}
NTP=${NTP}
LinkLocalAddressing=no
IPv6AcceptRA=no" > /etc/systemd/network/10-static-en.network
# Change permissions on the interface config file.
chmod 644 /etc/systemd/network/10-static-en.network
# Restart the network services.
systemctl restart systemd-networkd.service
systemctl status systemd-networkd.service

# Allow ping to/from the host.
iptables -A OUTPUT -p icmp -j ACCEPT
iptables -A INPUT  -p icmp  -j ACCEPT

# Restart the SSH Service.
systemctl restart sshd
systemctl status sshd

# Set the time server for ntp
sed -i 's/#NTP=/NTP='"{$NTP}"'/g' /etc/systemd/timesyncd.conf
cat /etc/systemd/timesyncd.conf
# List the time zones. we need Asia/Hong_Kong and Europe/London
#timedatectl list-timezones
timedatectl set-timezone $TIMEZONE
# Enable ntp.
timedatectl set-ntp true
# Restart ntp service.
systemctl restart systemd-timesyncd.service
# Check ntp status.
systemctl status systemd-timesyncd -l

echo "<------ Start with tdnf installs. ------>"

# Install iputils
tdnf -y install iputils
# Install net-tools
tdnf -y install net-tools
# Install bindutils
tdnf -y install bindutils
# Install sshpass
tdnf -y install sshpass
# Install wget
tdnf -y install wget
# Install wget
tdnf -y install unzip

echo "<------ Done with tdnf installs. ------>"

echo "<------ Start with docker configs. ------>"
# Start docker.
systemctl start docker
# Enable docker for autostart on reboot.
systemctl enable docker
systemctl status docker

# Create the following folders.
mkdir /root/docker
mkdir /root/docker/nginx
mkdir /root/docker/nginx/ssl

# Create the Certificate CSR config file.
echo "
[ req ]
default_md = sha512
default_bits = 2048
default_keyfile = rui.key
distinguished_name = req_distinguished_name
encrypt_key = no
prompt = no
string_mask = nombstr
req_extensions = v3_req

[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment, nonRepudiation
subjectAltName = IP:${IP},DNS:${FQDN},DNS:${HOSTNDOMAIN},DNS:${HOSTNAME}

[ req_distinguished_name ]
countryName = ${COUNTRY}
stateOrProvinceName = ${STATEPROV}
localityName = ${LOCALITY}
0.organizationName = ${COMPANY}
organizationalUnitName = ${OUNAME}
commonName = ${FQDN}" > /root/docker/nginx/ssl/$HOSTNAME.conf

# Create the CSR.
openssl req -new -newkey rsa:2048 -nodes -keyout /root/docker/nginx/ssl/$HOSTNAME.key -out /root/docker/nginx/ssl/$HOSTNAME.csr -config /root/docker/nginx/ssl/$HOSTNAME.conf

# Reformat the csr to a text stream.
# Remove next line/carriage return charcaters.
CERT=`cat /root/docker/nginx/ssl/$HOSTNAME.csr | tr -d '\n\r'`
# replace plus with %2B
CERT=`echo $CERT | sed 's/+/%2B/g'`
# replace spaces with plus.
CERT=`echo $CERT | tr -s ' ' '+'`
# Set certificate template to use.
CERTATTRIB='CertificateTemplate:vSphere6.0%0D%0A'

# Display Requesting Certificate.
echo -e "\e[32mRequesting cert...\e[0m"

# Create Certificate Request Link.
OUTPUTLINK=`curl -k -u "${USERNAME}":$USERPASS --ntlm \
"https://${MSCA}/certsrv/certfnsh.asp" \
-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
-H 'Accept-Encoding: gzip, deflate' \
-H 'Accept-Language: en-US,en;q=0.5' \
-H 'Connection: keep-alive' \
-H "Host: ${MSCA}" \
-H "Referer: https://${MSCA}/certsrv/certrqxt.asp" \
-H 'User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; Trident/7.0; rv:11.0) like Gecko' \
-H 'Content-Type: application/x-www-form-urlencoded' \
--data "Mode=newreq&CertRequest=${CERT}&CertAttrib=${CERTATTRIB}&TargetStoreFlags=0&SaveCert=yes&ThumbPrint=" | grep -A 1 'function handleGetCert() {' | tail -n 1 | cut -d '"' -f 2`
CERTLINK="https://${MSCA}/certsrv/${OUTPUTLINK}"

# Display Retrieving Certificate.
echo -e "\e[32mRetrieving cert: ${CERTLINK}\e[0m"
curl -k -u "${USERNAME}":${USERPASS} --ntlm $CERTLINK \
-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
-H 'Accept-Encoding: gzip, deflate' \
-H 'Accept-Language: en-US,en;q=0.5' \
-H 'Connection: keep-alive' \
-H "Host: ${MSCA}" \
-H "Referer: https://${MSCA}/certsrv/certrqxt.asp" \
-H 'User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; Trident/7.0; rv:11.0) like Gecko' \
-H 'Content-Type: application/x-www-form-urlencoded' > /root/docker/nginx/ssl/$HOSTNAME.crt

URL="https://${MSCA}/certsrv/certnew.p7b?ReqID=CACert&Renewal=-1&Enc=DER"

# Download the chain certificate.
curl -k -u "${USERNAME}":$USERPASS --ntlm $URL > /root/docker/nginx/ssl/chain.p7b
# Covert the PKCS#7 (pb7) Certificate to PEM.
openssl pkcs7 -inform PEM -outform PEM -in /root/docker/nginx/ssl/chain.p7b -print_certs > /root/docker/nginx/ssl/chain.crt

# Separate the Chain Certificate in to the Root, and both intermediate Certificates.
# Remove the subject line, the issuer line, and any blank lines.
sed -i -e '/^subject/ d' -e '/^issuer/ d' -e '/^\s*$/d' /root/docker/nginx/ssl/chain.crt
# Split the chain.crt file into it's three component cert files.
awk 'BEGIN {c=0;} /BEGIN CERT/{c++} { print > "/root/docker/nginx/ssl/roots." c ".pem"}' < /root/docker/nginx/ssl/chain.crt
# Rename the root files to root64, interm65, and inter264
mv /root/docker/nginx/ssl/roots.1.pem /root/docker/nginx/ssl/interm264.crt
mv /root/docker/nginx/ssl/roots.2.pem /root/docker/nginx/ssl/interm64.crt
mv /root/docker/nginx/ssl/roots.3.pem /root/docker/nginx/ssl/root64.crt

# Verify the chain.crt certificate.
openssl verify -CAfile /root/docker/nginx/ssl/chain.crt /root/docker/nginx/ssl/$HOSTNAME.crt
openssl x509 -in /root/docker/nginx/ssl/$HOSTNAME.crt -text -noout

# Create the nginx config file.
echo "
user www-data;
worker_processes 4;
pid /var/run/nginx.pid;

events {
        worker_connections 1024;
}

http {
        sendfile on;
        proxy_buffering on;
        proxy_cache_valid 200 1d;
        proxy_cache_path /var/www/cache levels=1:2 keys_zone=my-cache:15m max_size=1g inactive=24h;
        proxy_temp_path /var/www/cache/tmp;

        server { listen 80;

                location / {
                        proxy_pass https://\${AUTO_DEPLOY};
                        keepalive_timeout 65;
                        tcp_nodelay on;
                        proxy_cache my-cache;
                        proxy_redirect off;
                        proxy_set_header Host \$host;
                        proxy_set_header X-Real-IP \$remote_addr;
                        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                        proxy_set_header X-Forwarded-Host \$server_name;
                        proxy_ssl_certificate /etc/ssl/certs/cert.crt;
                        proxy_ssl_certificate_key /etc/ssl/certs/cert.key;
                        proxy_ssl_trusted_certificate /etc/ssl/certs/chain.crt;
                        proxy_ssl_server_name on;
                        proxy_ssl_verify on;
                        proxy_ssl_verify_depth 2;
                        proxy_ssl_protocols TLSv1.2;
                        proxy_ssl_session_reuse on;
                }
        }
}
daemon off;" > /root/docker/nginx/nginx.conf.template.simple

# Create the nginx dockerfile.
echo "
FROM nginx
COPY nginx.conf.template.simple /etc/nginx/nginx.conf.template
COPY ./ssl/${HOSTNAME}.crt   /etc/ssl/certs/cert.crt
COPY ./ssl/${HOSTNAME}.key   /etc/ssl/certs/cert.key
COPY ./ssl/chain.crt        /etc/ssl/certs/chain.crt

RUN mkdir -p /var/www/cache
CMD envsubst '\$\$AUTO_DEPLOY' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf && nginx" > /root/docker/nginx/dockerfile

# Build the nginx docker container.
docker build -t hcm/auto_deploy_nginx /root/docker/nginx/
# Run the nginx docker container.
docker run --name reverse_proxy --restart=always -it -p 5100:80 -d -e AUTO_DEPLOY=$VCSA:6501 hcm/auto_deploy_nginx
# Test nginx container functionality.
curl http://$IP:5100/vmw/rbd/tramp

# Create the folder structure for tftp.
mkdir /root/docker/tftpd
mkdir /root/docker/tftpd/tramp

wget "https://${VCSA}:6502/vmw/rbd/deploy-tftp.zip" --no-check-certificate

unzip deploy-tftp.zip -d /root/docker/tftpd/tramp/

# Create the tftp dockerfile.
echo "
FROM centos:latest

RUN yum install -y tftp-server syslinux wget
RUN mkdir /srv/tftpboot
ADD tramp /srv/tftpboot

ENV LISTEN_IP=0.0.0.0
ENV LISTEN_PORT=69

ENTRYPOINT in.tftpd -s /srv/tftpboot -4 -L -a \$LISTEN_IP:\$LISTEN_PORT" > /root/docker/tftpd/dockerfile

# Build the tftp docker container.
docker build -t hcm/tftpd /root/docker/tftpd/
# Run the tftp docker container.
docker run --name tftp -d -p 69:69/udp hcm/tftpd
# Stop the tftp docker container and remove it.
docker rm -f tftp

echo "<------ Done with docker configs. ------>"

# Create the tftp server service for autostart.
echo "
[Unit]
Description=TFTP Server
After=docker.service
Requires=docker.service

[Service]
ExecStart=/usr/bin/docker run --name tftp --restart unless-stopped -p 69:69/udp hcm/tftpd
ExecStop=/usr/bin/docker rm -f tftp
Restart=always

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/tftp.service

# Enable the tftp service autostart.
systemctl enable tftp.service
systemctl start tftp.service
systemctl status tftp.service