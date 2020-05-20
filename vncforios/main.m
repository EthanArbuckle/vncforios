//
//  Created by ethanarbuckle.
//  Copyright © ethanarbuckle. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <objc/message.h>
#include "external.h"
#include "hid.h"

static IOSurfaceRef remoteSurface;
static IOSurfaceRef fullsizeSurface;
static rfbScreenInfoPtr _remote_screen = NULL;
static CGSize displaySize;
static CGSize scaledDisplaySize;
static CGFloat displayScale = 0.4;
static CFStringRef displayName;
static IOSurfaceAcceleratorRef accelerator;

static enum rfbNewClientAction vnc_client_new(rfbClientPtr client) {
    return RFB_CLIENT_ACCEPT;
}

static rfbBool vnc_check_password(rfbClientPtr client, const char *data, int size) {
    return 1;
}

void create_vnc_server() {
    int BytesPerPixel = 4;
    int BitsPerSample = 8;

    int argc = 1;
    char *arg0 = strdup("vncforios");
    char *argv[] = {arg0, NULL};
        
    _remote_screen = rfbGetScreen(&argc, argv, scaledDisplaySize.width, scaledDisplaySize.height, BitsPerSample, 3, BytesPerPixel);
    free(arg0);

    _remote_screen->desktopName = [[[UIDevice currentDevice] name] UTF8String];
    _remote_screen->alwaysShared = YES;
    _remote_screen->handleEventsEagerly = YES;
    _remote_screen->deferUpdateTime = 0;
    _remote_screen->serverFormat.redShift = BitsPerSample * 2;
    _remote_screen->serverFormat.greenShift = BitsPerSample * 1;
    _remote_screen->serverFormat.blueShift = BitsPerSample * 0;
    NSDictionary *properties = @{
        (__bridge NSString *)kIOSurfaceIsGlobal:@YES,
        (__bridge NSString *)kIOSurfaceBytesPerElement:@(4),
        (__bridge NSString *)kIOSurfaceBytesPerRow:@(scaledDisplaySize.width * BytesPerPixel),
        (__bridge NSString *)kIOSurfaceWidth:@(scaledDisplaySize.width),
        (__bridge NSString *)kIOSurfaceHeight:@(scaledDisplaySize.height),
        (__bridge NSString *)kIOSurfacePixelFormat:@(0x42475241), 
        (__bridge NSString *)kIOSurfaceAllocSize:@(scaledDisplaySize.width * scaledDisplaySize.height * BytesPerPixel)
    };
    
    remoteSurface = IOSurfaceCreate((__bridge CFDictionaryRef)properties);
    assert(remoteSurface != NULL);
    
    _remote_screen->frameBuffer = IOSurfaceGetBaseAddress(remoteSurface);
    _remote_screen->kbdAddEvent = &VNCKeyboard;
    _remote_screen->ptrAddEvent = &VNCPointerNew;
    _remote_screen->newClientHook = &vnc_client_new;
    _remote_screen->passwordCheck = &vnc_check_password;
    _remote_screen->cursor = NULL;

    _remote_screen->socketState = RFB_SOCKET_INIT;
    rfbInitServer(_remote_screen);
    rfbRunEventLoop(_remote_screen, -1, true);
}

void draw(void) {
    
    IOSurfaceLock(fullsizeSurface, 0, nil);
    CARenderServerRenderDisplay(0, displayName, fullsizeSurface, 0, 0);
    IOSurfaceUnlock(fullsizeSurface, 0, 0);
    
    IOSurfaceLock(remoteSurface, 0, nil);
    IOSurfaceAcceleratorTransferSurface(accelerator, fullsizeSurface, remoteSurface, NULL,  NULL);
    IOSurfaceUnlock(remoteSurface, 0, 0);
    
    rfbMarkRectAsModified(_remote_screen, 0, 0, scaledDisplaySize.width, scaledDisplaySize.height);
}


@interface VncSurfaceDrawer : NSObject
@end
@implementation VncSurfaceDrawer

- (void)draw {
    draw();
}

@end

int main(int argc, const char *argv[]) {
        
    @autoreleasepool {
        
        id mainDisplay = ((id (*)(id, SEL))objc_msgSend)(objc_getClass("CADisplay"), sel_registerName("mainDisplay"));

        displayName = ((CFStringRef (*)(id, SEL))objc_msgSend)(mainDisplay, sel_registerName("name"));
        displaySize = ((CGRect (*)(id, SEL))objc_msgSend)(mainDisplay, sel_registerName("frame")).size;
        
        // Determine scaled size. Needs to be multiple of 4
        int (^roundToMultiple)(int, int) = ^int(int source, int multiple) {
            int remainder = source % multiple;
            if (remainder == 0)
                return source;

            return source + multiple - remainder;
        };
        int proposedWidth = roundToMultiple(displaySize.width * displayScale, 4);
        int proposedHeight = roundToMultiple(displaySize.height * displayScale, 4);
        
        scaledDisplaySize = CGSizeMake(proposedWidth, proposedHeight);
        NSLog(@"Starting up with display: %@", mainDisplay);
        
        IOSurfaceAcceleratorCreate(kCFAllocatorDefault, 0, &accelerator);
        NSDictionary *properties = @{
            (__bridge NSString *)kIOSurfaceIsGlobal:@YES,
            (__bridge NSString *)kIOSurfaceBytesPerElement:@(4),
            (__bridge NSString *)kIOSurfaceBytesPerRow:@(displaySize.width * 4),
            (__bridge NSString *)kIOSurfaceWidth:@(displaySize.width),
            (__bridge NSString *)kIOSurfaceHeight:@(displaySize.height),
            (__bridge NSString *)kIOSurfacePixelFormat:@(0x42475241),
            (__bridge NSString *)kIOSurfaceAllocSize:@(displaySize.width * displaySize.height * 4)
        };
        
        fullsizeSurface = IOSurfaceCreate((__bridge CFDictionaryRef)properties);
        
        setup_hid(scaledDisplaySize);
        create_vnc_server();
        
        id drawer = [[VncSurfaceDrawer alloc] init];
        CADisplayLink *dlink = [CADisplayLink displayLinkWithTarget:drawer selector:@selector(draw)];
        [dlink setPreferredFramesPerSecond:60];
        [dlink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];

        CFRunLoopRun();

    }
    return 0;
}
