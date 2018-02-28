echo " Applying fix-hack to the Qt micro-scroll bug:"
sudo pacman -S xf86-input-mouse xf86-input-evdev
echo 'Section "InputClass"' >> /etc/X11/xorg.conf.d/99-user.conf
echo '    Identifier "evdev pointer catchall"' >> /etc/X11/xorg.conf.d/99-user.conf  
echo '    MatchIsPointer "on"' >> /etc/X11/xorg.conf.d/99-user.conf
echo '    MatchDevicePath "/dev/input/event*"' >> /etc/X11/xorg.conf.d/99-user.conf
echo '    Driver "evdev"' >> /etc/X11/xorg.conf.d/99-user.conf
echo 'EndSection' >> /etc/X11/xorg.conf.d/99-user.conf
echo " Done."
