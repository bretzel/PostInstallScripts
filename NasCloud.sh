#.bin/sh

if [ "$2" = "up" ]; then

    mount -t nfs netfs:/nfs/bretzelus  /netfs/bretzelus
    mount -t nfs netfs:/Public  /netfs/shared

elif [ "$2" = "down" ]; then

    umount /netfs/bretzelus
    umount /netfs/shared

fi

