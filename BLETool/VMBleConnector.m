//
//  VMBleConnector.m
//  BLETool
//
//  Created by Jaben on 14-12-30.
//  Copyright (c) 2014年 Jaben. All rights reserved.
//

#import "VMBleConnector.h"

@interface VMBleConnector ()<JRBluetoothManagerDelegate>
{
    
}

@property (nonatomic, strong) CBCharacteristic *dataWriteCharacteristic;
@property (nonatomic, strong) CBCharacteristic *dataReadCharacteristic;
@property (nonatomic, strong) CBCharacteristic *batteryReadCharacteristic;
@property (nonatomic, strong) CBCharacteristic *RSSIReadCharacteristic;
@property (nonatomic, strong) CBCharacteristic *RSSICircleWriteCharacteristic;
@property (nonatomic, strong) CBCharacteristic *hardwareNameCharacteristic;
@property (nonatomic, strong) CBCharacteristic *hardwareResetCharacteristic;
@property (nonatomic, strong) CBCharacteristic *hardwareIDCharacteristic;
@property (nonatomic, strong) CBCharacteristic *hardwarePowerOffCharacteristic;
@property (nonatomic, strong) CBCharacteristic *deviceIDCharacteristic;
@property (nonatomic, strong) CBCharacteristic *deviceVersionCharacteristic;

@end

@implementation VMBleConnector

+ (instancetype)shareManager {
    static VMBleConnector *shareManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager =[[VMBleConnector alloc] init];
    });
    return shareManager;
}

- (instancetype)init
{
    if (self= [super init])
    {
        [JRBluetoothManager shareManager].delegate = self;
    }
    return self;
}

#pragma mark - Public
- (void)startScanPeripherals:(NSArray *)serviceUUIDs {
    [[JRBluetoothManager shareManager] startScanPeripherals:serviceUUIDs];
}

- (void)stopScanPeripherals {
    [[JRBluetoothManager shareManager] stopScanPeripherals];
}

- (void)connectPeripheral:(JRCBPeripheral *)jrPeripheral withCompleted:(void(^)(BOOL success))complted {
    [[JRBluetoothManager shareManager] connectPeripheral:jrPeripheral];
}

#pragma mark - JRBluetooth Manager Delegate

- (void)didUpdateState:(CBCentralManagerState)state
{
    if (_delegate && [_delegate respondsToSelector:@selector(didUpdateState:)])
    {
        [_delegate didUpdateState:state];
    }
}

- (void)didFoundPeripheral:(JRCBPeripheral *)peripheral
{
    if (_delegate && [_delegate respondsToSelector:@selector(didFoundPeripheral:)])
    {
        [_delegate didFoundPeripheral:peripheral];
    }
}

- (void)didConnectPeriphral:(CBPeripheral *)periphral
{
    NSLog(@"============ vm didConnectPeripheral ============");
    if (_delegate && [_delegate respondsToSelector:@selector(didConnectPeriphral:)])
    {
        [_delegate didConnectPeriphral:periphral];
    }
}

- (void)didDisconnectPeriphral:(CBPeripheral *)periphral
{
    if (_delegate && [_delegate respondsToSelector:@selector(didDisconnectPeriphral:)])
    {
        [_delegate didDisconnectPeriphral:periphral];
    }
}

- (void)didFailToConnectPeriphral:(CBPeripheral *)periphral
{
    if (_delegate && [_delegate respondsToSelector:@selector(didFailToConnectPeriphral:)])
    {
        [_delegate didFailToConnectPeriphral:periphral];
    }
}

- (void)didUpdateValue:(NSData *)data fromPeripheral:(CBPeripheral *)peripheral characteritic:(CBCharacteristic *)characteristic
{
//    NSLog(@"============ vm didUpdateValue ============");
    if (characteristic == _dataReadCharacteristic)
    {
        [self analyzeCommand:_dataReadCharacteristic.value];
    }
    else if (characteristic == _batteryReadCharacteristic)
    {
        [self getBattery:_batteryReadCharacteristic.value];
    }
}

- (void)didWriteValueForCharacteristic:(CBCharacteristic *)characteristic inPeripheral:(CBPeripheral *)peripheral
{
    
}

