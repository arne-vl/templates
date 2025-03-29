#!/bin/sh

ANSIBLE_USER="ansible"

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root (use sudo)." >&2
    exit 1
fi

echo "Paste your public SSH key and press Enter:"
read -r SSH_KEY

if id "$ANSIBLE_USER" >/dev/null 2>&1; then
    echo "User '$ANSIBLE_USER' already exists."
else
    echo "Creating user '$ANSIBLE_USER'..."
    useradd -m -s /bin/sh -G sudo "$ANSIBLE_USER"
    echo "User '$ANSIBLE_USER' created."
fi

SSH_DIR="/home/$ANSIBLE_USER/.ssh"
mkdir -p "$SSH_DIR"
chown "$ANSIBLE_USER:$ANSIBLE_USER" "$SSH_DIR"
chmod 700 "$SSH_DIR"

echo "Setting up SSH key for '$ANSIBLE_USER'..."
echo "$SSH_KEY" > "$SSH_DIR/authorized_keys"
chown "$ANSIBLE_USER:$ANSIBLE_USER" "$SSH_DIR/authorized_keys"
chmod 600 "$SSH_DIR/authorized_keys"

echo "Configuring sudoers for '$ANSIBLE_USER'..."
echo "$ANSIBLE_USER ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/$ANSIBLE_USER"
chmod 440 "/etc/sudoers.d/$ANSIBLE_USER"

echo "Disabling password authentication in SSH..."
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

echo "Restarting SSH service..."
service ssh restart

echo "Setup complete! You can now SSH into the server as '$ANSIBLE_USER'."
