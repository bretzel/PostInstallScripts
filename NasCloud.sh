#.bin/sh

if [ "$2" = "up" ]; then

    mount -t nfs netfs:/nfs/bretzelus  /netfs/bretzelus
    mount -t nfs netfs:/nfs/Public  /netfs/shared
    mount -t nfs netfs:/nfs/xilef  /netfs/xilef

elif [ "$2" = "down" ]; then

    umount /netfs/bretzelus
    umount /netfs/shared
    umount /netfs/xilef

fi

