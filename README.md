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

## Setup Ceph webpanel
**sudo cephadm bootstrap --mon-ip 172.16.0.1**

once this completes, it will give you the user & password to loginThe URL will be partially incorrectthe correct URL will be https://PUBLIC_IP:8443/

## Set up the Ceph cluster using the Web panel
This is where we're going to log into the site https://PUBLIC_IP:8443/ once you first login, you'll notice that it asks you to change your password

once you get past that, click expand cluster and start adding hostThe host name must be identical to the hostname of the servers

for the Network Address, we'll be using the internal vSwitch IP's which is a part of the 172.16.0.0/24 network. ceph will use that network to avoid data caps and bandwitdth overages 

ensure that these labels are on all 3 hosts: _admin, mds, osd & rbd

Ceph01 should have _admin, grafana & rgw as it's tags

wait for the status column to populate with information about the servers prior to moving on to the OSD phase to allow the other nodes to get setup 

at the OSD stage, set the drives you wish to be osd's as OSDs

you also want to have DB Devices set to allow storing of metadata

on the services page, create a MDS service with ID: mds, Placement should be Label and the label should be MDS. set the count to  the number of nodes being configured (in this case 3) and click create service and next. 
you are also going to want to create a rgw service with id: rgw and set the placement to labels and use the rgw label
we can set the count to 1 as only 1 rgw will be configured

once you have reviewed everything to ensure its correct, click expand cluster

## CREATE a Pool for data
Using the menu below Cluster, create a pool to store data<br>
anything you update here, should also be updated in the scripts provided
name: DATA
type: Replicated<br>
applicateions: rbd<br>
compression mode: none<br>
**Crush Rule:<br>**
Name: RBD_CrushRule<br>
Root: Default<br>
Failure domain type: OSD<br>
Device Class: SSD<br>

Once complete, create the pool

## Setting up a RBD Image to expose
under the Block menu, create an Image that uses the data pool that we set up before. 
anything you update here, should also be updated in the Scripts provided
Name: data
For size, we'll use 50GiB in this setup<br>
as for features, we'll leave that default

## Connecting to the RBD 
connect the server to the vswitch and give it an ip address of 172.16.0.4<br>
transfer /etc/ceph/ceph.client.admin.keyring to the server and put it in /etc/ceph (you'll probably need to make /etc/ceph)<br>
copy /etc/ceph/ceph.conf to the connecting server<br>

run the provided setup script on the server you're trying to connect to the RBD (the script will mount everything based on the guide below)

good guide for mounting RBD's<br>
http://www.sebastien-han.fr/blog/2013/11/22/map-slash-unmap-rbd-device-on-boot-slash-shutdown/
