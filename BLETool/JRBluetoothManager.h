//
//  JRBluetoothManager.h
//  BLETool
//
//  Created by Jaben on 14-12-23.
//  Copyright (c) 2014年 Jaben. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol JRBluetoothManagerDelegate <NSObject>

@required

- (void)didUpdateState:(CBCentralManagerState)state;

@optional

- (void)didFoundPeripheral:(CBPeripheral *)peripheral advertisement:(NSDictionary *)advertisement rssi:(NSNumber *)rssi;

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

- (void)connectPeripheral:(CBPeripheral *)peripheral;
- (void)cancelConnectPeriphral:(CBPeripheral *)peripheral;

- (void)readDataFromPeriperalWithName:(NSString *)name inCharacteristic:(CBCharacteristic *)characteristic;
- (void)readDataFromPeriperal:(CBPeripheral *)jrPeripheral inCharacteristic:(CBCharacteristic *)characteristic;

- (void)writeData:(NSData *)data toPeriperal:(CBPeripheral *)jrPeripheral characteritic:(CBCharacteristic *)characteristic;
- (void)writeData:(NSData *)data toPeriperal:(CBPeripheral *)jrPeripheral characteritic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)characteristicWriteType;

- (void)writeData:(NSData *)data toPeriperalWithName:(NSString *)name characteritic:(CBCharacteristic *)characteristic;
- (void)writeData:(NSData *)data toPeriperalWithName:(NSString *)name characteritic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)characteristicWriteType;
@end
