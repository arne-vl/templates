#!/bin/sh

# Ensure script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root." >&2
    exit 1
fi

# Prompt for share details
printf "Enter the SMB share name: "
read SHARE_NAME

printf "Enter the path for the share (default: /srv/%s): " "$SHARE_NAME"
read SHARE_PATH
[ -z "$SHARE_PATH" ] && SHARE_PATH="/srv/$SHARE_NAME"

printf "Enter the SMB username: "
read SMB_USER

printf "Enter the SMB password: "
stty -echo
read SMB_PASSWORD
stty echo
echo

printf "Confirm the SMB password: "
stty -echo
read CONFIRM_PASSWORD
stty echo
echo

if [ "$SMB_PASSWORD" != "$CONFIRM_PASSWORD" ]; then
    echo "Error: Passwords do not match!" >&2
    exit 1
fi

# Install Samba if not installed
if ! command -v smbd >/dev/null 2>&1; then
    echo "Installing Samba..."
    apt update && apt install -y samba || {
        echo "Failed to install Samba." >&2
        exit 1
    }
fi

# Create the share directory
mkdir -p "$SHARE_PATH"
chmod 777 "$SHARE_PATH"

# Create system user if not exists
if ! id "$SMB_USER" >/dev/null 2>&1; then
    useradd -M -s /usr/sbin/nologin "$SMB_USER"
fi

# Set SMB password
( echo "$SMB_PASSWORD"; echo "$SMB_PASSWORD" ) | smbpasswd -a -s "$SMB_USER"
smbpasswd -e "$SMB_USER"

# Backup smb.conf if not already backed up
if [ ! -f /etc/samba/smb.conf.bak ]; then
    cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
fi

# Append share configuration if not already present
if ! grep -q "^\[$SHARE_NAME\]" /etc/samba/smb.conf; then
    cat >> /etc/samba/smb.conf <<EOF

[$SHARE_NAME]
   path = $SHARE_PATH
   browseable = yes
   read only = no
   guest ok = no
   valid users = $SMB_USER
EOF
else
    echo "Share [$SHARE_NAME] already exists in smb.conf. Skipping config append."
fi

# Restart Samba to apply changes
systemctl restart smbd || service smbd restart

echo
echo "SMB share '$SHARE_NAME' created successfully at '$SHARE_PATH'."
echo "Access it via: smb://<server-ip>/$SHARE_NAME"
