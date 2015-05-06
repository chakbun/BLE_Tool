//
//  RTBleConnector.h
//  BLETool
//
//  Created by Jaben on 15/5/6.
//  Copyright (c) 2015年 Jaben. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRBluetoothManager.h"

static NSString *const RTBle_Periperal     = @"RTPeriperal";
static NSString *const RTBle_BroadcastData = @"RTBroadcastData";
static NSString *const RTBle_RSSI          = @"RTRSSI";

#pragma mark - RTBleConnectorDelegate

@protocol RTBleConnectorDelegate <NSObject>

@required
- (void)didUpdateRTBleState:(CBCentralManagerState)state;

@optional

- (void)didFoundRTBlePeriperalInfo:(NSDictionary *)periperalInfo;

- (void)didConnectRTBlePeripheral:(CBPeripheral *)peripheral;

- (void)didFailToConnectRTBlePeripheral:(CBPeripheral *)peripheral;

- (void)didDisconnectRTBlePeripheral:(CBPeripheral *)peripheral;
@end

#pragma mark - RTBleConnector

/*======================================================
 RTBleConnector
 /======================================================*/

@interface RTBleConnector : NSObject

@property (nonatomic, strong) id<RTBleConnectorDelegate> delegate;

+ (instancetype)shareManager;

@end
