#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#
# Author: Wim Li <liwangmj@gmail.com> (http://liwangmj.com)

k_username=super

# 增加用户
groupadd ${k_username}
useradd -G ${k_username} -g ${k_username} -s /bin/bash -m ${k_username}
passwd ${k_username}

# 安装基础应用
yum -y install epel-release net-tools wget curl
yum -y update && yum -y upgrade && yum -y install gcc gcc-c++ vim make automake libtool cmake tar unzip patch lsof lrzsz jq nc bind-utils perl perl-CPAN lua lua-devel luajit luajit-devel luarocks python python-devel python-setuptools python-pip valgrind gdb tcpdump nload git svn ntpdate cronie openssh-server watchdog
pip install --upgrade setuptools pip
pip install --upgrade backports.ssl_match_hostname

# 安装docker相关
curl -sSL http://acs-public-mirror.oss-cn-hangzhou.aliyuncs.com/docker-engine/internet | sh -
yum -y update && yum -y upgrade
pip install docker-compose
chkconfig --add docker
chkconfig docker on
service docker start

# 关闭防火墙
setenforce 0
sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config
service firewalld stop
chkconfig firewalld off

# 配置aliyun的docker加速器
if [[ -z "$(cat /etc/sysconfig/docker | grep aliyuncs)" ]]; then
    sed -i "s|OPTIONS='|OPTIONS='--registry-mirror=https://rbhx2eui.mirror.aliyuncs.com |g" /etc/sysconfig/docker
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
    chkconfig --add sshd
    chkconfig sshd on
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
yum clean all
rm -rf /tmp/*

exit 0

