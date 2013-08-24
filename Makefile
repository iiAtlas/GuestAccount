include theos/makefiles/common.mk

TWEAK_NAME = GuestAccount
GuestAccount_FILES = Tweak.xm GuestAccountManager.m GuestLockscreenViewController.m GuestSearchViewController.m
GuestAccount_FRAMEWORKS = UIKit

BUNDLE_NAME = GuestAccountResources
GuestAccountResources_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries

include $(THEOS)/makefiles/bundle.mk
include $(THEOS_MAKE_PATH)/tweak.mk
