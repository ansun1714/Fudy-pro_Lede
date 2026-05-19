#!/bin/bash
# =====================================================
# DIY2 - WH3000 LEDE 终极稳定优化版
# Design主题 + Docker + Lucky + MT7981 WiFi加速
# =====================================================

echo "========================================="
echo " WH3000 LEDE DIY2 开始执行"
echo "========================================="

# =====================================================
# 1. 主机名 + 时区
# =====================================================

mkdir -p files/etc/uci-defaults

cat > files/etc/uci-defaults/01-system << 'EOF'
#!/bin/sh

uci set system.@system[0].hostname='WH3000'
uci set system.@system[0].timezone='CST-8'
uci set system.@system[0].zonename='Asia/Shanghai'

uci commit system

exit 0
EOF

chmod +x files/etc/uci-defaults/01-system

echo ">>> [1/7] 主机名配置完成"

# =====================================================
# 2. 默认主题 Design
# =====================================================

if [ -f package/lean/default-settings/files/zzz-default-settings ]; then
    sed -i 's/luci-theme-bootstrap/luci-theme-design/g' \
    package/lean/default-settings/files/zzz-default-settings
fi

find feeds/luci -name "Makefile" 2>/dev/null | \
xargs grep -l "luci-theme-bootstrap" 2>/dev/null | \
while read f; do
    sed -i 's/luci-theme-bootstrap/luci-theme-design/g' "$f"
done

echo ">>> [2/7] 默认主题已切换 Design"

# =====================================================
# 3. Lucky 权限修复
# =====================================================

echo ">>> [3/7] 修复 Lucky 权限..."

find feeds/ -type f -name "lucky*" \
-exec chmod +x {} \; 2>/dev/null || true

find package/ -type f -name "lucky*" \
-exec chmod +x {} \; 2>/dev/null || true

echo ">>> Lucky 权限修复完成"

# =====================================================
# 4. MT7981 WiFi 极速初始化
# 解决：
# - 首次WiFi很久才出现
# - 无线二次reload
# - path写死导致初始化慢
# =====================================================

mkdir -p files/etc/uci-defaults

cat > files/etc/uci-defaults/30-wifi-setup << 'EOF'
#!/bin/sh

logger -t wifi "MT7981 WiFi setup start"

# 等待 mtwifi 初始化
sleep 8

# 自动生成无线配置
[ ! -f /etc/config/wireless ] && wifi config

# 开启无线
uci set wireless.@wifi-device[0].disabled='0'
uci set wireless.@wifi-device[1].disabled='0'

# 国家
uci set wireless.@wifi-device[0].country='CN'
uci set wireless.@wifi-device[1].country='CN'

# 减少扫描等待
uci set wireless.@wifi-device[0].cell_density='0'
uci set wireless.@wifi-device[1].cell_density='0'

# 2.4G
uci set wireless.default_radio0.ssid='WH3000_2.4G'
uci set wireless.default_radio0.encryption='psk2+ccmp'
uci set wireless.default_radio0.key='password123'

# 5G
uci set wireless.default_radio1.ssid='WH3000_5G'
uci set wireless.default_radio1.encryption='psk2+ccmp'
uci set wireless.default_radio1.key='password123'

uci commit wireless

# 延迟reload避免mtwifi冲突
sleep 2

wifi reload

logger -t wifi "MT7981 WiFi setup complete"

exit 0
EOF

chmod +x files/etc/uci-defaults/30-wifi-setup

echo ">>> [4/7] MT7981 WiFi 极速初始化完成"

# =====================================================
# 5. Docker + 分区挂载
# =====================================================

mkdir -p files/etc/config

cat > files/etc/config/fstab << 'EOF'
config global
        option anon_mount '1'
        option auto_swap '1'
        option auto_mount '1'
        option delay_root '5'
        option check_fs '0'

config mount
        option target '/mnt/mmcblk0p7'
        option device '/dev/mmcblk0p7'
        option fstype 'ext4'
        option options 'rw,sync,noatime'
        option enabled '1'
        option enabled_fsck '0'
EOF

cat > files/etc/config/docker << 'EOF'
config globals
        option data_root '/mnt/mmcblk0p7/docker'
EOF

cat > files/etc/uci-defaults/40-docker << 'EOF'
#!/bin/sh

MOUNT="/mnt/mmcblk0p7"

for i in $(seq 1 20); do
    mountpoint -q "$MOUNT" && break
    sleep 1
done

if mountpoint -q "$MOUNT"; then
    mkdir -p "$MOUNT/docker"
    chmod 777 "$MOUNT/docker"
    logger -t docker "Docker directory ready"
else
    logger -t docker "Partition mount failed"
fi

exit 0
EOF

chmod +x files/etc/uci-defaults/40-docker

echo ">>> [5/7] Docker 配置完成"

# =====================================================
# 6. 系统性能优化
# =====================================================

mkdir -p files/etc

cat > files/etc/sysctl.conf << 'EOF'
net.netfilter.nf_conntrack_max=65535
net.ipv4.tcp_fastopen=3
net.core.somaxconn=65535
net.ipv4.tcp_syncookies=1
vm.swappiness=10
vm.vfs_cache_pressure=50
EOF

cat > files/etc/uci-defaults/98-performance << 'EOF'
#!/bin/sh

# uhttpd
uci set uhttpd.main.max_connections='200'
uci set uhttpd.main.max_requests='50'
uci set uhttpd.main.network_timeout='30'
uci set uhttpd.main.http_keepalive='20'
uci commit uhttpd

# rpcd
uci set rpcd.@rpcd[0].timeout='60'
uci commit rpcd

# luci中文
uci set luci.main.lang='zh_Hans'
uci commit luci

# Samba
uci -q set samba4.@samba[0].disable_ipv6='1'
uci commit samba4 2>/dev/null || true

exit 0
EOF

chmod +x files/etc/uci-defaults/98-performance

echo ">>> [6/7] 系统性能优化完成"

# =====================================================
# 7. Banner
# =====================================================

cat > files/etc/banner << 'EOF'

 __      __ _   _  _____   ___   ___   ___
 \ \    / /| | | ||___ /  / _ \ / _ \ / _ \
  \ \/\/ / | |_| |  |_ \ | | | | | | | | | |
   \_/\_/   \___/  |___/ |_| |_|\___/ |_| |_|

   华思飞 WH3000 · LEDE · MT7981
-------------------------------------------------
 Design Theme / Docker / Lucky / WiFi FastBoot
-------------------------------------------------

EOF

echo ">>> [7/7] Banner 写入完成"

echo ""
echo "========================================="
echo " WH3000 LEDE DIY2 执行完成"
echo "========================================="
echo " 已启用："
echo " - Design主题"
echo " - MT7981 WiFi快速启动"
echo " - Docker分区挂载"
echo " - Lucky权限修复"
echo " - 系统性能优化"
echo "========================================="
