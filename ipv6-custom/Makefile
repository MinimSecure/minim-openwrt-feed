#
# Copyright (C) 2010-2012 OpenWrt.org
# Modifications from original Copyright (C) 2022 Minim, Inc.
#
# This Makefile and the code shipped in src/ is free software, licensed
# under the GNU Lesser General Public License, version 2.1 and later.
# See src/COPYING for more information.
#
# Refer to src/COPYRIGHT for copyright statements on the source files.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=minim-ipv6-custom
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/minim-ipv6-custom
  SECTION:=minim
  CATEGORY:=Minim
  TITLE:=Customisations to openwrt defaults for ipv6
endef

define Build/Compile
endef

define Package/minim-ipv6-custom/install
	$(INSTALL_DIR)                            $(1)/etc/uci-defaults/
	$(INSTALL_BIN)  99_ipv6_custom            $(1)/etc/uci-defaults/
endef

$(eval $(call BuildPackage,minim-ipv6-custom))
