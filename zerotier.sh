#!/bin/bash

# 检查是否以root权限运行
if [[ $EUID -ne 0 ]]; then
   echo "本脚本需要以root权限运行，请使用 sudo 执行。" 
   exit 1
fi

# 在线安装 ZeroTier
echo "正在安装 ZeroTier..."
curl -s https://install.zerotier.com/ | bash

# 检查安装是否成功
if ! command -v zerotier-cli &> /dev/null; then
    echo "ZeroTier 安装失败，请检查网络连接或安装源。"
    exit 1
fi
echo "ZeroTier 安装成功！"

# 添加开机自启
echo "配置 ZeroTier 开机自启..."
systemctl enable zerotier-one.service

# 启动服务
echo "启动 ZeroTier 服务..."
systemctl start zerotier-one.service

# 确认服务启动成功
if systemctl status zerotier-one.service | grep -q "active (running)"; then
    echo "ZeroTier 服务已启动！"
else
    echo "ZeroTier 服务启动失败，请检查日志。"
    exit 1
fi

# 提示用户输入网络 ID
read -p "请输入您要加入的 ZeroTier 网络 ID: " NETWORK_ID

# 加入网络
if [[ -n "$NETWORK_ID" ]]; then
    echo "正在加入网络 $NETWORK_ID..."
    zerotier-cli join "$NETWORK_ID"
    if [ $? -eq 0 ]; then
        echo "已成功加入网络 $NETWORK_ID！"
        echo "请前往 ZeroTier 控制台批准设备加入请求。"
    else
        echo "加入网络失败，请检查网络 ID 或服务状态。"
    fi
else
    echo "网络 ID 为空，跳过加入网络步骤。"
fi

echo "ZeroTier 配置完成！"
