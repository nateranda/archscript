#              _               _     _   
#  ___ ___ ___| |_ ___ ___ ___|_|___| |_ 
# | .'|  _|  _|   |_ -|  _|  _| | . |  _|
# |__,|_| |___|_|_|___|___|_| |_|  _|_|  
#  made by nate randa           |_|     

# A set of shell scripts that aim to provide a fast, customizable, and easy way
# to install Arch Linux. 

# The bulk of the script is split up into three parts:

# 1-base-install.sh (everything done before arch-chroot)
# 2-post-install.sh (everything performed in arch-chroot)
# 3-user-install.sh (everything performed as the main user)

# If you want to add anything, make sure you put it in the correct file so it
# doesn't get run by the wrong user or in the wrong place.

# Huge shoutout to Chris Titus Tech and his ArchTitus project - it inspired me
# to make my own scripts and served as a great starting place to build off of.
# -----------------------------------------------------------------------------


# Import configure.conf file if it exists
if [ -e ~/archscript/config.conf ]; then source ~/archscript/config.conf; fi

# Prompt for username if not in conf file
if [ ! -v username ]
then
    read -p "Username: " username
    echo -e "\nusername=$username" >> ~/archscript/config.conf
fi

# Give execution privileges & run base-install
chmod +x 1-base-install.sh
./1-base-install.sh

# Copy file/config to /mnt
cp 2-post-install.sh /mnt/2-post-install.sh
cp ~/archscript/config.conf /mnt/config.conf

# Give execution privileges & run post-install in chroot
chmod +x /mnt/2-post-install.sh
arch-chroot /mnt /2-post-install.sh

# Remove script from /mnt
rm /mnt/2-post-install.sh

# Copy file/config to user home
cp 3-user-install.sh /mnt/home/$username/3-user-install.sh
cp /mnt/config.conf /mnt/home/$username/config.conf
rm /mnt/config.conf

# Import configure.conf file again because it might have changed
source /mnt/home/$username/config.conf

# Restart if specified
if [ $restart == "true" ]
then
    chmod +x /mnt/home/$username/3-user-install.sh
    reboot
fi
sleep 10

# Give execution privileges & run user-install as user
chmod +x /mnt/home/$username/3-user-install.sh
arch-chroot /mnt /usr/bin/runuser -u $username -- /home/$username/3-user-install.sh
rm /mnt/home/$username/3-user-install.sh