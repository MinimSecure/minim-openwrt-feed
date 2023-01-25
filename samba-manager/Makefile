#
# Copyright (C) 2022 minim.co
#

include $(TOPDIR)/rules.mk

PKG_NAME:=samba-manager
PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Brett Mastbergen <brettm@minim.com>
PKG_VERSION:=1.0

include $(INCLUDE_DIR)/package.mk

define Package/samba-manager
  SECTION:=minim
  CATEGORY:=Minim
  TITLE:=Samba management helper
  DEPENDS:=+blockd +kmod-usb-storage +kmod-usb-storage-uas \
           +kmod-fuse +kmod-fs-f2fs +kmod-fs-exfat \
           +kmod-fs-vfat +kmod-fs-ext4 +kmod-fs-ntfs \
           +kmod-fs-hfs +kmod-fs-hfsplus 
endef

define Package/samba-manager/description
  These scripts manage configuration of the samba4 server
  to automatically share usb connected storage drives
endef

define Build/Compile
endef

define Package/samba-manager/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/samba-manager.init $(1)/etc/init.d/samba-manager

	$(INSTALL_DIR) $(1)/etc/hotplug.d/mount
	$(INSTALL_BIN) ./files/10-samba-manager.hotplug $(1)/etc/hotplug.d/mount/10-samba-manager

endef

$(eval $(call BuildPackage,samba-manager))
