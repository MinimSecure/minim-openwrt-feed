include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=uleds
PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Brett Mastbergen <brettm@minim.com>

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel-defaults.mk

define KernelPackage/uleds
  SUBMENU:=LED modules
  TITLE:= Backported uleds driver
  DEPENDS:=
  FILES:=$(PKG_BUILD_DIR)/uleds.ko
  AUTOLOAD:=$(call AutoLoad,30,uleds)
  KCONFIG:=
endef

define KernelPackage/uleds/description
  This is the uleds led class driver backported from 4.10
endef

define Build/Compile
	$(KERNEL_MAKE) M="$(PKG_BUILD_DIR)" modules
endef

$(eval $(call KernelPackage,uleds))
