#
# Copyright (C) 2010-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=q14-uled-driver
PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Brett Mastbergen <brettm@minim.com>
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/q14-uled-driver
  SECTION:=minim
  CATEGORY:=Minim
  DEPENDS:=+kmod-uleds +coreutils-stty
  TITLE:=q14 userspace led driver
  MAINTAINER:=Brett Mastbergen <brettm@minim.com>
  PKGARCH:=all
endef

define Package/q14-uled-driver/description
  A userspace led driver for the Motorola Q14 utilizing
  the uleds led class driver
endef

define Build/Configure
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -Wall" \
		LDFLAGS="$(TARGET_LDFLAGS)"
endef

define Package/q14-uled-driver/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/q14-uled-driver  $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/q14-uled-driver.init $(1)/etc/init.d/q14-uled-driver
endef

$(eval $(call BuildPackage,q14-uled-driver))
