#!/bin/bash

# 检查是否已安装openssh-server
if ! command -v ssh >/dev/null 2>&1; then
  echo "openssh-server未安装，正在安装..."
  sudo apt update && sudo apt install -y openssh-server
fi

# 列出已存在的公钥
existing_keys=$(sudo cat ~/.ssh/authorized_keys)
if [[ -n "$existing_keys" ]]; then
  echo "当前已存在的公钥:"
  echo "$existing_keys" | awk -F ' ' '{print NR "." $NF}' RS= OFS='\n'
  echo ""
fi

# 交互界面，用户选择操作
while true; do
  echo "请选择操作:"
  echo "1. 继续添加公钥"
  if [[ -n "$existing_keys" ]]; then
    echo "2. 删除某段公钥"
  fi
  echo "3. 退出"
  read choice
  case $choice in
    1 )
      sudo sh -c "echo '$public_key' >> ~/.ssh/authorized_keys"
      echo "公钥已添加。"
      break
      ;;
    2 )
      if [[ -z "$existing_keys" ]]; then
        echo "当前不存在公钥，请先添加公钥。"
        continue
      fi
      echo "请输入要删除的公钥编号："
      read num
      key_to_delete=$(echo "$existing_keys" | awk -v num="$num" 'NR==num {print $0}' RS= OFS='\n')
      if [[ -z "$key_to_delete" ]]; then
        echo "输入的公钥编号不存在，请重新输入。"
        continue
      fi
      sudo sed -i "/$key_to_delete/d" ~/.ssh/authorized_keys
      echo "公钥已删除。"
      break
      ;;
    3 )
      echo "脚本已退出。"
      exit 0
      ;;
    * )
      echo "请选择正确的操作。"
      ;;
  esac

# 读取公钥
echo -n "请输入公钥（请确保公钥格式正确）: "
read public_key

# 检查是否输入了公钥
if [[ -z "$public_key" ]]; then
  echo "未输入公钥，脚本已停止。"
  exit 1
fi

# 检查公钥格式是否正确
if ! echo "$public_key" | grep -q "^ssh-rsa\|^ssh-ed25519"; then
  echo "公钥格式不正确，请输入正确的公钥。"
  exit 1
fi

# 检查是否已禁用密码登录
if sudo grep -q "^PasswordAuthentication no" /etc/ssh/sshd_config; then
  echo "密码登录已禁用，无需重复操作。"
else
  # 禁用密码登录
  echo "正在禁用密码登录..."
  sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
  sudo service ssh restart
  echo "密码登录已禁用。"
fi


