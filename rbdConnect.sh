#!/bin/bash
echo "Make sure that the vLan is properly set up through netplan before running this script, use the CEPH01 or CEPH02 files for reference, this server's address would be 172.16.0.4."
echo ""
echo "The admin keyring should also be in /etc/ceph as well, this script will be looking for ceph.client.admin.keyring"
ls /etc/ceph
echo "it should be above here, if not, control + C and put it there before allowing this script to continue"
sleep 5
apt update
apt install ceph ceph-common
wget https://raw.github.com/ceph/ceph/a4ddf704868832e119d7949e96fe35ab1920f06a/src/init-rbdmap -O /etc/init.d/rbdmap
chmod +x /etc/init.d/rbdmap
update-rc.d rbdmap defaults
echo "DATA/data       id=admin,keyring=/etc/ceph/ceph.client.admin.keyring" >> /etc/ceph/rbdmap
systemctl start rbdmap
echo "/dev/rbd/DATA/data /mnt/data  xfs defaults,_netdev        0       0" >> /etc/fstab
mount -a
