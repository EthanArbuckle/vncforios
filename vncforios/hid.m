//
//  hid.m
//  vncforios
//
//  Created by user on 5/19/20.
//  Copyright © 2020 ethan arbuckle. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <mach/mach_time.h>
#include "external.h"

static IOHIDEventSystemClientRef eventClient;
static CGSize displaySize;
static uint64_t multitouchDeviceID;

void setup_hid(CGSize scaledDisplaySize) {
    eventClient = IOHIDEventSystemClientCreate(kCFAllocatorDefault);
    displaySize = scaledDisplaySize;
    
    mach_port_t masterPort;
    IOMasterPort(MACH_PORT_NULL, &masterPort);
    CFMutableDictionaryRef classesToMatch = IOServiceMatching("AppleMultitouchDevice");
    
    io_iterator_t matchingServices;
    kern_return_t kernResult = IOServiceGetMatchingServices(masterPort, classesToMatch, &matchingServices);
    if (kernResult != KERN_SUCCESS)
    {
        NSLog(@"failed to find AppleMultitouchDevice service");
        return;
    }

    io_object_t service;
    while ((service = IOIteratorNext(matchingServices)))
    {
        uint64_t state = 0;
        uint32_t integer = 0;
        uint64_t time = 0;
        IOServiceGetBusyStateAndTime(service, &state, &integer, &time);
        if (state & kIOServiceRegisteredState)
        {
            IORegistryEntryGetRegistryEntryID(service, &multitouchDeviceID);
        }
    }

    IOObjectRelease(service);
    IOObjectRelease(matchingServices);
    mach_port_deallocate(mach_task_self(), masterPort);
    
    NSLog(@"AppleMultitouchDevice: 0x%llx", multitouchDeviceID);
}

static void send_event(IOHIDEventRef event) {
    IOHIDEventSetSenderID(event, multitouchDeviceID);
    IOHIDEventSystemClientDispatchEvent(eventClient, event);
    CFRelease(event);
}

