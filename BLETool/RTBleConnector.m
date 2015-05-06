//
//  RTBleConnector.m
//  BLETool
//
//  Created by Jaben on 15/5/6.
//  Copyright (c) 2015年 Jaben. All rights reserved.
//

#import "RTBleConnector.h"

@interface RTBleConnector ()<JRBluetoothManagerDelegate>

@end

@implementation RTBleConnector


+ (instancetype)shareManager {
    static RTBleConnector *shareManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager =[[RTBleConnector alloc] init];
    });
    return shareManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        [JRBluetoothManager shareManager].delegate = self;

    }
    return self;
}

#pragma mark - JRBluetoothManagerDelegate

- (void)didUpdateState:(CBCentralManagerState)state {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didUpdateRTBleState:)]) {
        [self.delegate didUpdateRTBleState:state];
    }
}

- (void)didFoundPeripheral:(CBPeripheral *)peripheral advertisement:(NSDictionary *)advertisement rssi:(NSNumber *)rssi {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFoundRTBlePeriperalInfo:)]) {
        NSDictionary *peripheralInfo = @{
                                         RTBle_Periperal:peripheral,
                                         RTBle_BroadcastData:advertisement,
                                         RTBle_RSSI:rssi,
                                         };
        [self.delegate didFoundRTBlePeriperalInfo:peripheralInfo];
    }
}

- (void)didConnectPeriphral:(CBPeripheral *)periphral {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didConnectRTBlePeripheral:)]) {
        [self.delegate didConnectRTBlePeripheral:periphral];
    }
}

- (void)didFailToConnectPeriphral:(CBPeripheral *)periphral {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFailToConnectRTBlePeripheral:)]) {
        [self.delegate didFailToConnectRTBlePeripheral:periphral];
    }
}

- (void)didDisconnectPeriphral:(CBPeripheral *)periphral {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDisconnectRTBlePeripheral:)]) {
        [self.delegate didDisconnectRTBlePeripheral:periphral];
    }
}

- (void)didDiscoverCharacteristicOfService:(CBService *)service fromPeriperal:(CBPeripheral *)periphral {
    
}

- (void)didUpdateValue:(NSData *)data fromPeripheral:(CBPeripheral *)peripheral characteritic:(CBCharacteristic *)characteristic {
    
}

- (void)didWriteValueForCharacteristic:(CBCharacteristic *)characteristic inPeripheral:(CBPeripheral *)peripheral {
    
}

@end
