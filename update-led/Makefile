#
# Copyright (C) 2010-2012 OpenWrt.org
#
# This Makefile and the code shipped in src/ is free software, licensed
# under the GNU Lesser General Public License, version 2.1 and later.
# See src/COPYING for more information.
#
# Refer to src/COPYRIGHT for copyright statements on the source files.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=minim-update-led
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

define Package/minim-update-led
  SECTION:=minim
  CATEGORY:=Minim
  TITLE:=General purpose update-led
endef

define Build/Compile
endef

define Package/minim-update-led/install
        $(INSTALL_DIR) $(1)/sbin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) led_minim.sh $(1)/sbin
	$(INSTALL_BIN) update_leds.sh $(1)/sbin
	$(INSTALL_BIN) update_leds $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) 03_leds $(1)/etc/uci-defaults	
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,minim-update-led))
