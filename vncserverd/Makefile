ARCHS=arm64
TARGET=iphone:latest:9.0

include $(THEOS)/makefiles/common.mk

TOOL_NAME = vncserverd
vncserverd_FILES = $(wildcard ../vncforios/*.m) memory_limit.m
vncserverd_FRAMEWORKS = IOMobileFramebuffer IOSurface IOKit
vncserverd_CFLAGS = -I../include -Wno-deprecated-declarations
vncserverd_LDFLAGS = -L../lib -F../privateframeworks -lssl -lcrypto -lvncserverstatic -ljpeg -lpng
vncserverd_INSTALL_PATH=/usr/libexec/
vncserverd_CODESIGN_FLAGS = -S../entitlements.plist

include $(THEOS_MAKE_PATH)/tool.mk
