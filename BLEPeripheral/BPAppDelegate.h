//
//  BPAppDelegate.h
//  BLEPeripheral
//
//  Created by Sandeep Mistry on 10/28/2013.
//  Copyright (c) 2013 Sandeep Mistry. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <IOBluetooth/IOBluetooth.h>

@interface BPAppDelegate : NSObject <NSApplicationDelegate, CBPeripheralManagerDelegate>

@property (assign) IBOutlet NSWindow *window;

@end
