#!/bin/bash
# DIY 脚本第一部分：添加自定义软件源
# 在 feeds update 之前由 workflow 执行

# Lucky（内网穿透/DDNS）
echo "src-git lucky https://github.com/gdy666/luci-app-lucky.git" >> feeds.conf.default

# Qmodem（4G/5G 模块管理）
echo "src-git qmodem https://github.com/FUjr/modem_feeds.git;main" >> feeds.conf.default

# rtp2httpd（IPTV 组播转单播）
echo "src-git rtp2httpd https://github.com/stackia/rtp2httpd.git" >> feeds.conf.default

# msd_lite 主程序
git clone --depth=1 https://github.com/ximiTech/msd_lite package/msd_lite

# 删除官方 msd_lite 自带的 init.d，防止覆盖我们的双后端版本
rm -f package/msd_lite/files/etc/init.d/msd_lite 2>/dev/null || true

# luci-app-msd_lite 使用仓库里的魔改版（2合1界面）
cp -r ../luci-app-msd_lite package/luci-app-msd_lite

echo "✅ 软件源添加完成"
echo "当前 feeds.conf.default 内容："
cat feeds.conf.default
