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

PKG_NAME:=minim-web-admin
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include -ggdb -I$(PKG_BUILD_DIR)/../libminimcommon -Wall
TARGET_LDFLAGS += -L$(STAGING_DIR)/usr/lib -L$(PKG_BUILD_DIR)/../libminimcommon
TARGET_LDLIBS += -lcrypt -lminimcommon

define Package/minim-web-admin
  SECTION:=minim
  CATEGORY:=Minim
  TITLE:=CGI based admin tool
  DEPENDS:=+libminimcommon
endef

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) -c src/web_admin.c -o $(PKG_BUILD_DIR)/web_admin.o
	$(TARGET_CC) $(TARGET_LDFLAGS) $(PKG_BUILD_DIR)/web_admin.o $(TARGET_LDLIBS) -o $(PKG_BUILD_DIR)/web_admin
endef

define Package/minim-web-admin/install
	$(INSTALL_DIR) $(1)/www/cgi-bin/luci/admin/minim
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/web_admin $(1)/www/cgi-bin/luci/admin/minim
	$(LN) --symbolic --relative $(1)/www/cgi-bin/luci/admin/minim/web_admin $(1)/www/cgi-bin/luci/admin/minim/unprov
	$(LN) --symbolic --relative $(1)/www/cgi-bin/luci/admin/minim/web_admin $(1)/www/cgi-bin/luci/admin/minim/start_sshd
	$(LN) --symbolic --relative $(1)/www/cgi-bin/luci/admin/minim/web_admin $(1)/www/cgi-bin/luci/admin/minim/enable_sshd
	$(INSTALL_BIN) mode_check $(1)/www/cgi-bin/luci/admin/minim
	$(INSTALL_DATA) enable_sshd.html $(1)/www
	$(INSTALL_DATA) start_sshd.html $(1)/www
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,minim-web-admin))