- (void)didDiscoverCharacteristicOfService:(CBService *)service fromPeriperal:(CBPeripheral *)periphral
{
    NSLog(@"============ didDiscoverCharacteristicOfService ============");
    NSLog(@"servie: %@", [service.UUID UUIDString]);
    if ([[service.UUID UUIDString] isEqualToString:kDataWriteServiceUUID])
    {
        for (CBCharacteristic *characterisitc in service.characteristics)
        {
            NSLog(@"characterisitc: %@", [characterisitc.UUID UUIDString]);
            if ([[characterisitc.UUID UUIDString] isEqualToString:kDataWriteCharacteristicUUID])
            {
                _dataWriteCharacteristic = characterisitc;
            }
        }
    }
    else if ([[service.UUID UUIDString] isEqualToString:kDataReadServiceUUID])
    {
        for (CBCharacteristic *characterisitc in service.characteristics)
        {
            NSLog(@"characterisitc: %@", [characterisitc.UUID UUIDString]);
            if ([[characterisitc.UUID UUIDString] isEqualToString:kDataReadCharacteristicUUID])
            {
                _dataReadCharacteristic = characterisitc;
                [periphral setNotifyValue:YES forCharacteristic:characterisitc];
            }
        }
    }
    else if ([[service.UUID UUIDString] isEqualToString:kBatteryServiceUUID])
    {
        for (CBCharacteristic *characterisitc in service.characteristics)
        {
            NSLog(@"characterisitc: %@", [characterisitc.UUID UUIDString]);
            if ([[characterisitc.UUID UUIDString] isEqualToString:kBatteryReadCharacteristicUUID])
            {
                _batteryReadCharacteristic = characterisitc;
                [periphral setNotifyValue:YES forCharacteristic:characterisitc];
            }
        }
    }
    else if ([[service.UUID UUIDString] isEqualToString:kRSSIServiceUUID])
    {
        for (CBCharacteristic *characterisitc in service.characteristics)
        {
            NSLog(@"characterisitc: %@", [characterisitc.UUID UUIDString]);
            if ([[characterisitc.UUID UUIDString] isEqualToString:kRSSIReadCharacteristicUUID])
            {
                _RSSIReadCharacteristic = characterisitc;
                [periphral setNotifyValue:YES forCharacteristic:characterisitc];
            }
            else if ([[characterisitc.UUID UUIDString] isEqualToString:kRSSICircleWriteCharacteristicUUID])
            {
                _RSSICircleWriteCharacteristic = characterisitc;
            }
        }
    }
    else if ([[service.UUID UUIDString] isEqualToString:kHardwareServiceUUID])
    {
        for (CBCharacteristic *characterisitc in service.characteristics)
        {
            NSLog(@"characterisitc: %@", [characterisitc.UUID UUIDString]);
            if ([[characterisitc.UUID UUIDString] isEqualToString:kHardwareNameCharacteristicUUID])
            {
                _hardwareNameCharacteristic = characterisitc;
            }
            else if ([[characterisitc.UUID UUIDString] isEqualToString:kHardwareResetCharacteristicUUID])
            {
                _hardwareResetCharacteristic = characterisitc;
            }
            else if ([[characterisitc.UUID UUIDString] isEqualToString:kHardwareIDCharacteristicUUID])
            {
                _hardwareIDCharacteristic = characterisitc;
                [periphral setNotifyValue:YES forCharacteristic:characterisitc];
            }
            else if ([[characterisitc.UUID UUIDString] isEqualToString:kHardwarePowerOffCharacteristicUUID])
            {
                _hardwarePowerOffCharacteristic = characterisitc;
            }
        }
    }
    else if ([[service.UUID UUIDString] isEqualToString:kDeviceInfoServiceUUID])
    {
        for (CBCharacteristic *characterisitc in service.characteristics)
        {
            NSLog(@"characterisitc: %@", [characterisitc.UUID UUIDString]);
            if ([[characterisitc.UUID UUIDString] isEqualToString:kDeviceIDCharacteristicUUID])
            {
                _deviceIDCharacteristic = characterisitc;
            }
            else if ([[characterisitc.UUID UUIDString] isEqualToString:kDeviceVersionCharacteristicUUID])
            {
                _deviceVersionCharacteristic = characterisitc;
            }
        }
    }
}

#pragma mark - device operations

- (void)writeData:(NSData *)data toCharacteristic:(CBCharacteristic *)characteristic periphralName:(NSString *)name
{
    [[JRBluetoothManager shareManager] writeData:data toPeriperalWithName:name characteritic:characteristic];
}


- (void)powerOffWithPeriphralName:(NSString *)name
{
    NSLog(@"============ 关机 ============");
    Byte command[] = {0x02};
    
    NSData *data = [NSData dataWithBytes:command length:sizeof(command)];
    [self writeData:data toCharacteristic:_hardwarePowerOffCharacteristic periphralName:name];
}

- (void)batteryWithPerphralName:(NSString *)name
{
    NSLog(@"============ 读取电量 ============");
    [[JRBluetoothManager shareManager] readDataFromPeriperalWithName:name inCharacteristic:_batteryReadCharacteristic];
}

- (void)resetWithPeriphralName:(NSString *)name
{
    NSLog(@"============ 复位 ============");
    Byte command[] = {0x55};
    
    NSData *data = [NSData dataWithBytes:command length:sizeof(command)];
    
    [[JRBluetoothManager shareManager] writeData:data toPeriperalWithName:name characteritic:_hardwareResetCharacteristic type:CBCharacteristicWriteWithoutResponse];
}

- (void)restoreWithPeriphralName:(NSString *)name
{
    NSLog(@"============ 恢复出厂设置 ============");
    Byte command[] = {0x36};
    
    NSData *data = [NSData dataWithBytes:command length:sizeof(command)];
    
    [[JRBluetoothManager shareManager] writeData:data toPeriperalWithName:name characteritic:_hardwareResetCharacteristic type:CBCharacteristicWriteWithoutResponse];
}

#pragma mark 计算校验码

- (Byte)calculateXORCheckingCode:(Byte *)command length:(NSUInteger)length
{
    // 计算异或校验码
    Byte checkCode = 0x00;
    int i = 0;
    for (; i < length-1; i++)
    {
        checkCode ^= command[i];
    }
    command[i] = checkCode;
    
    return checkCode;
}

