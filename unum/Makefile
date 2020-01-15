# Copyright 2018 Minim Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include $(TOPDIR)/rules.mk

PKG_NAME:=unum
PKG_VERSION:=2020.1.0
PKG_LICENSE:=Apache-2.0

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=v2020.1.0
PKG_SOURCE_URL:=https://github.com/MinimSecure/unum-sdk
PKG_SOURCE_SUBDIR:=unum-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_SOURCE_VERSION).tar.gz
PKG_MAINTAINER:=Minim Labs <labs@minim.co>

PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/unum
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Unum network management and monitoring agent
	URL:=https://www.minim.co
	MAINTAINER:=$(PKG_MAINTAINER)
	VERSION:=$(PKG_VERSION)
	DEPENDS:=+libpthread +librt +libuci +jansson +libiwinfo \
	         +libcurl +libmbedtls
endef

define Package/unum/description
	Unum is a software component allowing a wireless router to be managed and
	continuously monitored by the Minim cloud.
	See https://www.minim.co for more information.
endef

# Path to unum sources
PKG_BUILD_DIR_UNUM=$(PKG_BUILD_DIR)/src/unum
# Path to static files bundled with unum
PKG_BUILD_DIR_FILES=$(PKG_BUILD_DIR)/files

# Subdir where the agent sources are (where to cd to run make)
MAKE_PATH:=src/unum

# Platform (ie. MODEL) used to build the agent
# OpenWrt builds use linux_generic by default
AGENT_MODEL_ID=openwrt_generic

# Trusted CA list location on the target
AGENT_TRUSTED_CA_LIST=/etc/ssl/certs/unum-ca-certificates.crt

# Agent config folder on the target
AGENT_ETC_DIR=/etc/unum

# Agent version
AGENT_VERSION_NUMBER="$(PKG_VERSION)"

define Build/Configure
endef

define Build/Compile
	$(call Build/Compile/Default,\
	  AGENT_VERSION=$(patsubst "%",%,$(AGENT_VERSION_NUMBER))\
	  MODEL=$(AGENT_MODEL_ID) TARGET_OBJ="$(PKG_BUILD_DIR)/src"\
	  UNUM_DISABLE_TRACER=1)
endef

define Package/unum/install
	# Agent executable
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR_UNUM)/unum $(1)/usr/bin/
	# Agent configuration folder
	$(INSTALL_DIR) $(1)$(AGENT_ETC_DIR)
	$(INSTALL_DATA) $(PKG_BUILD_DIR_FILES)/linux_generic/etc/config.json $(1)$(AGENT_ETC_DIR)/config.json
	# Trusted certificates (install our own CA list)
	$(INSTALL_DIR) $(1)/etc/ssl/certs
	cat $(PKG_BUILD_DIR_FILES)/ca/*.pem > $(1)$(AGENT_TRUSTED_CA_LIST)
	# Agent init files
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR_FILES)/openwrt_generic/etc/unum.init $(1)/etc/init.d/unum
	$(INSTALL_DATA) $(PKG_BUILD_DIR_FILES)/openwrt_generic/etc/unum.common $(1)$(AGENT_ETC_DIR)/unum.common

	# Restart script
	$(INSTALL_DATA) $(PKG_BUILD_DIR_FILES)/openwrt_generic/restart_config.sh $(1)/usr/bin/restart_config.sh

	# Agent files to keep through the firmware upgrade
	$(INSTALL_DIR) $(1)/lib/upgrade/keep.d
	echo "/etc/unum/unum.pem" > $(1)/lib/upgrade/keep.d/unum.upgrade
	echo "/etc/unum/unum.key" >> $(1)/lib/upgrade/keep.d/unum.upgrade
	echo "/etc/unum/config.json" >> $(1)/lib/upgrade/keep.d/unum.upgrade
	echo "/etc/unum/.credentials_provisioned" >> $(1)/lib/upgrade/keep.d/unum.upgrade
	echo "/etc/unum/.wifi_provisioned" >> $(1)/lib/upgrade/keep.d/unum.upgrade
endef

$(eval $(call BuildPackage,unum))
