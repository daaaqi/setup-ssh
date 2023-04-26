#!/bin/bash

# 检查用户是否为 root 账户
if [ "$EUID" -ne 0 ]
  then echo "请使用 root 账户执行此脚本"
  exit
fi

# 检查是否安装 sudo
if ! command -v sudo &> /dev/null
then
    echo "sudo 未安装，现在开始安装"
    apt-get update
    apt-get install -y sudo
fi

# 获取用户输入的公钥
echo "请粘贴您的公钥："
read public_key

# 检查用户是否输入了公钥
if [ -z "$public_key" ]; then
  echo "未输入公钥，脚本已停止"
  exit
fi

# 检查公钥格式是否正确
if ! echo "$public_key" | grep -q "ssh-rsa\|ssh-ed25519"; then
  echo "公钥格式不正确，脚本已停止"
  exit
fi

# 将公钥贴到 authorized_keys 文件中
sudo mkdir -p ~/.ssh
echo "$public_key" | sudo tee -a ~/.ssh/authorized_keys > /dev/null

# 检查用户是否已经禁用密码登录
if sudo grep -q "^PasswordAuthentication no" /etc/ssh/sshd_config; then
  echo "已经禁用密码登录，无需再次操作"
  exit
fi

# 禁用密码登录
sudo sed -i 's/.*PasswordAuthentication.*/PasswordAuthentication no/g' /etc/ssh/sshd_config

# 重启 sshd 服务
sudo systemctl restart sshd

# 检查已经存在的公钥
echo "当前机器上已经存在的公钥有："
awk '{print $3}' < ~/.ssh/authorized_keys | cut -d '@' -f 2 | sort | uniq