#pragma mark 验证校验码

- (BOOL)verifyXORCheckingCode:(Byte *)command length:(NSUInteger)length
{
    Byte checkCode = [self calculateXORCheckingCode:command length:length];
    
    BOOL flag = (checkCode ^ command[length-1]) ? NO : YES;
    
    return flag;
}

#pragma mark 厨房秤

- (void)scalePoweroff {
    [self powerOffWithPeriphralName:kDeviceScaleName];
}

- (void)scaleBattery {
    [self batteryWithPerphralName:kDeviceScaleName];
}

- (void)resetScale {
    [self resetWithPeriphralName:kDeviceScaleName];
}

- (void)restoreScale {
    [self restoreWithPeriphralName:kDeviceScaleName];
}

- (void)setScaleUnit:(VMBleMassUnit)value
{
    NSLog(@"============ 厨房秤 设置单位 ============");
    Byte command[] = {0x23, 0x01, 0x12, 0x01, 0x00, 0xFF};
    command[4] = value;     // 单位
    
    // 计算异或校验码
    [self calculateXORCheckingCode:command length:sizeof(command)];
    
    NSData *data = [NSData dataWithBytes:command length:sizeof(command)];
    [self writeData:data toCharacteristic:_dataWriteCharacteristic periphralName:kDeviceScaleName];
}

- (void)setScalePeeling
{
    NSLog(@"============ 厨房秤 去皮 ============");
    Byte command[] = {0x23, 0x01, 0x13, 0x00, 0xFF};
    
    // 计算异或校验码
    [self calculateXORCheckingCode:command length:sizeof(command)];
    
    NSData *data = [NSData dataWithBytes:command length:sizeof(command)];
    [self writeData:data toCharacteristic:_dataWriteCharacteristic periphralName:kDeviceScaleName];
}

- (void)setScaleClear
{
    NSLog(@"============ 厨房秤 清零 ============");
    Byte command[] = {0x23, 0x01, 0x14, 0x00, 0xFF};
    
    // 计算异或校验码
    [self calculateXORCheckingCode:command length:sizeof(command)];
    
    NSData *data = [NSData dataWithBytes:command length:sizeof(command)];
    [self writeData:data toCharacteristic:_dataWriteCharacteristic periphralName:kDeviceScaleName];
}

- (void)setScaleTargetWeight:(NSUInteger)value
{
    NSLog(@"============ 厨房秤 设置重量 ============");
    Byte command[] = {0x23, 0x01, 0x15, 0x02, 0x00, 0x00, 0xFF};
    command[4] = value >> 8;
    command[5] = value;
    
    // 计算异或校验码
    [self calculateXORCheckingCode:command length:sizeof(command)];
    
    NSData *data = [NSData dataWithBytes:command length:sizeof(command)];
    [self writeData:data toCharacteristic:_dataWriteCharacteristic periphralName:kDeviceScaleName];
}

- (void)setScaleFluidDensity:(NSUInteger)value
{
    NSLog(@"============ 厨房秤 设置液体密度 ============");
    Byte command[] = {0x23, 0x01, 0x16, 0x02, 0x00, 0x00, 0xFF};
    command[4] = value >> 8;
    command[5] = value;
    
    // 计算异或校验码
    [self calculateXORCheckingCode:command length:sizeof(command)];
    
    NSData *data = [NSData dataWithBytes:command length:sizeof(command)];
    [self writeData:data toCharacteristic:_dataWriteCharacteristic periphralName:kDeviceScaleName];
}

- (void)setScaleSynchroniseParam
{
    NSLog(@"============ 厨房秤 同步参数 ============");
    Byte command[] = {0x23, 0x01, 0x17, 0x00, 0xFF};
    
    // 计算异或校验码
    [self calculateXORCheckingCode:command length:sizeof(command)];
    
    NSData *data = [NSData dataWithBytes:command length:sizeof(command)];
    [self writeData:data toCharacteristic:_dataWriteCharacteristic periphralName:kDeviceScaleName];
}

#pragma mark 定时器

- (void)timerPoweroff {
    [self powerOffWithPeriphralName:kDeviceTimerName];
}

- (void)timerBattery {
    [self batteryWithPerphralName:kDeviceTimerName];
}

- (void)resetTimer {
    [self resetWithPeriphralName:kDeviceTimerName];
}

- (void)restoreTimer {
    [self restoreWithPeriphralName:kDeviceTimerName];
}

- (void)setTimerTime:(NSUInteger *)value index:(NSUInteger)index
{
    Byte command[] = {0x23, 0x02, 0x32, 0x04, 0x00, 0x00, 0x00, 0x00, 0xFF};
    command[4] = index;     // 定时器号
    command[5] = value[0];  // 时
    command[6] = value[1];  // 分
    command[7] = value[2];  // 秒
    
    // 计算异或校验码
    [self calculateXORCheckingCode:command length:sizeof(command)];
    
    NSData *data = [NSData dataWithBytes:command length:sizeof(command)];
    [self writeData:data toCharacteristic:_dataWriteCharacteristic periphralName:kDeviceTimerName];
}

