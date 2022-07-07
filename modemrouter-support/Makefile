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

PKG_NAME:=minim-modemrouter-support
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/minim-modemrouter-support
  SECTION:=minim
  CATEGORY:=Minim
  TITLE:=Modem/Router support files
  DEPENDS:=+libuci +libminimcommon
endef

define Package/minim-modemrouter-support/install
	$(INSTALL_DIR) $(1)/etc/rc.button
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/BTN_0 $(1)/etc/rc.button/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/update-cablestatus $(1)/etc/init.d/
endef

$(eval $(call BuildPackage,minim-modemrouter-support))
