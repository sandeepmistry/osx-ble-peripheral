//
//  BPAppDelegate.m
//  BLEPeripheral
//
//  Created by Sandeep Mistry on 10/28/2013.
//  Copyright (c) 2013 Sandeep Mistry. All rights reserved.
//

#import <objc/runtime.h>
#import <objc/message.h>

#import "BPAppDelegate.h"

@interface CBXpcConnection : NSObject //{
//    <CBXpcConnectionDelegate> *_delegate;
//    NSRecursiveLock *_delegateLock;
//    NSMutableDictionary *_options;
//    NSObject<OS_dispatch_queue> *_queue;
//    int _type;
//    NSObject<OS_xpc_object> *_xpcConnection;
//    NSObject<OS_dispatch_semaphore> *_xpcSendBarrier;
//}
//
//@property <CBXpcConnectionDelegate> * delegate;

- (id)allocXpcArrayWithNSArray:(id)arg1;
- (id)allocXpcDictionaryWithNSDictionary:(id)arg1;
- (id)allocXpcMsg:(int)arg1 args:(id)arg2;
- (id)allocXpcObjectWithNSObject:(id)arg1;
- (void)checkIn;
- (void)checkOut;
- (void)dealloc;
- (id)delegate;
- (void)disconnect;
- (void)handleConnectionEvent:(id)arg1;
- (void)handleInvalid;
- (void)handleMsg:(int)arg1 args:(id)arg2;
- (void)handleReset;
- (id)initWithDelegate:(id)arg1 queue:(id)arg2 options:(id)arg3 sessionType:(int)arg4;
- (BOOL)isMainQueue;
- (id)nsArrayWithXpcArray:(id)arg1;
- (id)nsDictionaryFromXpcDictionary:(id)arg1;
- (id)nsObjectWithXpcObject:(id)arg1;
- (void)sendAsyncMsg:(int)arg1 args:(id)arg2;
- (void)sendMsg:(int)arg1 args:(id)arg2;
- (id)sendSyncMsg:(int)arg1 args:(id)arg2;
- (void)setDelegate:(id)arg1;

@end

@implementation CBXpcConnection (Swizzled)

- (void)sendMsg1:(int)arg1 args:(id)arg2
{
    NSLog(@"sendMsg: %d, %@", arg1, arg2);
    
    if ([self respondsToSelector:@selector(sendMsg1:args:)]) {
        [self sendMsg1:arg1 args:arg2];
    }
}

- (void)handleMsg1:(int)arg1 args:(id)arg2
{
    NSLog(@"handleMsg: %d, %@", arg1, arg2);
    
    if ([self respondsToSelector:@selector(handleMsg1:args:)]) {
        [self handleMsg1:arg1 args:arg2];
    }
}

@end

@interface BPAppDelegate ()

@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CBMutableService *service;

@end


@implementation BPAppDelegate

//#define XPC_SPY 1

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
#ifdef XPC_SPY
    // Insert code here to initialize your application
    Class xpcConnectionClass = NSClassFromString(@"CBXpcConnection");
    
    Method origSendMethod = class_getInstanceMethod(xpcConnectionClass,  @selector(sendMsg:args:));
    Method newSendMethod = class_getInstanceMethod(xpcConnectionClass, @selector(sendMsg1:args:));
    
    method_exchangeImplementations(origSendMethod, newSendMethod);
    
    Method origHandleMethod = class_getInstanceMethod(xpcConnectionClass,  @selector(handleMsg:args:));
    Method newHandleMethod = class_getInstanceMethod(xpcConnectionClass, @selector(handleMsg1:args:));
    
    method_exchangeImplementations(origHandleMethod, newHandleMethod);
#endif
    
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    NSLog(@"peripheralManagerDidUpdateState: %d", (int)peripheral.state);
    
    if (CBPeripheralManagerStatePoweredOn == peripheral.state) {
        
        NSData *zombie = [@"zombie" dataUsingEncoding:NSUTF8StringEncoding];
        CBMutableCharacteristic *characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:@"DDCA9B49-A6F5-462F-A89A-C2144083CA7F"] properties:CBCharacteristicPropertyRead value:zombie permissions:CBAttributePermissionsReadable];
        
        self.service = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:@"BD0F6577-4A38-4D71-AF1B-4E8F57708080"] primary:YES];
        self.service.characteristics = @[characteristic];
        
        [self.peripheralManager addService:self.service];
    } else {
        [peripheral stopAdvertising];
        [peripheral removeAllServices];
    }
}


- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    NSLog(@"peripheralManagerDidStartAdvertising: %@", error);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    NSLog(@"peripheralManagerDidAddService: %@ %@", service, error);

    [peripheral startAdvertising:@{
                                   CBAdvertisementDataLocalNameKey: @"hello"
                                   }];
}


@end