- (void)setTimerDelay:(NSUInteger *)value index:(NSUInteger)index
{
    Byte command[] = {0x23, 0x02, 0x33, 0x04, 0x00, 0x00, 0x00, 0x00, 0xFF};
    command[4] = index;     // 定时器号
    command[5] = value[0];  // 时
    command[6] = value[1];  // 分
    command[7] = value[2];  // 秒
    
    // 计算异或校验码
    [self calculateXORCheckingCode:command length:sizeof(command)];
    
    NSData *data = [NSData dataWithBytes:command length:sizeof(command)];
    [self writeData:data toCharacteristic:_dataWriteCharacteristic periphralName:kDeviceTimerName];
}

- (void)setTimerStart:(NSUInteger)index
{
    Byte command[] = {0x23, 0x02, 0x34, 0x01, 0x00, 0xFF};
    command[4] = index;     // 定时器号
    
    // 计算异或校验码
    [self calculateXORCheckingCode:command length:sizeof(command)];
    
    NSData *data = [NSData dataWithBytes:command length:sizeof(command)];
    [self writeData:data toCharacteristic:_dataWriteCharacteristic periphralName:kDeviceTimerName];
}

- (void)setTimerStop:(NSUInteger)index
{
    Byte command[] = {0x23, 0x02, 0x35, 0x01, 0x00, 0xFF};
    command[4] = index;     // 定时器号
    
    // 计算异或校验码
    [self calculateXORCheckingCode:command length:sizeof(command)];
    
    NSData *data = [NSData dataWithBytes:command length:sizeof(command)];
    [self writeData:data toCharacteristic:_dataWriteCharacteristic periphralName:kDeviceTimerName];
}

- (void)setTimerClear:(NSUInteger)index
{
    Byte command[] = {0x23, 0x02, 0x36, 0x01, 0x00, 0xFF};
    command[4] = index;     // 定时器号
    
    // 计算异或校验码
    [self calculateXORCheckingCode:command length:sizeof(command)];
    
    NSData *data = [NSData dataWithBytes:command length:sizeof(command)];
    [self writeData:data toCharacteristic:_dataWriteCharacteristic periphralName:kDeviceTimerName];
}

- (void)setTimerWarningTemperature:(CGFloat)value
{
    Byte command[] = {0x23, 0x02, 0x37, 0x02, 0x00, 0x00, 0xFF};
    
    short temperature = value * 10;
    
    command[4] = temperature >> 8;
    command[5] = temperature;
    
    // 计算异或校验码
    [self calculateXORCheckingCode:command length:sizeof(command)];
    
    NSData *data = [NSData dataWithBytes:command length:sizeof(command)];
    [self writeData:data toCharacteristic:_dataWriteCharacteristic periphralName:kDeviceTimerName];
}

- (void)setTimerTemperatureUnit:(VMBleTemperatureUnit)value
{
    Byte command[] = {0x23, 0x02, 0x38, 0x01, 0x00, 0xFF};
    command[4] = value;     // 温度单位
    
    // 计算异或校验码
    [self calculateXORCheckingCode:command length:sizeof(command)];
    
    NSData *data = [NSData dataWithBytes:command length:sizeof(command)];
    [self writeData:data toCharacteristic:_dataWriteCharacteristic periphralName:kDeviceTimerName];
}

- (void)setTimerSynchroniseParam
{
    Byte command[] = {0x23, 0x02, 0x17, 0x00, 0xFF};
    
    // 计算异或校验码
    [self calculateXORCheckingCode:command length:sizeof(command)];
    
    NSData *data = [NSData dataWithBytes:command length:sizeof(command)];
    [self writeData:data toCharacteristic:_dataWriteCharacteristic periphralName:kDeviceTimerName];
}

- (void)setTimerSynchroniseTime:(NSUInteger *)time1 time2:(NSUInteger *)time2 time3:(NSUInteger *)time3
{
    Byte command[] = {0x23, 0x02, 0x39, 0x0F, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF};
    
    int index = 4;
    for (int i = 0; i < 3; i++)
    {
        command[index++] = time1[i];
    }
    for (int i = 0; i < 3; i++)
    {
        command[index++] = time2[i];
    }
    for (int i = 0; i < 3; i++)
    {
        command[index++] = time3[i];
    }
    
    // 计算异或校验码
    [self calculateXORCheckingCode:command length:sizeof(command)];
    
    NSData *data = [NSData dataWithBytes:command length:sizeof(command)];
    [self writeData:data toCharacteristic:_dataWriteCharacteristic periphralName:kDeviceTimerName];
}

#pragma mark 温度计

- (void)thermometerPoweroff {
    [self powerOffWithPeriphralName:kDeviceThermometerName];
}

- (void)thermometerBattery {
    [self batteryWithPerphralName:kDeviceThermometerName];
}

- (void)resetThermometer {
    [self resetWithPeriphralName:kDeviceThermometerName];
}

- (void)restoreThermometer {
    [self restoreWithPeriphralName:kDeviceThermometerName];
}

- (void)setThermometerWarningTemperature:(CGFloat)value
{
    NSLog(@"============ 温度计 设置报警温度 ============");
    Byte command[] = {0x23, 0x03, 0x52, 0x02, 0x00, 0x00, 0xFF};
    
    short temperature = value * 10;
    
    command[4] = temperature >> 8;
    command[5] = temperature;
    
    // 计算异或校验码
    [self calculateXORCheckingCode:command length:sizeof(command)];
    
    NSData *data = [NSData dataWithBytes:command length:sizeof(command)];
    [self writeData:data toCharacteristic:_dataWriteCharacteristic periphralName:kDeviceThermometerName];
}

