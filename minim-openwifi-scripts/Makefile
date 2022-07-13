#
# Copyright (C) 2022 minim.co
#

include $(TOPDIR)/rules.mk

PKG_NAME:=minim-openwifi-scripts
PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Brett Mastbergen <brettm@minim.com>
PKG_VERSION:=1.0

include $(INCLUDE_DIR)/package.mk

define Package/minim-openwifi-scripts
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Openwifi Support Scripts
endef

define Package/unum/description
  These are scripts necessary to tweak openwifi for Minim products
endef


define Build/Compile
endef

define Package/minim-openwifi-scripts/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DATA) ./files/etc/uci-defaults/34_drop_wan_input $(1)/etc/uci-defaults
	$(INSTALL_DATA) ./files/etc/uci-defaults/35_disable_maverick $(1)/etc/uci-defaults
	$(INSTALL_DATA) ./files/etc/uci-defaults/36_disable_firstcontact_config $(1)/etc/uci-defaults

endef

$(eval $(call BuildPackage,minim-openwifi-scripts))
