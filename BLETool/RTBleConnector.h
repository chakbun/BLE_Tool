//
//  RTBleConnector.h
//  BLETool
//
//  Created by Jaben on 15/5/6.
//  Copyright (c) 2015年 Jaben. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRBluetoothManager.h"
#import "RongTai.h"

static NSString *const RTBle_Periperal     = @"RTPeriperal";
static NSString *const RTBle_BroadcastData = @"RTBroadcastData";
static NSString *const RTBle_RSSI          = @"RTRSSI";

#define RTLocalName @"RT8600S"
#define RTBroadServiceUUID @"1802"

#define RTServiceUUID @"FFF0"
#define RT_N_ChracteristicUUID @"0734594A-A8E7-4B1A-A6B1-CD5243059A57"
#define RT_RW_ChracteristicUUID @"FFF1"
#define RT_W_ChracteristicUUID @"8B00ACE7-EB0B-49B0-BBE9-9AEE0A26E1A3"
#define RT_RN_ChracteristicUUID @"E06D5EFB-4F4A-45C0-9EB1-371AE5A14AD4"

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

- (void)startScanRTPeripheral:(NSArray *)serviceUUIDs;

- (void)stopScanRTPeripheral;

- (void)connectRTPeripheral:(CBPeripheral *)peripheral;

- (void)cancelConnectRTPeripheral:(CBPeripheral *)peripheral;

/*======================================================
 业务命令
 /======================================================*/
#pragma mark - Control Command

- (void)controlMode:(RTControlMode)mode;
@end