- (void)setThermometerWarningColor:(NSUInteger *)value
{
    NSLog(@"============ 温度计 设置报警颜色 ============");
    Byte command[] = {0x23, 0x03, 0x53, 0x03, 0x00, 0x00, 0x00, 0xFF};
    command[4] = value[0];  // R
    command[5] = value[1];  // G
    command[6] = value[3];  // B
    
    // 计算异或校验码
    [self calculateXORCheckingCode:command length:sizeof(command)];
    
    NSData *data = [NSData dataWithBytes:command length:sizeof(command)];
    [self writeData:data toCharacteristic:_dataWriteCharacteristic periphralName:kDeviceThermometerName];
}

- (void)setThermometerGlintFrequency:(NSUInteger)value
{
    NSLog(@"============ 温度计 设置闪烁频率 ============");
    Byte command[] = {0x23, 0x03, 0x54, 0x02, 0x00, 0x00, 0xFF};
    command[4] = value >> 8;
    command[5] = value;
    
    // 计算异或校验码
    [self calculateXORCheckingCode:command length:sizeof(command)];
    
    NSData *data = [NSData dataWithBytes:command length:sizeof(command)];
    [self writeData:data toCharacteristic:_dataWriteCharacteristic periphralName:kDeviceThermometerName];
}

- (void)setThermometerTemperatureUnit:(VMBleTemperatureUnit)value
{
    NSLog(@"============ 温度计 设置单位 ============");
    Byte command[] = {0x23, 0x03, 0x55, 0x01, 0x00, 0xFF};
    command[4] = value;  // 温度单位
    
    // 计算异或校验码
    [self calculateXORCheckingCode:command length:sizeof(command)];
    
    NSData *data = [NSData dataWithBytes:command length:sizeof(command)];
    [self writeData:data toCharacteristic:_dataWriteCharacteristic periphralName:kDeviceThermometerName];
}

- (void)setThermometerSynchroniseParam
{
    NSLog(@"============ 温度计 同步参数 ============");
    Byte command[] = {0x23, 0x03, 0x17, 0x00, 0xFF};
    
    // 计算异或校验码
    [self calculateXORCheckingCode:command length:sizeof(command)];
    
    NSData *data = [NSData dataWithBytes:command length:sizeof(command)];
    [self writeData:data toCharacteristic:_dataWriteCharacteristic periphralName:kDeviceThermometerName];
}

#pragma mark - analysze command

- (void)analyzeCommand:(NSData *)data
{
//    NSLog(@"============ vm analyzeCommand ============");
    
    Byte *values = (Byte *)[data bytes];
    
    switch (values[1])
    {
        case VMBleDeviceScale:
            [self analyzeScaleCommand:data];
            break;
        case VMBleDeviceTimer:
            [self analyzeTimerCommand:data];
            break;
        case VMBleDeviceThermometer:
            [self analyzeThermometerCommand:data];
            break;
    }
}

- (void)getBattery:(NSData *)data
{
    NSLog(@"--->> 更新电池 : %@", data);
    
    Byte *values = (Byte *)[data bytes];
    
    NSUInteger value = values[0];
    
    if (_delegate && [_delegate respondsToSelector:@selector(didUpdateBattery:)])
    {
        [_delegate didUpdateBattery:value];
    }
}

#pragma mark 厨房秤

- (void)analyzeScaleCommand:(NSData *)data
{
    Byte *values = (Byte *)[data bytes];
    
    switch (values[2])
    {
        case 0x21:
            [self getScaleWeight:data];
            break;
        case 0x22:
            [self getScaleSynchroniseUnit:data];
            break;
    }
}

- (void)getScaleWeight:(NSData *)data
{
    BOOL flag = [self verifyXORCheckingCode:(Byte *)[data bytes] length:[data length]];
    if ([data length] >= 10 && flag)
    {
        Byte *values = (Byte *)[data bytes];
        
        NSUInteger uCurrentWeight;
        NSUInteger uTotalWeight;
        
        VMBleMassUnit unit;
        
        uCurrentWeight = values[4];
        uCurrentWeight = (uCurrentWeight << 8) + values[5];
        
        uTotalWeight = values[6];
        uTotalWeight = (uTotalWeight << 8) +values[7];
        
        unit = values[8];
        
        if (_delegate && [_delegate respondsToSelector:@selector(didUpdateScaleWeight:totalWeight:)])
        {
            [_delegate didUpdateScaleWeight:uCurrentWeight totalWeight:uTotalWeight];
        }
    }
    else
    {
        NSLog(@"%s --- data loss", __func__);
    }
}

- (void)getScaleSynchroniseUnit:(NSData *)data
{
    BOOL flag = [self verifyXORCheckingCode:(Byte *)[data bytes] length:[data length]];
    if ([data length] >= 6 && flag)
    {
        Byte *values = (Byte *)[data bytes];
        
        VMBleMassUnit unit;
        
        unit = values[4];
        
        if (_delegate && [_delegate respondsToSelector:@selector(didUpdateScaleUnit:)])
        {
            [_delegate didUpdateScaleUnit:unit];
        }
    }
    else
    {
        NSLog(@"%s --- data loss", __func__);
    }
}

