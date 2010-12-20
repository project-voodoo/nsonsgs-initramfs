#!/sbin/sh
# Voodoo Nexus kernel on Galaxy S pre-init script :
# author: François Simond @supercurio
exec > /pre_init.log 2>&1 
set -x
PATH=/sbin


# create required device
mkdir -p /dev/block/
mknod /dev/block/mmcblk0p2 b 179 2


# make sure the empty mount directory is present
mkdir /nsonsgs/mnt


# mount loop: wait for the internal sdcard device to appear
while true; do
	mount -t ext4 -o noatime,noauto_da_alloc,barrier=1,data=ordered \
		/dev/block/mmcblk0p2 /nsonsgs/mnt && break
	sleep 0.1
done


# bind-mount resources to fool Android system
mkdir -p /system
mkdir -p /cache
mkdir -p /data
mkdir -p /efs
mount -o bind /nsonsgs/mnt/gingerbread/system /system
mount -o bind /nsonsgs/mnt/gingerbread/cache /cache
mount -o bind /nsonsgs/mnt/gingerbread/data /data
mount -o bind /nsonsgs/mnt/gingerbread/efs /efs


# copy port resources
cp nsonsgs/resources/vold.fstab /system/etc/


# run the original init binary
mv init_binary init
exec /init
