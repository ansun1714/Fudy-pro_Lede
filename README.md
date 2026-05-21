# WH3000 / WH3000 Pro LEDE 固件自动编译

适用于：

- Huasifei WH3000
- Huasifei WH3000 Pro

基于 LEDE 自动化 GitHub Actions 云编译。

支持：

- Docker
- QModem
- Lucky
- MSD Lite IPTV
- Design 主题
- Wi-Fi 极速启动优化
- 自动 Release 发布
- 多设备型号选择

---

# 项目特点

本仓库针对 MT7981 平台进行了专项优化：

## Wi-Fi 极速启动优化

针对：

- MT7981
- 华思飞 WH3000 系列

进行了：

- 无线预配置
- 首次启动跳过无线重生成
- MTK Wi-Fi 模块预加载
- 减少 Wi-Fi 延迟初始化

解决：

- 首次刷机 Wi-Fi 很久才出现
- 无线初始化慢
- 首启无线卡死

问题。

---

# Docker 优化

已适配：

```bash
/mnt/mmcblk0p7/docker
支持：
Docker 数据目录自动迁移
自动挂载 emmc 分区
避免 overlay 空间爆满
QModem 优化
支持：
QModem
SMS
TTL
移动拨号
首次刷机自动启用。
IPTV
集成：
MSD Lite IPTV
相比传统 rtp2httpd：
更轻量
更稳定
更适合 MT7981
默认插件
已集成：
Lucky
Docker
MSD Lite
UPnP
WOL
BBR
FullCone NAT
中文界面
Design 主题
固件源码
本项目基于：
Lean's LEDE Source
源码仓库：
https://github.com/coolsnowwolf/lede⁠�
Release：
https://github.com/coolsnowwolf/lede/releases⁠�
致谢
感谢：
Lean
coolsnowwolf
OpenWrt
sirpdboy
OpenWrt 社区
以及所有插件作者。