void VNCKeyboard(rfbBool down, rfbKeySym key, rfbClientPtr client) {
    uint16_t usage;
    uint16_t usagePage = kHIDPage_KeyboardOrKeypad;

    switch (key)
    {
        case XK_exclam:
        case XK_1: usage = kHIDUsage_Keyboard1; break;
        case XK_at:
        case XK_2: usage = kHIDUsage_Keyboard2; break;
        case XK_numbersign:
        case XK_3: usage = kHIDUsage_Keyboard3; break;
        case XK_dollar:
        case XK_4: usage = kHIDUsage_Keyboard4; break;
        case XK_percent:
        case XK_5: usage = kHIDUsage_Keyboard5; break;
        case XK_asciicircum:
        case XK_6: usage = kHIDUsage_Keyboard6; break;
        case XK_ampersand:
        case XK_7: usage = kHIDUsage_Keyboard7; break;
        case XK_asterisk:
        case XK_8: usage = kHIDUsage_Keyboard8; break;
        case XK_parenleft:
        case XK_9: usage = kHIDUsage_Keyboard9; break;
        case XK_parenright:
        case XK_0: usage = kHIDUsage_Keyboard0; break;
            
        case XK_A:
        case XK_a: usage = kHIDUsage_KeyboardA; break;
        case XK_B:
        case XK_b: usage = kHIDUsage_KeyboardB; break;
        case XK_C:
        case XK_c: usage = kHIDUsage_KeyboardC; break;
        case XK_D:
        case XK_d: usage = kHIDUsage_KeyboardD; break;
        case XK_E:
        case XK_e: usage = kHIDUsage_KeyboardE; break;
        case XK_F:
        case XK_f: usage = kHIDUsage_KeyboardF; break;
        case XK_G:
        case XK_g: usage = kHIDUsage_KeyboardG; break;
        case XK_H:
        case XK_h: usage = kHIDUsage_KeyboardH; break;
        case XK_I:
        case XK_i: usage = kHIDUsage_KeyboardI; break;
        case XK_J:
        case XK_j: usage = kHIDUsage_KeyboardJ; break;
        case XK_K:
        case XK_k: usage = kHIDUsage_KeyboardK; break;
        case XK_L:
        case XK_l: usage = kHIDUsage_KeyboardL; break;
        case XK_M:
        case XK_m: usage = kHIDUsage_KeyboardM; break;
        case XK_N:
        case XK_n: usage = kHIDUsage_KeyboardN; break;
        case XK_O:
        case XK_o: usage = kHIDUsage_KeyboardO; break;
        case XK_P:
        case XK_p: usage = kHIDUsage_KeyboardP; break;
        case XK_Q:
        case XK_q: usage = kHIDUsage_KeyboardQ; break;
        case XK_R:
        case XK_r: usage = kHIDUsage_KeyboardR; break;
        case XK_S:
        case XK_s: usage = kHIDUsage_KeyboardS; break;
        case XK_T:
        case XK_t: usage = kHIDUsage_KeyboardT; break;
        case XK_U:
        case XK_u: usage = kHIDUsage_KeyboardU; break;
        case XK_V:
        case XK_v: usage = kHIDUsage_KeyboardV; break;
        case XK_W:
        case XK_w: usage = kHIDUsage_KeyboardW; break;
        case XK_X:
        case XK_x: usage = kHIDUsage_KeyboardX; break;
        case XK_Y:
        case XK_y: usage = kHIDUsage_KeyboardY; break;
        case XK_Z:
        case XK_z: usage = kHIDUsage_KeyboardZ; break;
            
        case XK_underscore:
        case XK_minus: usage = kHIDUsage_KeyboardHyphen; break;
        case XK_plus:
        case XK_equal: usage = kHIDUsage_KeyboardEqualSign; break;
        case XK_braceleft:
        case XK_bracketleft: usage = kHIDUsage_KeyboardOpenBracket; break;
        case XK_braceright:
        case XK_bracketright: usage = kHIDUsage_KeyboardCloseBracket; break;
        case XK_bar:
        case XK_backslash: usage = kHIDUsage_KeyboardBackslash; break;
        case XK_colon:
        case XK_semicolon: usage = kHIDUsage_KeyboardSemicolon; break;
        case XK_quotedbl:
        case XK_apostrophe: usage = kHIDUsage_KeyboardQuote; break;
        case XK_asciitilde:
        case XK_grave: usage = kHIDUsage_KeyboardGraveAccentAndTilde; break;
        case XK_less:
        case XK_comma: usage = kHIDUsage_KeyboardComma; break;
        case XK_greater:
        case XK_period: usage = kHIDUsage_KeyboardPeriod; break;
        case XK_question:
        case XK_slash: usage = kHIDUsage_KeyboardSlash; break;
        case XK_Return: usage = kHIDUsage_KeyboardReturnOrEnter; break;
        case XK_BackSpace: usage = kHIDUsage_KeyboardDeleteOrBackspace; break;
        case XK_Tab: usage = kHIDUsage_KeyboardTab; break;
        case XK_space: usage = kHIDUsage_KeyboardSpacebar; break;
        case XK_Shift_L: usage = kHIDUsage_KeyboardLeftShift; break;
        case XK_Shift_R: usage = kHIDUsage_KeyboardRightShift; break;
        case XK_Control_L: usage = kHIDUsage_KeyboardLeftControl; break;
        case XK_Control_R: usage = kHIDUsage_KeyboardRightControl; break;
        case XK_Meta_L: usage = kHIDUsage_KeyboardLeftAlt; break;
        case XK_Meta_R: usage = kHIDUsage_KeyboardRightAlt; break;
        case XK_Alt_L: usage = kHIDUsage_KeyboardLeftGUI; break;
        case XK_Alt_R: usage = kHIDUsage_KeyboardRightGUI; break;
        case XK_Up: usage = kHIDUsage_KeyboardUpArrow; break;
        case XK_Down: usage = kHIDUsage_KeyboardDownArrow; break;
        case XK_Left: usage = kHIDUsage_KeyboardLeftArrow; break;
        case XK_Right: usage = kHIDUsage_KeyboardRightArrow; break;
        // map the keyboard home key and exc key to the Menu button
        case XK_Home:
        case XK_Escape:
        case XK_Begin: {
            usagePage = kHIDPage_GenericDesktop;
            usage = kHIDUsage_Button_134;
            break;
        }
        case XK_End: usage = kHIDUsage_KeyboardEnd; break;
        case XK_Page_Up: usage = kHIDUsage_KeyboardPageUp; break;
        case XK_Page_Down: usage = kHIDUsage_KeyboardPageDown; break;
        default: return;
    }
    
    IOHIDEventRef event = IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), usagePage, usage, down, 0);
    send_event(event);
}

