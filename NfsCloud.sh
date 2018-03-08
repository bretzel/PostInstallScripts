#.bin/sh
 
if [ "$2" = "up" ]; then
 
    mount -t nfs 192.168.2.62:/nfs/bretzelus  /Cloud/bretzelus
    mount -t nfs 192.168.2.62:/nfs/maryse  /Cloud/maryse
    mount -t nfs 192.168.2.62:/nfs/xilef  /Cloud/xilef
    mount -t nfs 192.168.2.62:/nfs/Public  /Cloud/shared
 
elif [ "$2" = "down" ]; then
 
    umount /Cloud/bretzelus
    umount /Cloud/maryse
    umount /Cloud/xilef
    umount /Cloud/shared
 
fi
 
