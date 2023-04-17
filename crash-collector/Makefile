include $(TOPDIR)/rules.mk

PKG_NAME:=crash-collector
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/crash-collector
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Kernel crash log collector
endef

define Package/crash-collector/description
	Collects kernel crashlogs for later analysis
endef

define Build/Compile
endef

define Package/crash-collector/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) files/crash-collector.init $(1)/etc/init.d/crash-collector
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) files/upload_crash_to_s3.sh $(1)/sbin/upload_crash_to_s3.sh
endef

$(eval $(call BuildPackage,crash-collector))
