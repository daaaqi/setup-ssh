# setup-ssh
自动贴公共钥且禁用ssh

```
wget https://raw.githubusercontent.com/daaaqi/setup-ssh/main/setup-ssh.sh
```
 实现功能：

* 检查用户是否为 root 账户
* 检查是否安装 sudo，如果没有安装则安装 sudo
* 检查已经存在的公钥
* 获取用户输入的公钥
* 检查用户是否输入了公钥
* 检查公钥格式是否正确
* 将公钥贴到 authorized_keys 文件中
* 检查是否已经禁用密码登录，如果已经禁用则无需再执行一次
* 禁用密码登录
* 重启 sshd 服务

