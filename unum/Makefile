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
PKG_VERSION:=2018.1.0
PKG_RELEASE:=1
PKG_LICENSE:=Apache-2.0

PKG_SOURCE:=v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/MinimSecure/unum-sdk/archive/
PKG_MAINTAINER:=Minim Labs <labs@minim.co>

include $(INCLUDE_DIR)/package.mk

define Package/unum
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Unum agent
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
AGENT_MODEL_ID=linux_generic

# Agent config folder on the target
AGENT_ETC_DIR=/etc/unum

# Agent version
AGENT_VERSION_NUMBER="$PKG_VERSION"

define Build/Prepare
	$(PKG_UNPACK)
	cp -f --remove-destination files/unum-linux_generic.mk $(PKG_BUILD_DIR)/src/unum/unum-linux_generic.mk
	mkdir -p $(PKG_BUILD_DIR_FILES)/linux_generic
	cp -f --remove-destination files/unum.common $(PKG_BUILD_DIR_FILES)/linux_generic/unum.common
	cp -f --remove-destination files/unum.init $(PKG_BUILD_DIR_FILES)/linux_generic/unum.init
endef

define Build/Configure
endef

define Build/Compile
	$(call Build/Compile/Default,\
	  AGENT_VERSION=$(patsubst "%",%,$(AGENT_VERSION_NUMBER))\
	  MODEL=$(AGENT_MODEL_ID) TARGET_OBJ="$(PKG_BUILD_DIR)/src")\
	  INSTALL_EXTRAS=no
endef

define Package/unum/install
	# Agent executable
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR_UNUM)/unum $(1)/usr/bin/
	# Agent configuration folder
	$(INSTALL_DIR) $(1)$(AGENT_ETC_DIR)
	# Agent init files
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR_FILES)/linux_generic/unum.init $(1)/etc/init.d/unum
	$(INSTALL_DATA) $(PKG_BUILD_DIR_FILES)/linux_generic/unum.common $(1)$(AGENT_ETC_DIR)/unum.common
	# Agent files to keep through the firmware upgrade
	$(INSTALL_DIR) $(1)/lib/upgrade/keep.d
	echo "/etc/unum/unum.pem" > $(1)/lib/upgrade/keep.d/unum.upgrade
	echo "/etc/unum/unum.key" >> $(1)/lib/upgrade/keep.d/unum.upgrade
	echo "$(AGENT_USER_CONF)" >> $(1)/lib/upgrade/keep.d/unum.upgrade
	echo "/etc/unum/.credentials_provisioned" >> $(1)/lib/upgrade/keep.d/unum.upgrade
	echo "/etc/unum/.wifi_provisioned" >> $(1)/lib/upgrade/keep.d/unum.upgrade
endef

$(eval $(call BuildPackage,unum))
