#
# Copyright (C) 2010-2012 OpenWrt.org
# Modifications from original Copyright (C) 2023 Minim, Inc.
#
# This Makefile and the code shipped in src/ is free software, licensed
# under the GNU Lesser General Public License, version 2.1 and later.
# See src/COPYING for more information.
#
# Refer to src/COPYRIGHT for copyright statements on the source files.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=minim-performance-tuning
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/minim-performance-tuning
  SECTION:=minim
  CATEGORY:=Minim
  TITLE:=Customisations to openwrt for performance tuning
endef

define Build/Compile
endef

define Package/minim-performance-tuning/install
	$(INSTALL_DIR)                                           $(1)/etc/hotplug.d/net/
	$(INSTALL_BIN)  99-smp-packet-steering-minim             $(1)/etc/hotplug.d/net/
	$(INSTALL_DIR)                                           $(1)/etc/uci-defaults/
	$(INSTALL_BIN)  99-smp-packet-steering-minim-defaults    $(1)/etc/uci-defaults/
endef
$(eval $(call BuildPackage,minim-performance-tuning))
