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

PKG_NAME:=libminimcommon
PKG_RELEASE:=8

PKG_LICENSE:=LGPL-2.1
PKG_LICENSE_FILES:=LICENSE

PKG_MAINTAINER:=Minim <team-embedded@minim.com>

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

define Package/libminimcommon
  SECTION:=minim
  CATEGORY:=Minim
  TITLE:=Minim common C code
endef

define Build/Configure
endef

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) -c $(PKG_BUILD_DIR)/minim_common.c -o $(PKG_BUILD_DIR)/minim_common.o -I$(PKG_BUILD_DIR)
	$(TARGET_CROSS)ar rcs $(PKG_BUILD_DIR)/libminimcommon.a $(PKG_BUILD_DIR)/minim_common.o
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib/libminimcommon/lib
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/libminimcommon.a $(1)/usr/lib/libminimcommon/lib/

	$(INSTALL_DIR) $(1)/usr/lib/libminimcommon/include
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/minim_common.h $(1)/usr/lib/libminimcommon/include/
endef

define Package/libminimcommon/install
	$(INSTALL_DIR) $(1)/tmp
	touch $(1)/tmp/.libminimcommon-placeholder
endef


$(eval $(call HostBuild))
$(eval $(call BuildPackage,libminimcommon))
