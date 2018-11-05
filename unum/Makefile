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
PKG_VERSION:=v2
PKG_RELEASE:=0
PKG_LICENSE:=Apache-2.0

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/MinimSecure/unum-sdk
PKG_SOURCE_VERSION:=master
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

# Path where we store sources and file in the LEDE build tree (making it the
# same as in our build system tree)
PKG_BUILD_DIR_UNUM=$(PKG_BUILD_DIR)/src/unum
PKG_BUILD_DIR_FILES=$(PKG_BUILD_DIR)/files

# Subdir where the agent sources are (where to cd to run make)
MAKE_PATH:=src/unum

# Agent MODEL name for all the unum agent builds
AGENT_MODEL_ID=linux_generic

# Trusted CA list location on the target
AGENT_TRUSTED_CA_LIST=/etc/ssl/certs/unum-ca-certificates.crt
# Agent config folder on the target
AGENT_ETC_DIR=/etc/unum
# Agent system config on the target
AGENT_SYSTEM_CONF=$(AGENT_ETC_DIR)/system.conf
# Agent user config on the target
AGENT_USER_CONF=$(AGENT_ETC_DIR)/user.conf

# Agent version. This is based on time if just the agent package is
# built. The normal firmware build overrides this w/ its version number.
ifeq ($(MINIM_VERSION_NUMBER),)
  AGENT_VERSION_NUMBER=$(shell date +"%y%m%d.%H%M.%S.0" | sed -E 's/\b0+([1-9][0-9]*)\b/\1/g')
else
  AGENT_VERSION_NUMBER=$(MINIM_VERSION_NUMBER)
endif

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
	  MODEL=$(AGENT_MODEL_ID) TARGET_OBJ="$(PKG_BUILD_DIR)/src")
endef

define Package/unum/install
	# Agent executable
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR_UNUM)/unum $(1)/usr/bin/
	# Agent configuration folder
	$(INSTALL_DIR) $(1)$(AGENT_ETC_DIR)
	# Trusted certificates (install our own CA list)
	$(INSTALL_DIR) $(1)/etc/ssl/certs
	cat $(PKG_BUILD_DIR_FILES)/ca/*.pem > $(1)$(AGENT_TRUSTED_CA_LIST)
	# Default agent config file
	echo "export UNUM_CA_FILE=$(AGENT_TRUSTED_CA_LIST)" > $(1)$(AGENT_SYSTEM_CONF)
	echo "export UNUM_PID_FILE_PREFIX=/var/run/unum" >> $(1)$(AGENT_SYSTEM_CONF)
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
