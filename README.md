# ghostbsd-core-build
GhostBSD core ISO build

Work based on https://github.com/pkgdemon/ghostbsd-core

These scripts will : 
(1) setup the build environment (setup-env.sh),
(2) assemble the core GhostBSD operating system. 
* 01-build-packages.sh will build base packages.  
* 02-build-iso.sh will assemble a hybrid ISO.  
* 03-build-vm.sh will boot the ISO in a bhyve VM for testing.  

## Recommend System Requirements for building base packages

* GhostBSD 20.07.14 or newer 
* 32GB memory
* 8 cores
* 50GB of disk space
* C Compiler
* Git
* GhostBSD src in /usr/src
* GhostBSD ports in /usr/ports
* Poudriere with one time manual configuration required

## System Requirements for VM testing

* GhostBSD 20.07.14 or newer
* 2GB memory for VM
* 2 cores for VM
* vm-bhyve with one time manual configuration required

Lesser configurations should work but have not been tested.

## Optional 
The following ISO is suggested for use, but not mandatory.
```
ftp://ftp.researchbsd.dev/pub/GhostBSD/development/GhostBSD-minimal-env-for-poudriere-2020-08-02.iso
```

## Setup build environment 
Adds necesary build dependencies
```
sudo ./setup-env.sh
```
## Install GhostBSD kernel source
```
git clone https://github.com/ghostbsd/ghostbsd.git /usr/src
```
## Install GhostBSD Ports
```
git clone https://github.com/ghostbsd/ghostbsd-ports.git /usr/ports
```

## Configure poudriere

Edit poudriere default configuration:

```
edit /usr/local/etc/poudriere.conf
```

Define to the pool to be used for building packages:

```
ZPOOL=tank
```

Define the local path for creating jails, ports trees:

```
BASEFS=/tank/poudriere
```

Save configuration then make distfiles location for building ports:

```
zfs create tank/usr/ports/distfiles
```

Create poudriere ports jail that uses /usr/ports for ports tree:
```
poudriere ports -c -p ghostbsd-ports -m null -M /usr/ports/
```

## Configure nginx to monitor ports build (optional)

Edit the default configuration:

```
edit /usr/local/etc/nginx/nginx.conf
```

Set root parameter, add data alias, and enable autoindex:

```
    server {
        listen       80;
        server_name  localhost;
        root         /usr/local/share/poudriere/html;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        location /data {
            alias /tank/poudriere/data/logs/bulk;
            autoindex on;
        }
```

Save configuration then enable nginx service:

```
rc-update add nginx
```

Start nginx service:

```
service nginx start
```

Now you can access poudriere from http://127.0.0.1 in browser to monitor progress of base packages build.

## Configure vm-bhyve
```
sysrc vm_enable="YES"
sysrc vm_dir="zfs:tank/usr/vms"
zfs set mountpoint=/usr/vms tank/usr/vms
vm init
rc-update add vm
```

Create bridge for networking
```
vm switch create public
```

Add your ethernet adapter to brige (substitute igb0 for your adapter)

```
vm switch add public igb0
```

Note that ipfw must be stopped if it is enabled, or bridge traffic must be allowed for networking to function (not covered here).  

## Build base packages
```
./01-build.packages.sh
```

## Build core image
```
./02-build-iso.sh
```

## Start VM with ISO and console for testing
```
./03-build-vm.sh
```

## Kill VM session from another terminal
```
killall cu
vm poweroff ghostbsd
```
