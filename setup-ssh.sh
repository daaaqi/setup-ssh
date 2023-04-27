#!/bin/bash

# Step 1: 检查是否为root用户
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Step 2: 检查sudo是否已安装，如未安装则安装sudo
if ! dpkg -s sudo >/dev/null 2>&1; then
  echo "sudo is not installed. Installing..."
  apt-get update && apt-get install -y sudo
fi

# Step 3: 检查是否已安装openssh-server，如未安装则安装openssh-server
if ! dpkg -s openssh-server >/dev/null 2>&1; then
  echo "openssh-server is not installed. Installing..."
  sudo apt-get update && sudo apt-get install -y openssh-server
fi

# Step 4: 提示输入要添加的公钥
echo "Please enter the public key you want to add:"
read pubkey

# Step 5: 检查公钥格式是否正确
if ! ssh-keygen -l -f <(echo "$pubkey") >/dev/null 2>&1; then
  echo "Invalid public key format. Please make sure it is in the correct format and try again."
  exit
fi

# Step 6: 把公钥添加到authorized_keys文件中
mkdir -p ~/.ssh && touch ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys
echo "$pubkey" >> ~/.ssh/authorized_keys

# Step 7: 询问是否禁用密码登录
echo "Do you want to disable password login? (y/n)"
read answer

# Step 8: 如果未禁用，则禁用密码登录
if [[ "$answer" =~ ^[Yy]$ ]]; then
  if ! grep -q '^PasswordAuthentication no' /etc/ssh/sshd_config; then
    echo "Disabling password login..."
    echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config
    service sshd reload
  else
    echo "Password login has already been disabled."
  fi
fi

# Step 9: 输出已完成提示信息
echo "Setup is completed."
