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
PKG_LICENSE:=Apache-2.0

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=f3e9da1dcdcdb3018e266f8a5542cd572d675bcf
PKG_MIRROR_HASH:=a0027decf7a2db59e330b2df71e7241fe9589b0caace3633d2b11f81f808a4ce
PKG_SOURCE_URL:=https://github.com/MinimSecure/unum-sdk
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
		 +libcurl +libmbedtls +libnl-tiny +zlib
endef

define Package/unum/description
	Unum is a software component allowing a wireless router to be managed and
	continuously monitored by the Minim cloud.
	See https://www.minim.co for more information.
endef

# Platform (ie. MODEL) used to build the agent
AGENT_MODEL_ID=lede_generic

# Agent hardware ID for this particular hardware target/subtarget/device
ifeq ($(patsubst "%",%,$(CONFIG_VERSION_HWREV)),)
  ifeq ($(patsubst "%",%,$(CONFIG_VERSION_PRODUCT)),)
    AGENT_HARDWARE_ID=openwrt_generic
  else
    AGENT_HARDWARE_ID=$(patsubst "%",%,$(CONFIG_VERSION_PRODUCT))
  endif
else
  AGENT_HARDWARE_ID=$(patsubst "%",%,$(CONFIG_VERSION_PRODUCT))_$(patsubst "%",%,$(CONFIG_VERSION_HWREV))
endif

define Build/Configure
endef

MAKE_FLAGS += \
	TARGET_CFLAGS="$(TARGET_CFLAGS) \
	-I$(STAGING_DIR)/usr/include/libnl-tiny \
	$(TARGET_CPPFLAGS) -Wno-array-bounds \
	-DAGENT_VERSION_IS_FW_VERSION \
	-DCONFIG_LIBNL20" \
	TARGET_LDFLAGS="$(TARGET_LDFLAGS)" \
	MODEL=$(AGENT_MODEL_ID) HARDWARE=$(AGENT_HARDWARE_ID) \
	TARGET_OBJ="$(PKG_BUILD_DIR)/src"


define Package/unum/install
	# untar the unum rootfs into the package install dir
	tar -zxvf $(PKG_BUILD_DIR)/out/$(AGENT_MODEL_ID)/$(AGENT_MODEL_ID)*.tgz -C $(1) > /dev/null

	# Installing properties.json to rootfs under /etc/unum to avoid
	# dealing with owrt build folders (although we do not need it on target)
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/out/$(AGENT_MODEL_ID)/release_properties.json $(1)/etc/unum/release_properties.json
endef

$(eval $(call BuildPackage,unum))
