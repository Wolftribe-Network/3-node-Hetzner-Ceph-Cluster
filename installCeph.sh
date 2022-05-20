#!/bin/bash
echo "This script is going to install everything needed and than reboot the system"
sleep 3
cd
apt update && apt upgrade -y
if [ $HOSTNAME = "CEPH01" ]; then
    curl --silent --remote-name --location https://github.com/ceph/ceph/raw/pacific/src/cephadm/cephadm
    chmod +x cephadm
    ./cephadm add-repo --release pacific
    echo "deb https://download.ceph.com/debian-pacific/ focal main" > /etc/apt/sources.list.d/ceph.list
    apt update
    /root/cephadm install
    echo "  vlans:" >> /etc/netplan/01-netcfg.yaml
    echo "    vlan.4000:" >> /etc/netplan/01-netcfg.yaml
    echo "      id: 4000" >> /etc/netplan/01-netcfg.yaml
    echo "      link: enp10s0" >> /etc/netplan/01-netcfg.yaml
    echo "      addresses: [172.16.0.1/24]" >> /etc/netplan/01-netcfg.yaml
    rm /root/cephadm
fi
if [ $HOSTNAME = "CEPH02" ]; then
    apt-get install ca-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    echo "  vlans:" >> /etc/netplan/01-netcfg.yaml
    echo "    vlan.4000:" >> /etc/netplan/01-netcfg.yaml
    echo "      id: 4000" >> /etc/netplan/01-netcfg.yaml
    echo "      link: enp10s0" >> /etc/netplan/01-netcfg.yaml
    echo "      addresses: [172.16.0.2/24]" >> /etc/netplan/01-netcfg.yaml
fi
if [ $HOSTNAME = "CEPH03" ]; then
apt-get install ca-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
echo "  vlans:" >> /etc/netplan/01-netcfg.yaml
    echo "    vlan.4000:" >> /etc/netplan/01-netcfg.yaml
    echo "      id: 4000" >> /etc/netplan/01-netcfg.yaml
    echo "      link: enp8s0" >> /etc/netplan/01-netcfg.yaml
    echo "      addresses: [172.16.0.3/24]" >> /etc/netplan/01-netcfg.yaml
fi
echo "172.16.0.1 CEPH01" >> /etc/hosts
echo "172.16.0.2 CEPH02" >> /etc/hosts
echo "172.16.0.3 CEPH03" >> /etc/hosts
reboot
