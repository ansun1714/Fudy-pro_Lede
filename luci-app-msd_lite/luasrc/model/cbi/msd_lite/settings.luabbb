local sys = require "luci.sys"

m = Map("msd_lite", "RTP/UDP/RTSP IPTV Server",
    translate("Multi Stream daemon (msd) / rtp2httpd，将 IPTV 流转换为 HTTP 协议服务器"))

m:section(SimpleSection).template = "msd_lite/msdlite_status"

s = m:section(NamedSection, "config", "msd_lite", translate("基本设置"))
s.addremove = false
s.anonymous = false

-- 启用开关
enable = s:option(Flag, "enable", translate("启用"))
enable.rmempty = false

-- 主程序选择
type = s:option(ListValue, "type", translate("主程序选择"))
type:value("0", translate("MSD Lite"))
type:value("1", translate("rtp2httpd"))
type.default = "0"

-- ===========================
-- MSD Lite 专用选项（type=0）
-- ===========================
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

threads = s:option(ListValue, "threads", translate("最大 CPU 并发线程"))
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

-- ===========================
-- rtp2httpd 专用选项（type=1）
-- 配置存在 msd_lite UCI 里，init.d 读取后以命令行参数传给 rtp2httpd
-- ===========================
rtp_port = s:option(Value, "rtp_port", translate("端口"))
rtp_port.datatype = "port"
rtp_port.default = "5140"
rtp_port.placeholder = "5140"
rtp_port:depends("type", "1")

rtp_source = s:option(Value, "rtp_source", translate("上游接口"))
rtp_source.default = "eth0"
rtp_source:depends("type", "1")
for _, e in ipairs(sys.net.devices()) do
    if e ~= "lo" then rtp_source:value(e) end
end

rtp_workers = s:option(Value, "rtp_workers", translate("Worker 线程数"))
rtp_workers.datatype = "uinteger"
rtp_workers.default = "1"
rtp_workers.placeholder = "1"
rtp_workers:depends("type", "1")

rtp_maxclients = s:option(Value, "rtp_maxclients", translate("最大客户端数"))
rtp_maxclients.datatype = "uinteger"
rtp_maxclients.placeholder = "5"
rtp_maxclients:depends("type", "1")

rtp_buffer = s:option(Value, "rtp_buffer", translate("缓冲区大小"))
rtp_buffer.datatype = "uinteger"
rtp_buffer.default = "16384"
rtp_buffer.placeholder = "16384"
rtp_buffer:depends("type", "1")

rtp_player = s:option(Value, "rtp_player_path", translate("内置播放器路径"))
rtp_player.placeholder = "/player"
rtp_player:depends("type", "1")

rtp_status = s:option(Value, "rtp_status_path", translate("状态页面路径"))
rtp_status.placeholder = "/status"
rtp_status:depends("type", "1")

rtp_m3u = s:option(Value, "rtp_external_m3u", translate("外部 M3U 播放源地址"))
rtp_m3u.placeholder = "https://example.com/playlist.m3u"
rtp_m3u:depends("type", "1")

rtp_rejoin = s:option(Value, "rtp_mcast_rejoin", translate("组播重新加入间隔（秒）"))
rtp_rejoin.datatype = "uinteger"
rtp_rejoin.default = "0"
rtp_rejoin.placeholder = "0"
rtp_rejoin:depends("type", "1")

rtp_token = s:option(Value, "rtp_token", translate("访问令牌"))
rtp_token.placeholder = translate("留空则不需要认证")
rtp_token.password = true
rtp_token:depends("type", "1")

rtp_zerocopy = s:option(Flag, "rtp_zerocopy", translate("启用零拷贝发送"))
rtp_zerocopy:depends("type", "1")

return m
