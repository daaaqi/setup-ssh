#!/bin/bash

# Check for dependencies and install if missing
if ! command -v sudo &> /dev/null
then
    echo "sudo command not found, installing..."
    if command -v apt-get &> /dev/null
    then
        sudo apt-get update && sudo apt-get install -y sudo
    elif command -v yum &> /dev/null
    then
        sudo yum install -y sudo
    else
        echo "Could not find a package manager to install sudo"
        exit 1
    fi
fi

# Determine whether to use sudo or not
if [ "$(whoami)" == "root" ]
then
    SUDO=""
else
    SUDO="sudo"
fi

# Step 1: Add SSH public key
echo "Please enter your SSH public key:"
read ssh_public_key

# Validate SSH public key format
if ! ssh-keygen -l -f <(echo "$ssh_public_key") >/dev/null 2>&1; then
    echo "Invalid SSH public key format. Please enter a valid SSH public key."
    exit 1
elif [[ -z $ssh_public_key ]]; then
    echo "SSH public key cannot be empty. Please enter a valid SSH public key."
    exit 1
fi

mkdir -p ~/.ssh
echo "$ssh_public_key" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Step 2: Disable password authentication
$SUDO sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
$SUDO sed -i 's/#ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/g' /etc/ssh/sshd_config
$SUDO systemctl restart sshd

# Step 3: Check for other SSH public keys in authorized_keys file
echo "The following email addresses are currently authorized:"
if [ -f ~/.ssh/authorized_keys ] && [ -s ~/.ssh/authorized_keys ]; then
    awk '{print $NF}' ~/.ssh/authorized_keys | cut -d "@" -f 2 | sort | uniq
else
    echo "No other email addresses are currently authorized."
fi

# Step 4: Print completion message
echo "SSH public key has been added and password authentication has been disabled."
