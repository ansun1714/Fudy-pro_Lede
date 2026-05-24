lmodule("luci.controller.msd_lite", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/msd_lite") then
        return
    end
    entry({"admin", "services", "msd_lite"},
        alias("admin", "services", "msd_lite", "general"),
        _("IPTV RTP/UDP/RTSP"), 80)
    entry({"admin", "services", "msd_lite", "general"},
        cbi("msd_lite/settings"), _("基本设置"), 1)
    entry({"admin", "services", "msd_lite", "status"},
        call("status")).leaf = true
end

function status()
    local uci  = require "luci.model.uci".cursor()
    local type = uci:get_first("msd_lite", "msd_lite", "type") or "0"
    local port = tonumber(uci:get_first("msd_lite", "msd_lite", "port")) or 7088
    local rport= tonumber(uci:get_first("msd_lite", "msd_lite", "rtp_port")) or 5140

    local e = {}

    if type == "0" then
        -- MSD Lite 模式：检测 msd_lite 进程
        e.running = luci.sys.call(
            "busybox ps -w | grep 'msd_lite' | grep -v grep >/dev/null") == 0
        e.rtp = false
        e.port = port
    else
        -- rtp2httpd 模式：检测 rtp2httpd 进程
        e.running = luci.sys.call(
            "busybox ps -w | grep 'rtp2httpd' | grep -v grep >/dev/null") == 0
        e.rtp = e.running
        e.port = rport
    end

    luci.http.prepare_content("application/json")
    luci.http.write_json(e)
end
