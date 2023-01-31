#
# Copyright (C) 2021 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=minim-ebpf
PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Brett Mastbergen <brettm@minim.com>
PKG_VERSION:=1.0

PKG_BUILD_DEPENDS:=bpf-headers
PKG_FLAGS:=nonshared

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/bpf.mk

define Package/minim-ebpf
  SECTION:=minim
  CATEGORY:=minim
  TITLE:=Test ebpf build
  DEPENDS:=+libbpf $(BPF_DEPENDS)
endef

define Build/Compile
	$(call CompileBPF,src/minim-ebpf.c)
endef

define Package/minim-ebpf/install
	$(INSTALL_DIR) $(1)/lib/bpf
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/minim-ebpf.o $(1)/lib/bpf
endef

$(eval $(call BuildPackage,minim-ebpf))
