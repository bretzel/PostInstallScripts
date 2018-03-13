#.bin/sh

if [ "$2" = "up" ]; then

    mount -t nfs 192.168.2.62:/nfs/bretzelus  /Cloud/bretzelus
    mount -t nfs 192.168.2.62:/nfs/Public  /Cloud/public
    mount -t nfs 192.168.2.62:/nfs/maryse  /Cloud/maryse
    mount -t nfs 192.168.2.62:/nfs/xilef  /Cloud/xilef

elif [ "$2" = "down" ]; then

    umount /Cloud/b
    umount /Cloud/public
    umount /Cloud/maryse
    umount /Cloud/xilef

fi

