//
//  Created by ethanarbuckle.
//  Copyright © ethanarbuckle. All rights reserved.
//

#define RUNPATH @"/usr/bin/vncforios"
#import <Foundation/Foundation.h>

void launchVNC(void) {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/Applications/VNC Viewer.app/Contents/MacOS/vncviewer"];
    [task setArguments:@[@"localhost:5999", @"-Scaling", @"100%"]];
    [task launch];
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
            
        // Launch to executable on device
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:@"/usr/bin/ssh"];
        [task setArguments:@[@"-oStricthostkeychecking=no", @"-oUserknownhostsfile=/dev/null", @"-p 2222", @"root@localhost", RUNPATH]];
        NSPipe *outputPipe = [NSPipe pipe];
        [task setStandardOutput:outputPipe];
        [task launch];
        
        // Open an instance of VNV Viewer to the device
        launchVNC();
        
        [task waitUntilExit];
        
        NSData *outData = [[outputPipe fileHandleForReading] readDataToEndOfFile];
        NSString *output = [[NSString alloc] initWithData:outData encoding:NSUTF8StringEncoding];
        
        // Print output from the device
        NSLog(@"%@", output);
    
    }
    return 0;
}
