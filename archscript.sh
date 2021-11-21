#              _               _     _   
#  ___ ___ ___| |_ ___ ___ ___|_|___| |_ 
# | .'|  _|  _|   |_ -|  _|  _| | . |  _|
# |__,|_| |___|_|_|___|___|_| |_|  _|_|  
#  made by nate randa           |_|     


# In order for this script to be completely autonomous, it needs to be split up
# into parts:
# 1-base-install.sh (everything done before arch-chroot)
# 2-post-install.sh (everything performed in arch-chroot)
# 3-user-install.sh (everything performed as the main user)

# Give execution privileges and run base-install
chmod +x 1-base-install.sh
./1-base-install.sh