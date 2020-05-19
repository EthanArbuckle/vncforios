//
//  external.h
//  vncforios
//
//  Created by ethanarbuckle.
//  Copyright © ethanarbuckle. All rights reserved.
//

#ifndef external_h
#define external_h

#include <IOKit/hidsystem/IOHIDEventSystemClient.h>
#include <IOKit/hid/IOHIDUsageTables.h>
#include <IOKit/hid/IOHIDEventTypes.h>
#include <IOKit/hid/IOHIDEvent.h>
#include <UIKit/UIKit.h>
#include <rfb/rfb.h>
#include <rfb/keysym.h>

// For surface rendering
extern void CARenderServerRenderDisplay(kern_return_t a, CFStringRef b, IOSurfaceRef surface, int x, int y);
typedef struct __IOSurfaceAccelerator *IOSurfaceAcceleratorRef;
extern int IOSurfaceAcceleratorCreate(CFAllocatorRef allocator, int type, IOSurfaceAcceleratorRef *outAccelerator);
extern int IOSurfaceAcceleratorTransferSurface(IOSurfaceAcceleratorRef accelerator, IOSurfaceRef source, void *dest, CFDictionaryRef, void *);

// For events
typedef struct __IOHIDEvent *IOHIDEventRef;
IOHIDEventSystemClientRef IOHIDEventSystemClientCreate(CFAllocatorRef allocator);
void IOHIDEventSetIntegerValue(IOHIDEventRef event, IOHIDEventField field, int value);
void IOHIDEventSetSenderID(IOHIDEventRef event, uint64_t sender);
void IOHIDEventSystemClientDispatchEvent(IOHIDEventSystemClientRef client, IOHIDEventRef event);

#endif /* external_h */
