include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-msd_lite
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0

LUCI_TITLE:=IPTV RTP/UDP/RTSP Server (MSD Lite + rtp2httpd)
LUCI_DEPENDS:=+msd_lite +rtp2httpd

include $(TOPDIR)/feeds/luci/luci.mk

$(eval $(call BuildPackage,luci-app-msd_lite))
