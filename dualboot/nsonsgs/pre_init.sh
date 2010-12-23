#!/sbin/sh
# Voodoo Nexus kernel on Galaxy S pre-init script :
# author: François Simond @supercurio
exec > /pre_init.log 2>&1 
set -x
PATH=/sbin


# create required device
mkdir -p /dev/block/
mknod /dev/block/mmcblk0p1 b 179 1
mknod /dev/block/mmcblk0p2 b 179 2


# make sure the empty mount directory is present
mkdir /nsonsgs/mnt


# detect the model
mount -t sysfs sys /sys
if test "`cat /sys/block/mmcblk0/size`" = 3907584; then
	data_partition='/dev/block/mmcblk0p1'	# we are on fascinate/mesmerize/showcase
	model_prefix='-fascinate'
else
	data_partition='/dev/block/mmcblk0p2'	# every other Galaxy S
fi

# mount loop: wait for the internal sdcard device to appear
mount_count=0
while true; do
	mount -t ext4 -o noatime,noauto_da_alloc,barrier=1,data=ordered \
		$data_partition /nsonsgs/mnt && break
	sleep 0.1
	mount_count=$(( $mount_count + 1 ))
	test $mount_count -lt 20 || break
done


# bind-mount resources to fool Android system
mkdir -p /system
mkdir -p /cache /nsonsgs/mnt/gingerbread/cache
mkdir -p /data /nsonsgs/mnt/gingerbread/data
mkdir -p /efs /nsonsgs/mnt/gingerbread/efs
mount -o bind /nsonsgs/mnt/gingerbread/system /system
mount -o bind /nsonsgs/mnt/gingerbread/cache /cache
mount -o bind /nsonsgs/mnt/gingerbread/data /data
mount -o bind /nsonsgs/mnt/gingerbread/efs /efs


# copy port resources
cp nsonsgs/resources/vold.fstab"$model_prefix" /system/etc/vold.fstab


umount /sys
# run the original init binary
mv init_binary init
exec /init
