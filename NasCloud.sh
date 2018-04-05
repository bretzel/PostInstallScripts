#.bin/sh

if [ "$2" = "up" ]; then

    mount -t nfs netfs:/nfs/bretzelus  /netfs/b
    mount -t nfs netfs:/nfs/Public  /netfs/p
    mount -t nfs netfs:/nfs/xilef  /netfs/x

elif [ "$2" = "down" ]; then

    umount /netfs/b
    umount /netfs/p
    umount /netfs/x

fi