#pragma mark 定时器

- (void)analyzeTimerCommand:(NSData *)data
{
    Byte *values = (Byte *)[data bytes];
    
    switch (values[2])
    {
        case 0x41:
            [self getTimerSynchroniseTime:data];
            break;
        case 0x42:
            [self getTimerSynchroniseDelay:data];
            break;
        case 0x43:
            [self getTimerSynchroniseStart:data];
            break;
        case 0x44:
            [self getTimerSynchroniseStop:data];
            break;
        case 0x45:
            [self getTimerSynchroniseClear:data];
            break;
        case 0x46:
            [self getTimerSynchroniseWarningTemperature:data];
            break;
        case 0x47:
            [self getTimerSynchroniseTemperatureUnit:data];
            break;
        case 0x21:
            [self getTimerSynchroniseTemperature:data];
            break;
        case 0x48:
            [self getTimerSynchroniseParamTimer1:data];
            break;
        case 0x49:
            [self getTimerSynchroniseParamTimer2:data];
            break;
        case 0x4A:
            [self getTimerSynchroniseParamTimer3:data];
            break;
        case 0x4B:
            [self getTimerSynchroniseParamWarningTemperature:data];
            break;
    }
}

- (void)getTimerSynchroniseTime:(NSData *)data
{
    BOOL flag = [self verifyXORCheckingCode:(Byte *)[data bytes] length:[data length]];
    if ([data length] >= 9 && flag)
    {
        Byte *values = (Byte *)[data bytes];
        VMBleDeviceTimerNo timerNo;
        NSUInteger *time = (NSUInteger *)malloc(sizeof(NSUInteger) * 3);
        
        timerNo = values[4];    // 定时器号
        time[0] = values[5];    // 时
        time[1] = values[6];    // 分
        time[2] = values[7];    // 秒
        
        if (_delegate && [_delegate respondsToSelector:@selector(didUpdateTimerSettingTime:index:)])
        {
            [_delegate didUpdateTimerSettingTime:time index:timerNo];
        }
    }
    else
    {
        NSLog(@"%s --- data loss", __func__);
    }
}

- (void)getTimerSynchroniseDelay:(NSData *)data
{
    BOOL flag = [self verifyXORCheckingCode:(Byte *)[data bytes] length:[data length]];
    if ([data length] >= 9 && flag)
    {
        Byte *values = (Byte *)[data bytes];
        VMBleDeviceTimerNo timerNo;
        NSUInteger *time = (NSUInteger *)malloc(sizeof(NSUInteger) * 3);
        
        timerNo = values[4];    // 定时器号
        time[0] = values[5];    // 时
        time[1] = values[6];    // 分
        time[2] = values[7];    // 秒
        
        if (_delegate && [_delegate respondsToSelector:@selector(didUpdateTimerSettingDelay:index:)])
        {
            [_delegate didUpdateTimerSettingDelay:time index:timerNo];
        }
    }
    else
    {
        NSLog(@"%s --- data loss", __func__);
    }
}

- (void)getTimerSynchroniseStart:(NSData *)data
{
    BOOL flag = [self verifyXORCheckingCode:(Byte *)[data bytes] length:[data length]];
    if ([data length] >= 6 && flag)
    {
        Byte *values = (Byte *)[data bytes];
        VMBleDeviceTimerNo timerNo;
        
        timerNo = values[4];    // 定时器号
        
        if (_delegate && [_delegate respondsToSelector:@selector(didUpdateTimerStart:)])
        {
            [_delegate didUpdateTimerStart:timerNo];
        }
    }
    else
    {
        NSLog(@"%s --- data loss", __func__);
    }
}

- (void)getTimerSynchroniseStop:(NSData *)data
{
    BOOL flag = [self verifyXORCheckingCode:(Byte *)[data bytes] length:[data length]];
    if ([data length] >= 6 && flag)
    {
        Byte *values = (Byte *)[data bytes];
        VMBleDeviceTimerNo timerNo;
        
        timerNo = values[4];    // 定时器号
        
        if (_delegate && [_delegate respondsToSelector:@selector(didUpdateTimerStop:)])
        {
            [_delegate didUpdateTimerStop:timerNo];
        }
    }
    else
    {
        NSLog(@"%s --- data loss", __func__);
    }
}

- (void)getTimerSynchroniseClear:(NSData *)data
{
    BOOL flag = [self verifyXORCheckingCode:(Byte *)[data bytes] length:[data length]];
    if ([data length] >= 6 && flag)
    {
        Byte *values = (Byte *)[data bytes];
        VMBleDeviceTimerNo timerNo;
        
        timerNo = values[4];    // 定时器号
        
        if (_delegate && [_delegate respondsToSelector:@selector(didUpdateTimerClear:)])
        {
            [_delegate didUpdateTimerClear:timerNo];
        }
    }
    else
    {
        NSLog(@"%s --- data loss", __func__);
    }
}

