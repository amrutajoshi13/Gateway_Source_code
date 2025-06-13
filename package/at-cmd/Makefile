#
# Copyright (C) 2019 Dino Tse <dinotse45@hotmail.com>
#

include $(TOPDIR)/rules.mk

PKG_NAME:=at-cmd
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)


include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

define Package/at-cmd
  SECTION:=Extra packages
  CATEGORY:=Extra packages
  TITLE:=4G Module AT Command
endef

define Package/at-cmd/description
  An program to query info
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Configure
endef

define Package/at-cmd/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/at-cmd $(1)/bin
endef


$(eval $(call BuildPackage,at-cmd))

