TARGETS = console-setup resolvconf fake-hwclock mountkernfs.sh alsa-utils ufw hostname.sh x11-common lm-sensors pppd-dns apparmor plymouth-log udev mountdevsubfs.sh procps brltty hwclock.sh networking rpcbind checkroot.sh urandom kmod checkfs.sh checkroot-bootclean.sh bootmisc.sh mountnfs.sh mountall.sh mountnfs-bootclean.sh mountall-bootclean.sh
INTERACTIVE = console-setup udev checkroot.sh checkfs.sh
udev: mountkernfs.sh
mountdevsubfs.sh: mountkernfs.sh udev
procps: mountkernfs.sh udev
brltty: mountkernfs.sh udev
hwclock.sh: mountdevsubfs.sh
networking: resolvconf mountkernfs.sh urandom procps
rpcbind: networking
checkroot.sh: fake-hwclock hwclock.sh mountdevsubfs.sh hostname.sh
urandom: hwclock.sh
kmod: checkroot.sh
checkfs.sh: checkroot.sh
checkroot-bootclean.sh: checkroot.sh
bootmisc.sh: checkroot-bootclean.sh udev mountnfs-bootclean.sh mountall-bootclean.sh
mountnfs.sh: networking rpcbind
mountall.sh: checkfs.sh checkroot-bootclean.sh
mountnfs-bootclean.sh: mountnfs.sh
mountall-bootclean.sh: mountall.sh
