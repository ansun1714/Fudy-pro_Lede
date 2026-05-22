#!/bin/bash

echo "========================================"
echo " WH3000 专用优化脚本开始"
echo "========================================"

# =====================================================
# 1. 主机名
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
echo ">>> 主机名配置完成"

# =====================================================
# 2. 默认主题
# =====================================================
sed -i 's/luci-theme-bootstrap/luci-theme-design/g' \
package/lean/default-settings/files/zzz-default-settings 2>/dev/null
echo ">>> 默认主题修改完成"

# =====================================================
# 3. Lucky 权限
# =====================================================
find . -type f -name "lucky*" -exec chmod +x {} \; 2>/dev/null
echo ">>> Lucky 权限修复完成"

# =====================================================
# 4. WiFi 极速启动优化
# =====================================================
mkdir -p files/etc/config

cat > files/etc/config/wireless << 'EOF'
config wifi-device 'radio0'
	option type 'mac80211'
	option path 'platform/soc/18000000.wifi'
	option band '2g'
	option channel 'auto'
	option htmode 'HT40'
	option country 'CN'
	option cell_density '0'
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
	option path 'platform/soc/18000000.wifi+1'
	option band '5g'
	option channel '36'
	option htmode 'HE80'
	option country 'CN'
	option cell_density '0'
	option disabled '0'

config wifi-iface 'default_radio1'
	option device 'radio1'
	option network 'lan'
	option mode 'ap'
	option ssid 'WH3000_5G'
	option encryption 'psk2'
	option key '12345678'
EOF
echo ">>> WiFi 预配置完成"

# =====================================================
# 5. WiFi 启动加速
# =====================================================
mkdir -p files/etc/uci-defaults

cat > files/etc/uci-defaults/99-wifi-fast << 'EOF'
#!/bin/sh
rm -f /etc/uci-defaults/network
rm -f /etc/uci-defaults/wireless
wifi reload >/dev/null 2>&1
exit 0
EOF
chmod +x files/etc/uci-defaults/99-wifi-fast
echo ">>> WiFi 首启优化完成"

# =====================================================
# 6. Docker 数据目录配置
# =====================================================
mkdir -p files/etc/config
mkdir -p files/etc/uci-defaults

cat > files/etc/config/fstab << 'EOF'
config global
	option anon_mount '1'
	option auto_mount '1'
	option auto_swap '1'

config mount
	option target '/mnt/mmcblk0p7'
	option device '/dev/mmcblk0p7'
	option fstype 'ext4'
	option options 'rw,sync,noatime'
	option enabled '1'
EOF

cat > files/etc/uci-defaults/30-docker << 'EOF'
#!/bin/sh
mkdir -p /mnt/mmcblk0p7/docker
uci set dockerd.globals.data_root='/mnt/mmcblk0p7/docker'
uci commit dockerd
/etc/init.d/dockerd enable
/etc/init.d/dockerd restart
exit 0
EOF
chmod +x files/etc/uci-defaults/30-docker
echo ">>> Docker 数据目录已优化"

# =====================================================
# 7. QModem 自动启用
# =====================================================
cat > files/etc/uci-defaults/88-qmodem << 'EOF'
#!/bin/sh
/etc/init.d/qmodem enable >/dev/null 2>&1
/etc/init.d/qmodem start >/dev/null 2>&1
exit 0
EOF
chmod +x files/etc/uci-defaults/88-qmodem
echo ">>> QModem 启用完成"

# =====================================================
# 8. 系统优化
# =====================================================
cat > files/etc/sysctl.conf << 'EOF'
net.core.default_qdisc=fq_codel
net.ipv4.tcp_congestion_control=bbr
EOF
echo ">>> 系统优化完成"

# =====================================================
# 9. ★ 强制覆盖 msd_lite init.d 为双后端版本 ★
#
# 官方 ximiTech/msd_lite 包自带的 init.d 只支持 msd_lite 单后端
# 我们的版本同时支持 msd_lite 和 rtp2httpd 两个后端切换
# 必须在编译前覆盖，否则官方版本会覆盖我们的脚本
# =====================================================
MSD_INIT="package/luci-app-msd_lite/files/etc/init.d/msd_lite"
mkdir -p "$(dirname $MSD_INIT)"

