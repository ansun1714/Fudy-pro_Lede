#!/bin/bash

# Lucky
echo "src-git lucky https://github.com/gdy666/luci-app-lucky.git" >> feeds.conf.default

# Qmodem
echo "src-git qmodem https://github.com/FUjr/modem_feeds.git;main" >> feeds.conf.default

# IPTV
echo "src-git rtp2httpd https://github.com/stackia/rtp2httpd.git" >> feeds.conf.default

echo "========== LEDE 自定义 feeds 添加完成 =========="
