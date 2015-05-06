//
//  JRBluetoothManager.m
//  BLETool
//
//  Created by Jaben on 14-12-23.
//  Copyright (c) 2014年 Jaben. All rights reserved.
//

#import "JRBluetoothManager.h"

@interface JRBluetoothManager ()<CBCentralManagerDelegate,CBPeripheralDelegate,CBPeripheralManagerDelegate>
{
    CBCentralManager *centerManager;
    CBPeripheralManager *peripheralManager;
    NSMutableDictionary *connectedPeriphralDictionary;
}

@end

@implementation JRBluetoothManager

+ (instancetype)shareManager
{
    static JRBluetoothManager *shareManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        shareManager =[[JRBluetoothManager alloc] init];
    });
    
    return shareManager;
}

- (id)init
{
    if (self= [super init])
    {
        centerManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
        connectedPeriphralDictionary = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

#pragma mark - Public

- (void)startScanPeripherals:(NSArray *)serviceUUIDs
{
    NSLog(@"============ startScanPeripherals ============");
    [centerManager scanForPeripheralsWithServices:serviceUUIDs options:@{
                                                                         CBCentralManagerScanOptionAllowDuplicatesKey:@(NO)
                                                                         }];
}

- (void)stopScanPeripherals
{
    NSLog(@"============ stopScanPeripherals ============");
    [centerManager stopScan];
}

- (void)connectPeripheral:(CBPeripheral *)peripheral
{
    [centerManager connectPeripheral:peripheral options:nil];
}

- (void)cancelConnectPeriphral:(CBPeripheral *)peripheral
{
    [centerManager cancelPeripheralConnection:peripheral];
}

- (void)readDataFromPeriperal:(CBPeripheral *)peripheral inCharacteristic:(CBCharacteristic *)characteristic
{
    if (peripheral && characteristic)
    {
        [peripheral readValueForCharacteristic:characteristic];
    }
}

- (void)readDataFromPeriperalWithName:(NSString *)name inCharacteristic:(CBCharacteristic *)characteristic {
    CBPeripheral *targetPeripheral = connectedPeriphralDictionary[name];
    if (targetPeripheral) {
        [self readDataFromPeriperal:targetPeripheral inCharacteristic:characteristic];
    }
}

- (void)writeData:(NSData *)data toPeriperal:(CBPeripheral *)peripheral characteritic:(CBCharacteristic *)characteristic
{
    if (peripheral && data && characteristic)
    {
        NSLog(@"============ writeData ============");
        NSLog(@"characteristic: %@", [characteristic.UUID UUIDString]);
        NSLog(@"data: %@", data);
        [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    }
}

- (void)writeData:(NSData *)data toPeriperal:(CBPeripheral *)peripheral characteritic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)characteristicWriteType
{
    if (peripheral && data && characteristic)
    {
        NSLog(@"============ writeData ============");
        NSLog(@"characteristic: %@", [characteristic.UUID UUIDString]);
        NSLog(@"data: %@", data);
        [peripheral writeValue:data forCharacteristic:characteristic type:characteristicWriteType];
    }
}

- (void)writeData:(NSData *)data toPeriperalWithName:(NSString *)name characteritic:(CBCharacteristic *)characteristic {
    CBPeripheral *targetPeripheral = connectedPeriphralDictionary[name];
    if (targetPeripheral) {
        [self writeData:data toPeriperal:targetPeripheral characteritic:characteristic];
    }
}
- (void)writeData:(NSData *)data toPeriperalWithName:(NSString *)name characteritic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)characteristicWriteType {
    CBPeripheral *targetPeripheral = connectedPeriphralDictionary[name];
    if (targetPeripheral) {
        [self writeData:data toPeriperal:targetPeripheral characteritic:characteristic type:characteristicWriteType];
    }
}

#pragma mark - Central Manager Delegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"============ centralManagerDidUpdateState ============");
    NSLog(@"centerManager state: %d",(int)central.state);
    
    if (_delegate && [_delegate respondsToSelector:@selector(didUpdateState:)])
    {
        [_delegate didUpdateState:central.state];
    }
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"============ didDiscoverPeripheral ============");
    NSLog(@"periperal Name: %@",peripheral.name);
    NSLog(@"periperal RSSI: %@",RSSI);
    NSLog(@"periperal UUID: %@",[peripheral.identifier UUIDString]);
    NSLog(@"periperal advertisemenetData:%@",advertisementData);
    
    if (_delegate && [_delegate respondsToSelector:@selector(didFoundPeripheral:advertisement:rssi:)])
    {
        [_delegate didFoundPeripheral:peripheral advertisement:advertisementData rssi:RSSI];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"============ jr didConnectPeripheral ============");
    [connectedPeriphralDictionary setObject:peripheral forKey:peripheral.name];
    peripheral.delegate = self;
    
    [peripheral discoverServices:nil];
    
    if (_delegate && [_delegate respondsToSelector:@selector(didConnectPeriphral:)])
    {
        [_delegate didConnectPeriphral:peripheral];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"============ didFailToConnectPeripheral ============");
    if (_delegate && [_delegate respondsToSelector:@selector(didFailToConnectPeriphral:)])
    {
        [_delegate didFailToConnectPeriphral:peripheral];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"============ didDisconnectPeripheral ============");
    
    if (_delegate && [_delegate respondsToSelector:@selector(didDisconnectPeriphral:)])
    {
        [_delegate didDisconnectPeriphral:peripheral];
    }
}

#pragma mark - Peripheral Delegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"============ didDiscoverServices ============");
    if (error)
    {
        NSLog(@"Error occur : %@",error);
        return;
    }
    
    for(CBService *service in peripheral.services)
    {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"============ didDiscoverCharacteristicsForService ============");
    if (error)
    {
        NSLog(@"Error occur : %@",error);
        return;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(didDiscoverCharacteristicOfService:fromPeriperal:)])
    {
        [_delegate didDiscoverCharacteristicOfService:service fromPeriperal:peripheral];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"============ didUpdateValueForCharacteristic ============");
    if (error)
    {
        NSLog(@"error occur : %@",error);
        return;
    }
    NSLog(@"peripheral name: %@",peripheral.name);
    NSLog(@"characteristic: %@ data: %@",[characteristic.UUID UUIDString],characteristic.value);
    
    BOOL flag = [_delegate respondsToSelector:@selector(didUpdateValue:fromPeripheral:characteritic:)];
    if (_delegate && flag)
    {
        [_delegate didUpdateValue:characteristic.value fromPeripheral:peripheral characteritic:characteristic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"============ didWriteValueForCharacteristic ============");
    if (error)
    {
        NSLog(@"error occur : %@",error);
        return;
    }
    NSLog(@"peripheral name: %@",peripheral.name);
    NSLog(@"characteristic: %@ data: %@",[characteristic.UUID UUIDString],characteristic.value);
    if (_delegate && [_delegate respondsToSelector:@selector(didWriteValueForCharacteristic:inPeripheral:)])
    {
        [_delegate didWriteValueForCharacteristic:characteristic inPeripheral:peripheral];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
}


#pragma mark - Peripheral Manager Delegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    
}

@end
