local sys = require "luci.sys"
local uci = require "luci.model.uci".cursor()

m = Map("msd_lite", "RTP/UDP/RTSP IPTV Server",
    translate("Multi Stream daemon (msd) / rtp2httpd for IPTV streaming on the network via HTTP"))

m:section(SimpleSection).template = "msd_lite/msdlite_status"

-- =====================
-- MSD Lite / 公共设置
-- =====================
s = m:section(TypedSection, "msd_lite", translate("MSD Lite 设置"))
s.addremove = false
s.anonymous = true

enable = s:option(Flag, "enable", translate("启用"))
enable.rmempty = false

type = s:option(ListValue, "type", translate("主程序选择"))
type:value("0", translate("MSD Lite"))
type:value("1", translate("rtp2httpd"))
type.default = "0"

-- MSD Lite 专用选项（type=0 时显示）
port = s:option(Value, "port", translate("端口"))
port.datatype = "port"
port.default = "7088"
port.rmempty = false
port:depends("type", "0")

source = s:option(Value, "source", translate("上游 VLAN 接口"))
source.default = "eth0"
source.rmempty = false
source:depends("type", "0")
for _, e in ipairs(sys.net.devices()) do
    if e ~= "lo" then source:value(e) end
end

threads = s:option(Value, "threads", translate("最大 CPU 并发线程"))
threads.default = "0"
threads.rmempty = false
threads:value("0", translate("自动（CPU 线程数）"))
threads:value("1")
threads:value("2")
threads:value("3")
threads:value("4")
threads.description = translate("0 = 自动")
threads:depends("type", "0")

buffer = s:option(Value, "buffer", translate("缓存大小"))
buffer.default = "16384"
buffer.rmempty = false
buffer:depends("type", "0")

rejointime = s:option(Value, "rejointime", translate("IGMP 重新协商时间（秒）"))
rejointime.default = "0"
rejointime.rmempty = true
rejointime.datatype = "uinteger"
rejointime.description = translate("0 = 关闭")
rejointime:depends("type", "0")

-- =====================
-- rtp2httpd 专用选项（type=1 时显示）
-- 直接读写 /etc/config/rtp2httpd
-- =====================
r = m:section(TypedSection, "msd_lite", translate("rtp2httpd 设置"))
r.addremove = false
r.anonymous = true

-- 提示说明
hint = r:option(DummyValue, "_hint", "")
hint.rawhtml = true
hint.default = "<div style='color:#888;padding:4px 0'>" ..
    translate("以下配置写入 /etc/config/rtp2httpd，选择 rtp2httpd 模式时生效") ..
    "</div>"
hint:depends("type", "1")

-- 映射 rtp2httpd UCI 配置
local r2 = Map("rtp2httpd")
local rs = r2:section(TypedSection, "rtp2httpd")
rs.addremove = false
rs.anonymous = true

rport = rs:option(Value, "port", translate("端口"))
rport.datatype = "port"
rport.default = "5140"
rport.placeholder = "5140"

riface = rs:option(Value, "upstream_interface", translate("上游接口"))
riface.default = "eth0"
for _, e in ipairs(sys.net.devices()) do
    if e ~= "lo" then riface:value(e) end
end

rmaxclients = rs:option(Value, "maxclients", translate("最大客户端数"))
rmaxclients.datatype = "uinteger"
rmaxclients.placeholder = "5"

rworkers = rs:option(Value, "workers", translate("Worker 线程数"))
rworkers.datatype = "uinteger"
rworkers.placeholder = "1"

rbuffer = rs:option(Value, "buffer_pool_max_size", translate("缓冲区大小"))
rbuffer.datatype = "uinteger"
rbuffer.placeholder = "16384"

rplayer = rs:option(Value, "player_page_path", translate("内置播放器路径"))
rplayer.placeholder = "/player"

rstatus = rs:option(Value, "status_page_path", translate("状态页面路径"))
rstatus.placeholder = "/status"

rm3u = rs:option(Value, "external_m3u", translate("外部 M3U 播放源地址"))
rm3u.placeholder = "https://example.com/playlist.m3u"

rm3u_interval = rs:option(Value, "external_m3u_update_interval", translate("M3U 更新间隔（秒）"))
rm3u_interval.datatype = "uinteger"
rm3u_interval.placeholder = "7200"

rrejoin = rs:option(Value, "mcast_rejoin_interval", translate("组播重新加入间隔"))
rrejoin.datatype = "uinteger"
rrejoin.placeholder = "0"

rtoken = rs:option(Value, "r2h_token", translate("访问令牌"))
rtoken.placeholder = "留空则不需要认证"
rtoken.password = true

rzcopy = rs:option(Flag, "zerocopy_on_send", translate("启用零拷贝发送"))

return m
