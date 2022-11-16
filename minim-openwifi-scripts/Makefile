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
	$(INSTALL_DATA) ./files/etc/uci-defaults/37_enable_flow_offloading $(1)/etc/uci-defaults

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/update_leds $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/initialize_leds $(1)/etc/init.d

	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) ./files/sbin/update_leds.sh $(1)/sbin
	$(INSTALL_BIN) ./files/sbin/leds.sh $(1)/sbin

	$(INSTALL_DIR) $(1)/etc/rc.button
	$(INSTALL_BIN) ./files/etc/rc.button/lights_toggle $(1)/etc/rc.button

endef

$(eval $(call BuildPackage,minim-openwifi-scripts))
