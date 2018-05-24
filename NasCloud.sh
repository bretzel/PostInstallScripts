#.bin/sh

if [ "$2" = "up" ]; then

    mount -t nfs homefs:/nfs/bretzelus  /homefs/bretzelus
    mount -t nfs homefs:/nfs/Public  /homefs/Share

elif [ "$2" = "down" ]; then

    umount /homefs/bretzelus
    umount /homefs/Share

fi