- (void)getTimerSynchroniseWarningTemperature:(NSData *)data
{
    BOOL flag = [self verifyXORCheckingCode:(Byte *)[data bytes] length:[data length]];
    if ([data length] >= 7 && flag)
    {
        Byte *values = (Byte *)[data bytes];
        
        short temperature = values[4]; // 报警温度值
        temperature = (temperature << 8) + values[5];
        
        if (_delegate && [_delegate respondsToSelector:@selector(didUpdateTimerWarningTemperature:)])
        {
            [_delegate didUpdateTimerWarningTemperature:(temperature/10.0f)];
        }
    }
    else
    {
        NSLog(@"%s --- data loss", __func__);
    }
}

- (void)getTimerSynchroniseTemperatureUnit:(NSData *)data
{
    BOOL flag = [self verifyXORCheckingCode:(Byte *)[data bytes] length:[data length]];
    if ([data length] >= 6 && flag)
    {
        Byte *values = (Byte *)[data bytes];
        VMBleTemperatureUnit temperatureUnit;
        
        temperatureUnit = values[4];    // 温度单位
        
        if (_delegate && [_delegate respondsToSelector:@selector(didUpdateTimerTemperatureUnit:)])
        {
            [_delegate didUpdateTimerTemperatureUnit:temperatureUnit];
        }
    }
    else
    {
        NSLog(@"%s --- data loss", __func__);
    }
}

- (void)getTimerSynchroniseTemperature:(NSData *)data
{
    BOOL flag = [self verifyXORCheckingCode:(Byte *)[data bytes] length:[data length]];
    if ([data length] >= 7 && flag)
    {
        Byte *values = (Byte *)[data bytes];
        
        short sTemperature = values[4]; // 上报数据(温度)
        sTemperature = (sTemperature << 8) + values[5];
        
        if (_delegate && [_delegate respondsToSelector:@selector(didUpdateTimerTemperature:)])
        {
            [_delegate didUpdateTimerTemperature:(sTemperature/10.0f)];
        }
    }
    else
    {
        NSLog(@"%s --- data loss", __func__);
    }
}

// 参数同步

- (void)getTimerSynchroniseParamTimer1:(NSData *)data
{
    BOOL flag = [self verifyXORCheckingCode:(Byte *)[data bytes] length:[data length]];
    if ([data length] >= 10 && flag)
    {
        Byte *values = (Byte *)[data bytes];
        VMBleDeviceTimerNo timerNo;
        NSUInteger *time = (NSUInteger *)malloc(sizeof(NSUInteger) * 3);
        VMBleDeviceTimerStatus *timerStatus = (VMBleDeviceTimerStatus *)malloc(sizeof(VMBleDeviceTimerStatus) * 3);
        
        timerNo = values[4];    // 定时器号
        time[0] = values[5];    // 时
        time[1] = values[6];    // 分
        time[2] = values[7];    // 秒
        
        for (int i = 2; i >= 0; i--)
        {
            if ((values[8] & (1 << i*2)))
            {
                timerStatus[i] = VMBleDeviceTimerOn;
            }
            else
            {
                timerStatus[i] = VMBleDeviceTimerOff;
            }
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(didUpdateTimerParameter:status:index:)])
        {
            [_delegate didUpdateTimerParameter:time status:timerStatus index:timerNo];
        }
    }
    else
    {
        NSLog(@"%s --- data loss", __func__);
    }
}

- (void)getTimerSynchroniseParamTimer2:(NSData *)data
{
    BOOL flag = [self verifyXORCheckingCode:(Byte *)[data bytes] length:[data length]];
    if ([data length] >= 10 && flag)
    {
        Byte *values = (Byte *)[data bytes];
        VMBleDeviceTimerNo timerNo;
        NSUInteger *time = (NSUInteger *)malloc(sizeof(NSUInteger) * 3);
        VMBleDeviceTimerStatus *timerStatus = (VMBleDeviceTimerStatus *)malloc(sizeof(VMBleDeviceTimerStatus) * 3);
        
        timerNo = values[4];    // 定时器号
        time[0] = values[5];    // 时
        time[1] = values[6];    // 分
        time[2] = values[7];    // 秒
        
        for (int i = 2; i >= 0; i--)
        {
            if ((values[8] & (1 << i*2)))
            {
                timerStatus[i] = 0x01;
            }
            else
            {
                timerStatus[i] = 0x00;
            }
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(didUpdateTimerParameter:status:index:)])
        {
            [_delegate didUpdateTimerParameter:time status:timerStatus index:timerNo];
        }
    }
    else
    {
        NSLog(@"%s --- data loss", __func__);
    }
}

- (void)getTimerSynchroniseParamTimer3:(NSData *)data
{
    BOOL flag = [self verifyXORCheckingCode:(Byte *)[data bytes] length:[data length]];
    if ([data length] >= 10 && flag)
    {
        Byte *values = (Byte *)[data bytes];
        VMBleDeviceTimerNo timerNo;
        NSUInteger *time = (NSUInteger *)malloc(sizeof(NSUInteger) * 3);
        VMBleDeviceTimerStatus *timerStatus = (VMBleDeviceTimerStatus *)malloc(sizeof(VMBleDeviceTimerStatus) * 3);
        
        timerNo = values[4];    // 定时器号
        time[0] = values[5];    // 时
        time[1] = values[6];    // 分
        time[2] = values[7];    // 秒
        
        for (int i = 2; i >= 0; i--)
        {
            if ((values[8] & (1 << i*2)))
            {
                timerStatus[i] = 0x01;
            }
            else
            {
                timerStatus[i] = 0x00;
            }
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(didUpdateTimerParameter:status:index:)])
        {
            [_delegate didUpdateTimerParameter:time status:timerStatus index:timerNo];
        }
    }
    else
    {
        NSLog(@"%s --- data loss", __func__);
    }
}

