This page details how to set up a vSphere Auto Deploy Reverse Caching Proxy based on the article [Auto Deploy performance boost with reverse proxy caches](https://blogs.vmware.com/vsphere/2017/01/auto-deploy-performance-boost-reverse-proxy-caches.html) by Eric Gray.

This deployment includes setting up a containerized tftpd server, also running on [Photon OS 2.0](https://vmware.github.io/photon/) along side the Nginx server detailed in Eric's web page.

1. Deploy a Photon OS 2.0 vm from [ova](https://github.com/vmware/photon/wiki/Downloading-Photon-OS) use the Hardware version 11 one. Hardware version 13 has an issue.
2. Log in using root/changeme and set the new root password.
3. Set the hostname: hostnamectl set-hostname <hostname>
4. Check the hostname: hostnamectl status
5. Create the file ```/etc/systemd/network/10-static-en.network```
6. Enter the following values and save it.

```
[Match]
Name=eth0
	
[Network]
Address=<IP>/<NETMASK>
Gateway=<GATEWAY IP>
DNS=<DNS Server IP>
Domains=<DOMAIN>
NTP=<ntp server fqdn>
LinkLocalAddressing=no
IPv6AcceptRA=no
```

7. Set the file permissions ```chmod 644 /etc/systemd/network/10-static-en.network```
8. Restart network service ```systemctl restart systemd-networkd.service```
9. Now you should be able to SSH to the server.
10. Get your timezone ```timedatectl list-timezones```
11. Set your timezone ```timedatectl set-timezone America/New_York```
12. Enable NTP ```timedatectl set-ntp true```
13. Reload the system process ```systemctl daemon-reload```
14. Check NTP status ```systemctl status systemd-timesyncd -l```
15. Allow ping from and to your server
```
iptables -A OUTPUT -p icmp -j ACCEPT
iptables -A INPUT  -p icmp  -j ACCEPT
```
16. Update Photon OS packages and install network utils.
```
tdnf -y distro-sync
tdnf -y install iputils
tdnf -y install net-tools
```
17. Start Docker ```systemctl start docker```
18. Enable Docker ```systemctl enable docker```

**Quick Note here: The steps here assume that you already have a working Auto Deploy server.**

Just follow the steps Eric Gray has put together on his [blog](https://blogs.vmware.com/vsphere/2017/01/auto-deploy-performance-boost-reverse-proxy-caches.html).

To install the Auto Deploy reverse proxy, just pull it directly from Eric Gray's [Hub](https://hub.docker.com/r/egray/auto_deploy_nginx/) and start the docker container (Note: Make sure to replace the <VCSA IP> with the IP address of your VCSA Autodeploy server).

1. ```docker pull egray/auto_deploy_nginx```
2. ```docker run --restart=always -p 5100:80 -d -e AUTO_DEPLOY=<VCSA IP>:6501 egray/auto_deploy_nginx```
3. connect to you vcsa via powercli and add the proxy you just deployed ```Add-ProxyServer -Address http://<Photon vm IP address>:5100```

This tftpd server is based on the one from [CSC Labs](https://github.com/csclabs)

1. Create a tftpd folder: ```mkdir /root/tftpd```
2. Copy the [dockerfile](https://github.com/Vanarga/vmware/blob/master/Reverse-Proxy/tftpd/dockerfile) to the folder or just create it and paste the following in it.
```
FROM centos:latest

RUN yum install -y tftp-server syslinux wget
RUN mkdir /srv/tftpboot
ADD tramp /srv/tftpboot

ENV LISTEN_IP=0.0.0.0
ENV LISTEN_PORT=69

ENTRYPOINT in.tftpd -s /srv/tftpboot -4 -L -a $LISTEN_IP:$LISTEN_PORT
```
3. Create the folder for your tramp files: ```mkdir /root/tftpd/tramp```
4. Log in to the vCenter Gui.
5. Select the vCenter object under Hosts and Clusters.
6. Select the Configure Tab.
7. Select Auto Deploy.
8. Click the **Download TFTP Boot Zip**.
9. Unzip the files and scp (or winscp) them to your Photon OS vm.
10. Place them in the **/root/tftpd/tramp** folder.
11. Build the container ```docker build -t vanarga/tftpd . ```
12. Run the container ```docker run -d -p 69:69/udp vanarga/tftpd```
