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

PKG_NAME:=minim-web-landing-modemrouter
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

define Package/minim-web-landing-modemrouter
  SECTION:=minim
  CATEGORY:=Minim
  TITLE:=General purpose web-landing for cable modem routers
  DEPENDS:=+minim-web-landing
endef

define Build/Compile
endef

define Package/minim-web-landing/install
	mv $(1)/www/index.provisioned.html /tmp
	sed -e 's+<!-- Placeholder -->+<div class="card metadata-card" style="margin-top: 16px;"><a href="https://192.168.100.1" class="paragraph">Cable Modem Management</a></div>+' < /tmp/index.provisioned.html >$(1)/www/index.provisioned.html
	rm -f /tmp/index.provisioned.html
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,minim-web-landing))
