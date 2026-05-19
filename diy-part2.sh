#!/bin/bash
#=================================================
# DIY2 - WH3000 MT7981 极速启动优化版
#=================================================

echo "========================================="
echo " WH3000 极速 WiFi 启动优化开始"
echo "========================================="

#=================================================
# 1. 主机名
#=================================================

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

echo ">>> 主机名配置完成"

#=================================================
# 2. 默认主题
#=================================================

if [ -f package/lean/default-settings/files/zzz-default-settings ]; then
    sed -i 's/luci-theme-bootstrap/luci-theme-design/g' \
    package/lean/default-settings/files/zzz-default-settings
fi

echo ">>> 默认主题切换为 Design"

#=================================================
# 3. Lucky 权限
#=================================================

find feeds/lucky/ -type f -name "lucky*" \
-exec chmod +x {} \; 2>/dev/null || true

echo ">>> Lucky 权限修复完成"

#=================================================
# 4. WiFi 极速启动优化（核心）
#=================================================

mkdir -p files/etc/config

cat > files/etc/config/wireless << 'EOF'
config wifi-device 'radio0'
        option type 'mac80211'
        option band '2g'
        option channel 'auto'
        option htmode 'HT40'
        option country 'CN'
        option disabled '0'

config wifi-iface 'default_radio0'
        option device 'radio0'
        option network 'lan'
        option mode 'ap'
        option ssid 'WH3000_2.4G'
        option encryption 'psk2'
        option key '12345678'

config wifi-device 'radio1'
        option type 'mac80211'
        option band '5g'
        option channel 'auto'
        option htmode 'HE80'
        option country 'CN'
        option disabled '0'

config wifi-iface 'default_radio1'
        option device 'radio1'
        option network 'lan'
        option mode 'ap'
        option ssid 'WH3000_5G'
        option encryption 'psk2'
        option key '12345678'
EOF

echo ">>> 预置无线配置完成"

#=================================================
# 5. 提前加载 MT7981 WiFi 驱动（关键）
#=================================================

mkdir -p files/etc/modules.d

cat > files/etc/modules.d/99-mtwifi << 'EOF'
mt_wifi
mt_wifi_mt7981
mt_wifi_mt7986
EOF

echo ">>> WiFi 驱动预加载完成"

#=================================================
# 6. 避免首次启动重新生成无线
#=================================================

mkdir -p files/etc/uci-defaults

cat > files/etc/uci-defaults/99-disable-wifi-reset << 'EOF'
#!/bin/sh

rm -f /etc/uci-defaults/network
rm -f /etc/uci-defaults/wireless

exit 0
EOF

chmod +x files/etc/uci-defaults/99-disable-wifi-reset

echo ">>> 禁止首次重建无线配置"

#=================================================
# 7. Docker 优化
#=================================================

cat > files/etc/config/docker << 'EOF'
config globals
        option data_root '/opt/docker'
EOF

echo ">>> Docker 配置完成"

#=================================================
# 8. 系统启动优化
#=================================================

cat > files/etc/sysctl.conf << 'EOF'
net.netfilter.nf_conntrack_max=65535
net.core.somaxconn=65535
net.ipv4.tcp_fastopen=3
net.ipv4.tcp_syncookies=1
EOF

echo ">>> 系统优化完成"

#=================================================
# 9. 修复 GPT 延迟（重点）
#=================================================

mkdir -p files/etc/uci-defaults

cat > files/etc/uci-defaults/30-emmc-fix << 'EOF'
#!/bin/sh

block detect > /etc/config/fstab

uci set fstab.@global[0].delay_root='3'
uci commit fstab

exit 0
EOF

chmod +x files/etc/uci-defaults/30-emmc-fix

echo ">>> eMMC 启动延迟优化完成"

#=================================================
# 10. Banner
#=================================================

mkdir -p files/etc

cat > files/etc/banner << 'EOF'

██╗    ██╗██╗  ██╗██████╗  ██████╗  ██████╗
██║    ██║██║  ██║╚════██╗██╔═████╗██╔═████╗
██║ █╗ ██║███████║ █████╔╝██║██╔██║██║██╔██║
██║███╗██║██╔══██║██╔═══╝ ████╔╝██║████╔╝██║
╚███╔███╔╝██║  ██║███████╗╚██████╔╝╚██████╔╝
 ╚══╝╚══╝ ╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝

 WH3000 · LEDE · MT7981 极速优化版

EOF

echo "========================================="
echo " DIY2 执行完成"
echo " 已启用："
echo " ✔ 极速 WiFi 启动"
echo " ✔ MT7981 驱动预加载"
echo " ✔ 禁止首次无线重建"
echo " ✔ eMMC 启动优化"
echo "========================================="
