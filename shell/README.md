# Shell scripts
This folder contains usefull shell scripts.

## `create_ansible_user.sh`
This script creates an "ansible" user on a Linux system, sets up SSH key authentication, and grants the user passwordless sudo access.

Usage:
```sh
curl -s -O https://raw.githubusercontent.com/arne-vl/templates/refs/heads/main/shell/create_ansible_user.sh
chmod +x create_ansible_user.sh
sudo ./create_ansible_user.sh
```
Then paste in your public SSH key when prompted.

## `create_smb_share.sh`
This script creates a SMB share on a Linux system by creating a shared folder, configuring Samba, adding a user with authentication, and restarting the Samba service for network access.

Usage:
```sh
curl -s -O https://raw.githubusercontent.com/arne-vl/templates/refs/heads/main/shell/create_smb_share.sh
chmod +x create_smb_share.sh
sudo ./create_smb_share.sh
```
