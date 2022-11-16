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

PKG_NAME:=minim-web-landing
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

define Package/minim-web-landing
  SECTION:=minim
  CATEGORY:=Minim
  TITLE:=General purpose web-landing
endef

define Build/Compile
endef

define Package/minim-web-landing/install
	$(INSTALL_DIR)                           $(1)/www
	$(INSTALL_DATA) GothamSSm-Bold.otf	     $(1)/www
	$(INSTALL_DATA) GothamSSm-Light.otf	     $(1)/www
	$(INSTALL_DATA) index.provisioned.html   $(1)/www
	$(INSTALL_DATA) index.unprovisioned.html $(1)/www
	$(INSTALL_DATA) Makefile			     $(1)/www
	$(INSTALL_DATA) moto-sync-logo.png	     $(1)/www
	$(INSTALL_DATA) qr-code.png $(1)/www
	$(INSTALL_DATA) arrow-icon.png $(1)/www
	$(INSTALL_DIR)                           $(1)/www/styles
	$(INSTALL_DATA) styles/style.css         $(1)/www/styles/

	$(INSTALL_DIR)                            $(1)/etc/uci-defaults/
	$(INSTALL_BIN)  31_update_www_landing     $(1)/etc/uci-defaults/
	$(INSTALL_BIN)  31_update_www_provisioned $(1)/etc/uci-defaults/
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,minim-web-landing))