static int lastButtonMask;
void VNCPointerNew(int buttonMask, int x, int y, rfbClientPtr client) {
    int diff = lastButtonMask ^ buttonMask;
    bool wasDown = (lastButtonMask & 0x1) != 0;
    bool isDown = (buttonMask & 0x1) != 0;
    lastButtonMask = buttonMask;

    rfbDefaultPtrAddEvent(buttonMask, x, y, client);
    
    if ((diff & rfbButton5Mask) != 0) {
        BOOL down = (buttonMask & rfbButton5Mask) != 0;
        send_event(IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), kHIDPage_Telephony, kHIDUsage_Tfon_Flash, down, 0));
    }
    else if ((diff & rfbButton3Mask) != 0) {
        // Menu button
        BOOL down = (buttonMask & rfbButton3Mask) != 0;
        send_event(IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), kHIDPage_GenericDesktop, kHIDUsage_Button_134, down, 0));
    }
    else if ((diff & rfbButton2Mask) != 0) {
        // Power button
        BOOL down = (buttonMask & rfbButton2Mask) != 0;
        send_event(IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), kHIDPage_Consumer, kHIDUsage_Csmr_Power, down, 0));
    }

    uint32_t handm;
    uint32_t fingerm;

    if (wasDown == 0 && isDown == 1) {
        handm = kIOHIDDigitizerEventRange | kIOHIDDigitizerEventTouch | kIOHIDDigitizerEventIdentity;
        fingerm = kIOHIDDigitizerEventRange | kIOHIDDigitizerEventTouch;
    } else if (wasDown == 1 && isDown == 1) {
        handm = kIOHIDDigitizerEventPosition;
        fingerm = kIOHIDDigitizerEventPosition;
    } else if (wasDown == 1 && isDown == 0) {
        handm = kIOHIDDigitizerEventRange | kIOHIDDigitizerEventTouch | kIOHIDDigitizerEventIdentity | kIOHIDDigitizerEventPosition;
        fingerm = kIOHIDDigitizerEventRange | kIOHIDDigitizerEventTouch;
    } else {
        return;
    }

    IOHIDFloat xf = x;
    IOHIDFloat yf = y;

    xf /= displaySize.width;
    yf /= displaySize.height;
    
    IOHIDEventRef hand = IOHIDEventCreateDigitizerEvent(kCFAllocatorDefault, mach_absolute_time(), kIOHIDDigitizerTransducerTypeHand, 1<<22, 1, handm, 0, xf, yf, 0, 0, 0, 0, 0, 0);
    IOHIDEventSetIntegerValue(hand, kIOHIDEventFieldIsBuiltIn, true);
    IOHIDEventSetIntegerValue(hand, kIOHIDEventFieldDigitizerIsDisplayIntegrated, true);

    IOHIDEventRef finger = IOHIDEventCreateDigitizerFingerEvent(kCFAllocatorDefault, mach_absolute_time(), 3, 2, fingerm, xf, yf, 0, 0, 0, wasDown, isDown, 0);
    IOHIDEventAppendEvent(hand, finger);
    CFRelease(finger);

    send_event(hand);
}
