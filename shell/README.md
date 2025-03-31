# Shell scripts
This folder contains usefull shell scripts.

### `create_ansible_user.sh`
This script creates an "ansible" user on a Linux system, sets up SSH key authentication, and grants the user passwordless sudo access.

Usage:
```sh
curl -fsSL https://raw.githubusercontent.com/arne-vl/templates/refs/heads/main/shell/create_ansible_user.sh | sh
```
Then paste in your public SSH key when prompted.
