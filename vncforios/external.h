//
//  external.h
//  vncforios
//
//  Created by ethanarbuckle.
//  Copyright © ethanarbuckle. All rights reserved.
//

#ifndef external_h
#define external_h

extern void CARenderServerRenderDisplay(kern_return_t a, CFStringRef b, IOSurfaceRef surface, int x, int y);
typedef struct __IOSurfaceAccelerator *IOSurfaceAcceleratorRef;
extern int IOSurfaceAcceleratorCreate(CFAllocatorRef allocator, int type, IOSurfaceAcceleratorRef *outAccelerator);
extern int IOSurfaceAcceleratorTransferSurface(IOSurfaceAcceleratorRef accelerator, IOSurfaceRef source, IOSurfaceRef dest, CFDictionaryRef, void *);

#endif /* external_h */
