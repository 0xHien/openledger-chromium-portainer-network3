#!/bin/bash

echo "=============================================="
echo "一键安装openledger chromium portainer network3 "
echo "                                              "
echo "        =============================         "
echo "               By   Hien                      "
echo "             X/推特：@Hienkkkk                 "
echo "=============================================="

set -e  # 如果有错误立即退出
sleep 5
# 安装 Docker
echo "正在安装 Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

echo "正在安装 Docker Compose..."
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name":' | cut -d '"' -f 4)
if [ -z "$DOCKER_COMPOSE_VERSION" ]; then
  echo "获取 Docker Compose 版本失败，使用默认版本 v2.22.0"
  DOCKER_COMPOSE_VERSION="v2.22.0"
fi

sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version


# 查看本机机器码
echo "当前机器码："
cat /etc/machine-id

# 重新生成机器码
echo "正在重新生成机器码..."
sudo rm -f /etc/machine-id /var/lib/dbus/machine-id
sleep 5
sudo systemd-machine-id-setup
echo "重新生成的机器码："
cat /etc/machine-id

# 切换到指定目录
echo "切换到目录：/home/openledger/.config/opl..."
cd /home/openledger/.config/opl

# 启动 Docker Compose 项目
echo "启动 Docker Compose 项目..."
docker-compose up -d



sleep 5
# 设置定时任务
# echo "设置定时任务，每小时重启容器 opl-worker-1 和 opl-scraper-1..."
# CRON_JOB="0 * * * * docker restart opl-worker-1 && docker restart opl-scraper-1"
# (sudo crontab -l 2>/dev/null | grep -v "docker restart opl-worker-1" ; echo "$CRON_JOB") | sudo crontab -

sleep 8
# 安装 Portainer
echo "正在安装 Portainer..."
docker run -d -p 9000:9000 \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce

# 安装 Chrome 容器
echo "正在安装 Chromium 容器..."
read -p "请输入访问Chrome浏览器的用户名: " CUSTOM_USER
read -sp "请输入访问Chrome浏览器的密码: " PASSWORD
echo
docker run -d \
  --name=chromium \
  --security-opt seccomp=unconfined \
  -e CUSTOM_USER=$CUSTOM_USER \
  -e PUID=1000 \
  -e PGID=1000 \
  -e DOCKER_MODS=linuxserver/mods:universal-package-install \
  -e INSTALL_PACKAGES=fonts-noto-cjk \
  -e LC_ALL=zh_CN.UTF-8 \
  -e TZ=Etc/UTC \
  -e CHROME_CLI=https://www.linuxserver.io/ \
  -e PASSWORD=$PASSWORD \
  -p 3000:3000 \
  -p 3001:3001 \
  -v /path/to/config:/config \
  --shm-size="500m" \
  --restart unless-stopped \
  lscr.io/linuxserver/chromium:latest

# 安装 Network3
echo "正在安装 Network3..."
cd /root
wget https://network3.io/ubuntu-node-v2.1.1.tar.gz
tar -zxvf ubuntu-node-v2.1.1.tar.gz
cd ubuntu-node
bash manager.sh up
echo "显示network3 key:"
bash manager.sh key

echo "所有任务已成功完成！"
