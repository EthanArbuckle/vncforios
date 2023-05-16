ARCHS=arm64
TARGET=iphone:latest:9.0

THEOS_PACKAGE_INSTALL_PREFIX = "/fs/jb/"

include $(THEOS)/makefiles/common.mk

TOOL_NAME = vncserverd
vncserverd_FILES = $(wildcard ../vncforios/*.m) memory_limit.m
vncserverd_FRAMEWORKS = IOMobileFramebuffer IOSurface IOKit
vncserverd_CFLAGS = -I../include -Wno-deprecated-declarations -Wno-unguarded-availability
vncserverd_LDFLAGS = -L../lib -F../privateframeworks  -lcrypto -ljpeg -lpng -lssl -Wl,-w -lvncserverstatic
vncserverd_INSTALL_PATH=/fs/jb/usr/libexec/
vncserverd_CODESIGN_FLAGS = -S../entitlements.plist

include $(THEOS_MAKE_PATH)/tool.mk
