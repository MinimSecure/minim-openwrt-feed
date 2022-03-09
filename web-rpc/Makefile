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

PKG_NAME:=minim-web-rpc
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include -ggdb -I$(PKG_BUILD_DIR)/../libminimcommon -Wall
TARGET_LDFLAGS += -L$(STAGING_DIR)/usr/lib -L$(PKG_BUILD_DIR)/../libminimcommon
TARGET_LDLIBS += -lcrypt -luci -lminimcommon

define Package/minim-web-rpc
  SECTION:=minim
  CATEGORY:=Minim
  TITLE:=Replacement for rpcd-mod-luci
  DEPENDS:=+libuci +libminimcommon
endef

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) -c src/web_rpc.c -o $(PKG_BUILD_DIR)/web_rpc.o
	$(TARGET_CC) $(TARGET_LDFLAGS) $(PKG_BUILD_DIR)/web_rpc.o $(TARGET_LDLIBS) -o $(PKG_BUILD_DIR)/web_rpc
endef

define Package/minim-web-rpc/install
	$(INSTALL_DIR) $(1)/www/cgi-bin/luci/rpc
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/web_rpc $(1)/www/cgi-bin/luci/rpc
	$(LN) --symbolic --relative $(1)/www/cgi-bin/luci/rpc/web_rpc $(1)/www/cgi-bin/luci/rpc/auth
	$(LN) --symbolic --relative $(1)/www/cgi-bin/luci/rpc/web_rpc $(1)/www/cgi-bin/luci/rpc/uci
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) luci/modules/luci-base/root/sbin/luci-reload $(1)/sbin
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) 15_default_no_lua $(1)/etc/uci-defaults
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,minim-web-rpc))
