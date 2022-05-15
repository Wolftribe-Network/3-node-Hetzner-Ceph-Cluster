# 3 Node Ceph Cluster using Hetzner dedicated root servers
the 3 hetzner nodes should be in a vSwitch with eachother, the tag used in this setup is 4000

boot all 3 servers into Linux Rescue mode

make sure all hard drives are wiped while you're in rescue mode or before you get into the ceph installation

ssh into server and run command: installimage

## base install image config for all servers: 
**DRIVE1 /dev/nvme0n0<br>
DRIVE2 /dev/nvme01n1<br>
SWRAID 1<br>
SWRAIDLEVEL 1<br>
HOSTNAME CEPH0#<br>
PART swap swap 6G<br>
PART /boot ext3 4G<br>
PART / btrfs all<br>
IMAGE** (this line will remain the same from what OS you selected in installimage) (ubuntu jammy)

hit F10 and install

once the installation is complete, ensure that /dev/sda & /dev/sdb are completely wiped using fdisk. make sure to run w command even if drive has no partitions

**fdisk /dev/sda
fdisk /dev/sdb**

ensure that there is no partitions, filesystem signatures, or lvm volumes left on the drive 

once everything is done and verified, restart the system

## First Boot
execute the script provided on each server, the script will handle everything up until the next step

Installation of CEPH-ADM
ensure curl is installed using which curl if it doesn't show a response, install it using sudo apt install -y curl

install ceph adm using the following commands:

curl --silent --remote-name --location https://github.com/ceph/ceph/raw/pacific/src/cephadm/cephadm
**chmod +x cephadm
sudo ./cephadm add-repo --release pacific**

don't be alarmed by the error after this command, it's a feature not a bug

once you update, I have found that it doesn't update properly because Ceph doesn't have a repository for Jammy yet, so to fix this, use ubuntu focal's ceph repository in order to ensure latest cephadm installschange jammy to focal /etc/apt/sources.list.d/ceph.list

and than run apt update

**sudo ./cephadm install**

once the installation process is done, the following command will bootstrap the cluster to allow the cluster to run on the host

**sudo cephadm bootstrap --mon-ip 172.16.0.1**

once this completes, it will give you the user & password to loginThe URL will be partially incorrectthe correct URL will be https://PUBLIC_IP:8443/

## Set up the Ceph cluster using the Web panel
This is where we're going to log into the site https://PUBLIC_IP:8443/ once you first login, you'll notice that it asks you to change your password

once you get past that, click expand cluster and start adding hostThe host name must be identical to the hostname of the servers

for the Network Address, we'll be using the internal vSwitch IP's which is a part of the 172.16.0.0/24 network. ceph will use that network to avoid data caps and bandwitdth overages 

ensure that these labels are on all 3 hosts: mds, osd & rbd

Ceph01 should have _admin & grafana along with the other tags

wait for the status column to populate with information about the servers prior to moving on to the OSD phase to allow the other nodes to get setup 

at the OSD stage, set the drives you wish to be osd's as OSDs

you also want to have DB Devices set to allow storing of metadata

on the services page, create a MDS service with ID: mds, Placement should be Label and the label should be MDS. set the count to  the number of nodes being configured (in this case 3) and click create service and nextOnce you have reviewed everything to ensure its correct, click expand cluster

Setup public connectivity to Ceph
edit /etc/ceph/ceph.conf and add the following line in the [global] config

public_network = {65.21.88.21/32,157.90.36.20/32,65.21.124.126/32}

once you have the public network in ceph's config, restart ceph using 

reboot all 3 nodes once you have done this

CREATE a Pool for data
Using the menu below Cluster, create a pool to store data

type: Replicated

applicateions: rbd

compression mode: none