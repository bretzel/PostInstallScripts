#/bin/sh

if [ "$2" = "up" ]
then
    mount -t nfs Nuage:/nfs/bretzelus   /Nuage/A
    mount -t nfs Nuage:/nfs/Public  	/Nuage/B
elif [ "$2" = "down" ]
then
    umount /Nuage/A
    umount /Nuage/B
fi

