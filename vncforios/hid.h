//
//  hid.h
//  vncforios
//
//  Created by user on 5/19/20.
//  Copyright © 2020 ethan arbuckle. All rights reserved.
//

#ifndef hid_h
#define hid_h

void setup_hid(CGSize displaySize);
void VNCKeyboard(rfbBool down, rfbKeySym key, rfbClientPtr client);
void VNCPointerNew(uint8_t buttonMask, int x, int y, rfbClientPtr client);

#endif /* hid_h */
