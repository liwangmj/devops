#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#
# Author: Wim Li <liwangmj@gmail.com> (http://liwangmj.com)

k_username=wim

# 安装基础应用
pacman -Syyu
# yaourt -S base-devel perl lua51 python2 vim gimp fcitx unzip unrar curl epdfview
yaourt -S docker docker-compose cmake git subversion valgrind gdb luajit python3 python-pip python2-pip adobe-source-code-pro-fonts wqy-microhei xmind eclipse-jee atom qtcreator kdesvn mysql-workbench mysql-utilities freerdp remmina gnu-netcat wireshark-qt lsof nload tcpdump chromium firefox filezilla dia vlc thunderbird fcitx-configtool kcm-fcitx fcitx-im lrzsz tmux leafpad calc wine winetricks create_ap create_ap-gui meld doxygen graphviz shadowsocks-qt5 shadowsocks dos2unix zip unrar wget

# 安装扩展应用
# yaourt -S fcitx-sogoupinyin gitkraken android-studio dbeaver-ee packetsender soapui wps-office pencil electronic-wechat nutstore teamviewer youdao-dict shutter

pip2 install --upgrade setuptools pip
pip install --upgrade backports.ssl_match_hostname

systemctl enable docker.service
systemctl start docker.service
gpasswd -a ${k_username} docker

winetricks mfc42

systemctl enable teamviewerd
systemctl start teamviewerd

cd /tmp
wget -c https://fpdownload.adobe.com/get/flashplayer/pdc/24.0.0.221/flash_player_npapi_linux.x86_64.tar.gz
tar -xzf flash_player_npapi_linux.x86_64.tar.gz
mv libflashplayer.so /usr/lib/chromuium/

# 关闭机箱喇叭
echo 'blacklist pcspkr' > /etc/modprobe.d/nopcspkr.conf

# 中文输入法设置
if [[ -z "$(ls /home/${k_username}/.xprofile.ibak)" ]]; then
    \cp -f /home/${k_username}/.xprofile /home/${k_username}/.xprofile.ibak
    echo 'export LC_CTYPE=zh_CN.UTF-8' >> /home/${k_username}/.xprofile
    echo 'export XIM=fcitx' >> /home/${k_username}/.xprofile
    echo 'export XIM_PROGRAM=fcitx' >> /home/${k_username}/.xprofile
    echo 'export GTK_IM_MODULE=fcitx' >> /home/${k_username}/.xprofile
    echo 'export QT_IM_MODULE=fcitx' >> /home/${k_username}/.xprofile
    echo 'export XMODIFIERS="@im=fcitx"' >> /home/${k_username}/.xprofile
    echo 'exec fcitx &' >> /home/${k_username}/.xprofile
fi

# 解决中文乱码
if [[ -z "$(ls /etc/locale.conf.ibak)" ]]; then
    \cp -f /etc/locale.conf /etc/locale.conf.ibak
    echo 'LC_TIME=en_US.UTF-8' > /etc/locale.conf
    echo 'LC_PAPER=zh_CN.UTF-8' >> /etc/locale.conf
    echo 'LC_MONETARY=zh_CN.UTF-8' >> /etc/locale.conf
    echo 'LC_NUMERIC=zh_CN.UTF-8' >> /etc/locale.conf
    echo 'LC_IDENTIFICATION=zh_CN.UTF-8' >> /etc/locale.conf
    echo 'LC_ADDRESS=zh_CN.UTF-8' >> /etc/locale.conf
    echo 'LC_TELEPHONE=zh_CN.UTF-8' >> /etc/locale.conf
    echo 'LC_NAME=zh_CN.UTF-8' >> /etc/locale.conf
    echo 'LC_MEASUREMENT=zh_CN.UTF-8' >> /etc/locale.conf
    echo 'LANG=en_US.UTF-8' >> /etc/locale.conf
fi

# 解决wine程序乱码
cd /tmp
echo 'REGEDIT4' > zh.reg
echo '[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\FontLink\SystemLink]' >> zh.reg
echo '"Lucida Sans Unicode"="wqy-microhei.ttc"' >> zh.reg
echo '"Microsoft Sans Serif"="wqy-microhei.ttc"' >> zh.reg
echo '"Tahoma"="wqy-microhei.ttc"' >> zh.reg
echo '"Tahoma Bold"="wqy-microhei.ttc"' >> zh.reg
echo '"SimSun"="wqy-microhei.ttc"' >> zh.reg
echo '"Arial"="wqy-microhei.ttc"' >> zh.reg
echo '"Arial Black"="wqy-microhei.ttc"' >> zh.reg

su ${k_username} <<-'EOF'
regedit zh.reg
wineboot
EOF

# 关闭防火墙
ufw disable

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
    systemctl enable sshd.service
    systemctl restart sshd.service
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
yaourt -Qdt
pacman -Scc
rm -rf /tmp/*

exit 0
