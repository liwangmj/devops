#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#
# Author: Wim Li <liwangmj@gmail.com> (http://liwangmj.com)

k_username=super

# 增加用户
groupadd ${k_username}
useradd -G ${k_username} -g ${k_username} -s /bin/bash -m ${k_username}
gpasswd -a ${k_username} sudo

# 安装基础应用
apt-get -y install net-tools wget curl
apt-get -y update && apt-get -y upgrade && apt-get -y install aptitude build-essential vim automake libtool cmake tar unzip patch lsof lrzsz jq netcat-traditional perl perl-modules lua5.1 luajit luarocks python python-setuptools python-pip valgrind tcpdump nload git subversion ntpdate cron openssh-server watchdog
update-alternatives --config nc
pip install --upgrade setuptools pip
pip install --upgrade backports.ssl_match_hostname

# 安装docker相关
apt-get -y install linux-image-extra-$(uname -r) linux-image-extra-virtual
apt-get -y install apt-transport-https ca-certificates
curl -sSL http://acs-public-mirror.oss-cn-hangzhou.aliyuncs.com/docker-engine/internet | sh -
apt-get -y update && apt-get -y upgrade
pip install docker-compose
update-rc.d docker defaults
service docker start
gpasswd -a ${k_username} docker

# 关闭防火墙
ufw disable

# 配置aliyun的docker加速器
if [[ -z "$(cat /etc/default/docker | grep aliyuncs)" ]]; then
    echo "DOCKER_OPTS=\"$DOCKER_OPTS --registry-mirror=https://rbhx2eui.mirror.aliyuncs.com\"" >> /etc/default/docker
    service docker restart
fi

# 配置ulimit
if [[ -z "$(ls /etc/security/limits.d/local.conf.ibak)" ]]; then
    \cp -f /etc/security/limits.d/local.conf /etc/security/limits.d/local.conf.ibak
    echo '* hard nofile 1048576' >> /etc/security/limits.d/local.conf
    echo '* soft nofile 1048576' >> /etc/security/limits.d/local.conf
    echo 'root hard nofile 1048576' >> /etc/security/limits.d/local.conf
    echo 'root soft nofile 1048576' >> /etc/security/limits.d/local.conf
    echo '* hard nproc 1048576' >> /etc/security/limits.d/local.conf
    echo '* soft nproc 1048576' >> /etc/security/limits.d/local.conf
    echo 'root hard nproc 1048576' >> /etc/security/limits.d/local.conf
    echo 'root soft nproc 1048576' >> /etc/security/limits.d/local.conf
    echo '* hard stack 8192' >> /etc/security/limits.d/local.conf
    echo '* soft stack 8192' >> /etc/security/limits.d/local.conf
    echo 'root hard stack 8192' >> /etc/security/limits.d/local.conf
    echo 'root soft stack 8192' >> /etc/security/limits.d/local.conf
fi

# 配置搜索库路径
if [[ -z "$(ls /etc/bashrc.ibak)" ]]; then
    \cp -f /etc/bashrc /etc/bashrc.ibak
    echo 'export LD_LIBRARY_PATH=.:/usr/local/lib:/usr/local/lib64' >> /etc/bashrc
    export LD_LIBRARY_PATH=.:/usr/local/lib:/usr/local/lib64
    echo '.' >> /etc/ld.so.conf.d/local.conf
    echo '/usr/local/lib' >> /etc/ld.so.conf.d/local.conf
    echo '/usr/local/lib64' >> /etc/ld.so.conf.d/local.conf
    ldconfig
fi

# 配置ssh-server
if [[ -z "$(ls /etc/ssh/sshd_config.ibak)" ]]; then
    \cp -f /etc/ssh/sshd_config /etc/ssh/sshd_config.ibak
    sed -i 's/Port 22/Port 65522/' /etc/ssh/sshd_config
    sed -i 's/#Port 65522/Port 65522/' /etc/ssh/sshd_config
    sed -i 's/#Protocol 2/Protocol 2/' /etc/ssh/sshd_config
    sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
    sed -i 's/#PermitRootLogin without-password/PermitRootLogin no/' /etc/ssh/sshd_config
    echo 'sshd:all' >> /etc/hosts.deny
    echo 'sshd:all' >> /etc/hosts.allow
    update-rc.d sshd defaults
    service sshd restart
fi

# 设置ssh公钥并发送私钥
su - ${k_username} <<-'EOF'
rm -rf ~/.ssh
ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ''
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 700 -R ~/.ssh
chmod 600 ~/.ssh/authorized_keys
EOF

# 清理
apt-get clean && apt-get autoclean
rm -rf /tmp/*

# 配置
dpkg --configure -a

exit 0
