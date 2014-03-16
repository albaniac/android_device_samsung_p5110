#!/sbin/sh

# Ketut P. Kumajaya, May 2013, Nov 2013, Mar 2014
# Do not remove above credits header!

DEFAULTROM=0

# Galaxy Tab 2 block device
# Don't use /dev/block/platform/*/by-name/* symlink!
SYSTEMDEV="/dev/block/mmcblk0p9"
DATADEV="/dev/block/mmcblk0p10"
CACHEDEV="/dev/block/mmcblk0p7"
HIDDENDEV="/dev/block/mmcblk0p11"

# Galaxy Tab 3 T31x block device
# Don't use /dev/block/platform/*/by-name/* symlink!
# SYSTEMDEV="/dev/block/mmcblk0p20"
# DATADEV="/dev/block/mmcblk0p21"
# CACHEDEV="/dev/block/mmcblk0p19"
# HIDDENDEV="/dev/block/mmcblk0p16"

# Set CPU governor, NEXT kernel for Galaxy Tab 2 default governor is performance
echo interactive > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

# Rotate touchscreen orientation, for Galaxy Tab 2 P31xx
# echo 0 > /sys/devices/virtual/sec/tsp/pivot

# Waiting for kernel init process
sleep 1
busybox mount -o remount,rw /

mkdir /.secondrom
busybox mount -t ext4 $DATADEV /.secondrom

if [ -f /.secondrom/media/.secondrom/system.img ]; then
  aroma 1 0 /res/misc/bootmenu.zip
  # Clear framebuffer device
  dd if=/dev/zero of=/dev/graphics/fb0
  DEFAULTROM=`cat /.secondrom/media/.defaultrecovery`
fi

if [ "$DEFAULTROM" == "1" ]; then
  mv -f /res/misc/recovery.fstab.2 /etc/recovery.fstab
  mv -f /res/misc/mount.2 /sbin/mount
  mv -f /res/misc/umount.2 /sbin/umount
  mv -f /res/misc/virtual_keys.2.png /res/images/virtual_keys.png
  chmod 755 /sbin/mount
  chmod 755 /sbin/umount

  losetup /dev/block/loop0 /.secondrom/media/.secondrom/system.img
  # Remove default /system and /cache block device
  rm -f $SYSTEMDEV $CACHEDEV
  # Symlink /system block device to /dev/block/loop0
  ln -s /dev/block/loop0 $SYSTEMDEV
  # Symlink /cache block device to /preload block device
  ln -s $HIDDENDEV $CACHEDEV

  mkdir -p /.secondrom/media/.secondrom/data
  busybox mount --bind /.secondrom/media/.secondrom/data /data
  mkdir -p /data/media
  busybox mount --bind /.secondrom/media /data/media

  if [ ! -f /data/philz-touch/philz-touch_6.ini ]; then
    mkdir -p /data/philz-touch
    echo "menu_text_color=4" >> /data/philz-touch/philz-touch_6.ini
  fi
else
  if [ ! -f /.secondrom/philz-touch/philz-touch_6.ini ]; then
    mkdir -p /.secondrom/philz-touch
  fi
  busybox umount -f /.secondrom
fi
