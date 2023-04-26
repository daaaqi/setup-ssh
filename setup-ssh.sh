#!/bin/bash

# Step 1: Add SSH public key
echo "Please enter your SSH public key:"
read ssh_public_key
mkdir -p ~/.ssh
echo "$ssh_public_key" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Step 2: Disable password authentication
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sudo sed -i 's/#ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/g' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Step 3: Print completion message
echo "SSH public key has been added and password authentication has been disabled."
