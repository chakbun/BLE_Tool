//
//  JRBluetoothManager.h
//  BLETool
//
//  Created by Jaben on 14-12-23.
//  Copyright (c) 2014年 Jaben. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "JRCBPeripheral.h"

@protocol JRBluetoothManagerDelegate <NSObject>

@optional

- (void)didUpdateState:(CBCentralManagerState)state;
- (void)didFoundPeripheral:(JRCBPeripheral *)peripheral;
- (void)didConnectPeriphral:(CBPeripheral *)periphral;
- (void)didFailToConnectPeriphral:(CBPeripheral *)periphral;
- (void)didDisconnectPeriphral:(CBPeripheral *)periphral;
- (void)didDiscoverCharacteristicOfService:(CBService *)service fromPeriperal:(CBPeripheral *)periphral;
- (void)didUpdateValue:(NSData *)data fromPeripheral:(CBPeripheral *)peripheral characteritic:(CBCharacteristic *)characteristic;
- (void)didWriteValueForCharacteristic:(CBCharacteristic *)characteristic inPeripheral:(CBPeripheral *)peripheral;

@end


@interface JRBluetoothManager : NSObject

@property (nonatomic, strong) id<JRBluetoothManagerDelegate> delegate;

+ (instancetype)shareManager;

- (void)startScanPeripherals:(NSArray *)serviceUUIDs;
- (void)stopScanPeripherals;

- (void)connectPeripheral:(JRCBPeripheral *)jrPeripheral;
- (void)cancelConnectPeriphral:(JRCBPeripheral *)jrPeripheral;

- (void)readDataFromPeriperal:(JRCBPeripheral *)jrPeripheral inCharacteristic:(CBCharacteristic *)characteristic;
- (void)readDataFromPeriperalWithName:(NSString *)name inCharacteristic:(CBCharacteristic *)characteristic;

- (void)writeData:(NSData *)data toPeriperal:(JRCBPeripheral *)jrPeripheral characteritic:(CBCharacteristic *)characteristic;
- (void)writeData:(NSData *)data toPeriperal:(JRCBPeripheral *)jrPeripheral characteritic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)characteristicWriteType;
- (void)writeData:(NSData *)data toPeriperalWithName:(NSString *)name characteritic:(CBCharacteristic *)characteristic;
- (void)writeData:(NSData *)data toPeriperalWithName:(NSString *)name characteritic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)characteristicWriteType;
@end
