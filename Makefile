include theos/makefiles/common.mk
#export THEOS_DEVICE_IP = 192.168.2.2 put this in you .bash_profile
TWEAK_NAME = GuestAccount
GuestAccount_FILES = Tweak.xm
GuestAccount_FRAMEWORKS = UIKit

BUNDLE_NAME = GuestAccountResources
GuestAccountResources_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries

include $(THEOS)/makefiles/bundle.mk
include $(THEOS_MAKE_PATH)/tweak.mk
