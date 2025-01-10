# 一键安装openledger chromium portainer network3教程

# 复制docker-compose.yaml文件到.config/opl/

1.下载到服务器
```wget https://raw.githubusercontent.com/0xHien/openledger-chromium-portainer-network3/refs/heads/main/setup.sh```

2.赋予权限
```chmod +x setup.sh```

3.执行
```./setup.sh```

## 章鱼会有掉线情况，可以按下面命令设置 

定时重启命令，一小时重启一次

执行```corntab -e```

写入 ```0 * * * * docker restart opl-worker-1 && docker restart opl-scraper-1```

保存

执行```corntab -l``` 查看是否写入成功
