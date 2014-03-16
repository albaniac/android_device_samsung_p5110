#!/sbin/sh

# Ketut P. Kumajaya, May 2013
# Ketut P. Kumajaya, Dec 2013

# Waiting for kernel init process
sleep 1
busybox mount -o remount,rw /

mkdir /.secondrom
busybox mount -t ext4 /dev/block/mmcblk0p10 /.secondrom

DEFAULTROM=0

echo interactive > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
# echo 0 > /sys/devices/virtual/sec/tsp/pivot

if [ -f /.secondrom/media/.secondrom/system.img ]; then
  aroma 1 0 /res/misc/bootmenu.zip
  # clear framebuffer device
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
  rm -f /dev/block/mmcblk0p9
  rm -f /dev/block/mmcblk0p7
  ln -s /dev/block/loop0 /dev/block/mmcblk0p9
  ln -s /dev/block/mmcblk0p11 /dev/block/mmcblk0p7

  mkdir -p /.secondrom/media/.secondrom/data
  busybox mount --bind /.secondrom/media/.secondrom/data /data
  mkdir -p /data/media
  busybox mount --bind /.secondrom/media /data/media

  if [ ! -f /data/philz-touch/philz-touch_6.ini ]; then
    mkdir -p /data/philz-touch
    echo "menu_height=16" > /data/philz-touch/philz-touch_6.ini
    echo "menu_text_color=4" >> /data/philz-touch/philz-touch_6.ini
  fi
else
  if [ ! -f /.secondrom/philz-touch/philz-touch_6.ini ]; then
    mkdir -p /.secondrom/philz-touch
    echo "menu_height=16" > /.secondrom/philz-touch/philz-touch_6.ini
  fi
  busybox umount -f /.secondrom
fi