cat > "$MSD_INIT" << 'INITEOF'
#!/bin/sh /etc/rc.common

START=99
USE_PROCD=1

start_service() {
	local enable type port source threads buffer rejointime PROG

	config_load "msd_lite"
	config_get_bool enable "config" "enable" "0"
	[ "$enable" -eq "1" ] || return 0

	config_get type       "config" "type"        "0"
	config_get port       "config" "port"         "7088"
	config_get source     "config" "source"       "eth0"
	config_get threads    "config" "threads"      "0"
	config_get buffer     "config" "buffer"       "16384"
	config_get rejointime "config" "rejointime"   "0"

	mkdir -p /var/etc

	if [ "$type" = "0" ]; then
		PROG="/usr/bin/msd_lite"
		cat > /var/etc/msd_lite.conf << XMLEOF
<?xml version="1.0" encoding="utf-8"?>
<msd>
	<log><file>/var/log/msd_lite.log</file></log>
	<threadPool>
		<threadsCountMax>${threads}</threadsCountMax>
		<fBindToCPU>yes</fBindToCPU>
	</threadPool>
	<HTTP>
		<bindList>
			<bind><address>0.0.0.0:${port}</address></bind>
			<bind><address>[::]:${port}</address></bind>
		</bindList>
		<hostnameList><hostname>*</hostname></hostnameList>
	</HTTP>
	<hubProfileList>
		<hubProfile>
			<fDropSlowClients>no</fDropSlowClients>
			<fSocketTCPNoDelay>yes</fSocketTCPNoDelay>
			<precache>${buffer}</precache>
			<ringBufSize>1024</ringBufSize>
			<headersList>
				<header>Pragma: no-cache</header>
				<header>Content-Type: video/mpeg</header>
			</headersList>
		</hubProfile>
	</hubProfileList>
	<sourceProfileList>
		<sourceProfile>
			<skt>
				<rcvBuf>512</rcvBuf>
				<rcvTimeout>2</rcvTimeout>
			</skt>
			<multicast>
				<ifName>${source}</ifName>
				<rejoinTime>${rejointime}</rejoinTime>
			</multicast>
		</sourceProfile>
	</sourceProfileList>
</msd>
XMLEOF
	else
		PROG="/usr/bin/rtp2httpd"
		cat > /var/etc/msd_lite.conf << RTPEOF
[global]
verbosity = 3
upstream-interface = ${source}
workers = ${threads}
buffer-pool-max-size = ${buffer}
mcast-rejoin-interval = ${rejointime}
zerocopy-on-send = yes

[bind]
* ${port}
RTPEOF
	fi

	procd_open_instance
	procd_set_param command "$PROG" -c /var/etc/msd_lite.conf
	procd_set_param respawn
	procd_set_param stderr 1
	procd_close_instance
}

reload_service() {
	stop
	start
}

service_triggers() {
	procd_add_reload_trigger "msd_lite"
}
INITEOF

chmod +x "$MSD_INIT"
echo ">>> msd_lite 双后端 init.d 脚本已覆盖"

# =====================================================
# 10. Banner
# =====================================================
cat > files/etc/banner << 'EOF'

 __        ___   _  _____  ___   ___   ___
 \ \      / / | | ||___ / / _ \ / _ \ / _ \
  \ \ /\ / /| |_| |  |_ \| | | | | | | | | |
   \ V  V / |  _  | ___) | |_| | |_| | |_| |
    \_/\_/  |_| |_||____/ \___/ \___/ \___/

      WH3000 Optimized Build

EOF

echo "========================================"
echo " 所有优化完成"
echo " WiFi 2.4G : WH3000_2.4G / 12345678"
echo " WiFi 5G   : WH3000_5G   / 12345678"
echo " Docker    : /mnt/mmcblk0p7/docker"
echo " MSD Lite  : 双后端（msd_lite + rtp2httpd）"
echo "========================================"