- (void)getTimerSynchroniseParamWarningTemperature:(NSData *)data
{
    BOOL flag = [self verifyXORCheckingCode:(Byte *)[data bytes] length:[data length]];
    if ([data length] >= 8 && flag)
    {
        Byte *values = (Byte *)[data bytes];
        short temperature;
        VMBleTemperatureUnit temperatureUnit;
        
        temperature = values[4];
        temperature = (temperature << 8) + values[5];
        
        temperatureUnit = values[6];
        
        if (_delegate && [_delegate respondsToSelector:@selector(didUpdateTimerParameterWarningTemperature:unit:)])
        {
            [_delegate didUpdateTimerParameterWarningTemperature:(temperature/10.0f) unit:temperatureUnit];
        }
    }
    else
    {
        NSLog(@"%s --- data loss", __func__);
    }
}

#pragma mark 温度计

- (void)analyzeThermometerCommand:(NSData *)data
{
    Byte *values = (Byte *)[data bytes];
    
    switch (values[2])
    {
        case 0x21:
            [self getThermometerCurrentTemperature:data];
            break;
        case 0x46:
            [self getThermometerWarningTemperature:data];
            break;
        case 0x47:
            [self getThermometerTemperatureUnit:data];
            break;
        case 0x22:
            [self getThermometerSynchroniseParameter:data];
            break;
    }
}

- (void)getThermometerCurrentTemperature:(NSData *)data
{
    NSLog(@"============ 温度计 获取当前温度 ============");
    BOOL flag = [self verifyXORCheckingCode:(Byte *)[data bytes] length:[data length]];
    if ([data length] >= 7 && flag)
    {
        Byte *values = (Byte *)[data bytes];
        short temperature;
        
        temperature = values[4];
        temperature = (temperature << 8) + values[5];
        
        NSLog(@"temperature = %hi", temperature);
        
        if (_delegate && [_delegate respondsToSelector:@selector(didUpdateThermometerCurrentTemperature:)])
        {
            [_delegate didUpdateThermometerCurrentTemperature:(temperature/10.0f)];
        }
    }
    else
    {
        NSLog(@"%s --- data loss", __func__);
    }
}

- (void)getThermometerWarningTemperature:(NSData *)data
{
    NSLog(@"============ 温度计 获取报警温度 ============");
    BOOL flag = [self verifyXORCheckingCode:(Byte *)[data bytes] length:[data length]];
    if ([data length] >= 7 && flag)
    {
        Byte *values = (Byte *)[data bytes];
        short temperature;
        
        temperature = values[4];
        temperature = (temperature << 8) + values[5];
        
        if (_delegate && [_delegate respondsToSelector:@selector(didUpdateThermometerWarningTemperature:)])
        {
            [_delegate didUpdateThermometerWarningTemperature:(temperature/10.0f)];
        }
    }
    else
    {
        NSLog(@"%s --- data loss", __func__);
    }
}

- (void)getThermometerTemperatureUnit:(NSData *)data
{
    NSLog(@"============ 温度计 获取单位 ============");
    BOOL flag = [self verifyXORCheckingCode:(Byte *)[data bytes] length:[data length]];
    if ([data length] >= 6 && flag)
    {
        Byte *values = (Byte *)[data bytes];
        VMBleTemperatureUnit temperatureUnit;
        
        temperatureUnit = values[4];
        
        if (_delegate && [_delegate respondsToSelector:@selector(didUpdateThermometerTemperatureUnit:)])
        {
            [_delegate didUpdateThermometerTemperatureUnit:temperatureUnit];
        }
    }
    else
    {
        NSLog(@"%s --- data loss", __func__);
    }
}

- (void)getThermometerSynchroniseParameter:(NSData *)data
{
    NSLog(@"============ 温度计 获取同步参数 ============");
    BOOL flag = [self verifyXORCheckingCode:(Byte *)[data bytes] length:[data length]];
    if ([data length] >= 13 && flag)
    {
        Byte *values = (Byte *)[data bytes];
        short temperature;
        VMBleTemperatureUnit temperatureUnit;
        NSUInteger *color = (NSUInteger *)malloc(sizeof(NSUInteger) * 3);
        NSUInteger frequency;
        
        temperature = values[4];
        temperature = (temperature << 8) + values[5];
        
        temperatureUnit = values[6];
        
        color[0] = values[7];
        color[1] = values[8];
        color[2] = values[9];
        
        frequency = values[10];
        frequency = (frequency << 8) + values[11];
        
        if (_delegate && [_delegate respondsToSelector:@selector(didUpdateThermometerParameter:unit:color:frequency:)])
        {
            [_delegate didUpdateThermometerParameter:(temperature/10.0f) unit:temperatureUnit color:color frequency:frequency];
        }
    }
    else
    {
        NSLog(@"%s --- data loss", __func__);
    }
}

@end
