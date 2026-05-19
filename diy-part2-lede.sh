#!/bin/bash

# 默认主题改为 Design
sed -i 's/luci-theme-bootstrap/luci-theme-design/g' \
feeds/lean/default-settings/files/zzz-default-settings

# 主机名
sed -i 's/OpenWrt/WH3000/g' \
package/base-files/files/bin/config_generate

mkdir -p files/etc/uci-defaults

cat > files/etc/uci-defaults/99-custom << 'EOF'
#!/bin/sh

uci set system.@system[0].hostname='WH3000'
uci set system.@system[0].timezone='CST-8'
uci set system.@system[0].zonename='Asia/Shanghai'

# Docker
uci set dockerd.globals.data_root='/mnt/mmcblk0p7/docker'

# LuCI 中文
uci set luci.main.lang='zh_Hans'

uci commit

mkdir -p /mnt/mmcblk0p7/docker

exit 0
EOF

chmod +x files/etc/uci-defaults/99-custom

echo "========== LEDE DIY2 完成 =========="
