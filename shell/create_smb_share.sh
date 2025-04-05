#!/bin/sh

# Ensure script is run as root
if [ $EUID -ne 0 ]; then
    echo "This script must be run as root." >&2
    exit 1
fi

read -p "Enter the SMB share name: " SHARE_NAME
read -p "Enter the path for the share (default: /srv/$SHARE_NAME): " SHARE_PATH
SHARE_PATH=${SHARE_PATH:-/srv/$SHARE_NAME}
read -p "Enter the SMB username: " SMB_USER
read -s -p "Enter the SMB password: " SMB_PASSWORD
echo
read -s -p "Confirm the SMB password: " CONFIRM_PASSWORD
echo

if [ "$SMB_PASSWORD" != "$CONFIRM_PASSWORD" ]; then
    echo "Error: Passwords do not match!" >&2
    exit 1
fi

if ! command -v smbd &> /dev/null; then
    echo "Installing Samba..."
    apt update && apt install -y samba
fi

mkdir -p "$SHARE_PATH"
chmod 777 "$SHARE_PATH"

if ! id "$SMB_USER" &>/dev/null; then
    useradd -M -s /sbin/nologin "$SMB_USER"
fi
echo -e "$SMB_PASSWORD\n$SMB_PASSWORD" | smbpasswd -a -s "$SMB_USER"
smbpasswd -e "$SMB_USER"

cp /etc/samba/smb.conf /etc/samba/smb.conf.bak

cat >> /etc/samba/smb.conf <<EOF

[$SHARE_NAME]
   path = $SHARE_PATH
   browseable = yes
   read only = no
   guest ok = no
   valid users = $SMB_USER
EOF

systemctl restart smbd

echo "SMB share '$SHARE_NAME' created successfully at '$SHARE_PATH'."
echo "Access it via: smb://<server-ip>/$SHARE_NAME"
