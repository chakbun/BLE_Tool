//
//  VMBleConnector.h
//  BLETool
//
//  Created by Jaben on 14-12-30.
//  Copyright (c) 2014年 Jaben. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRBluetoothManager.h"


//我们手头上的产品广播名
#define kDeviceTimerName @"TAv22s-4C65E983"
#define kDeviceThermometerName @"BLE Scale-148DE45C"
#define kDeviceScaleName @"BLE Scale-4C65C5CA"

//客户测试的的产品广播名
//#define kDeviceTimerName @"TAv22s-4C657AEA"
//#define kDeviceThermometerName @"BLE Scale-4C4CED88"
//#define kDeviceScaleName @"BLE Scale-148DE8B2"

static NSString *const VM_Periperal     = @"VM_Periperal";
static NSString *const VM_BroadcastData = @"VM_BroadcastData";
static NSString *const VM_RSSI          = @"VM_RSSI";

typedef NS_ENUM(Byte, VMBleDeviceID) {
    VMBleDeviceScale = 0x01,
    VMBleDeviceTimer = 0x02,
    VMBleDeviceThermometer = 0x03,
};

typedef NS_ENUM(Byte, VMBleDeviceTimerNo) {
    VMBleDeviceTimer1 = 0x01,
    VMBleDeviceTimer2 = 0x02,
    VMBleDeviceTimer3 = 0x03,
};

typedef NS_ENUM(Byte, VMBleDeviceTimerStatus) {
    VMBleDeviceTimerOff = 0x00,
    VMBleDeviceTimerOn = 0x01,
};

typedef NS_ENUM(Byte, VMBleMassUnit) {
    VMBleMassUnitGram = 0x01,
    VMBleMassUnitPoundAndOunce = 0x02,
    VMBleMassUnitMilliliter = 0x03,
};

typedef NS_ENUM(Byte, VMBleTemperatureUnit) {
    VMBleTemperatureUnitCelsius = 0x01,
    VMBleTemperatureUnitFahrenheit = 0x02,
};


static NSString *const kDataWriteServiceUUID = @"FFE5";
static NSString *const kDataReadServiceUUID = @"FFE0";
static NSString *const kBatteryServiceUUID = @"180F";
static NSString *const kRSSIServiceUUID = @"FFA0";
static NSString *const kHardwareServiceUUID = @"FF90";
static NSString *const kDeviceInfoServiceUUID = @"180A";

static NSString *const kDataWriteCharacteristicUUID = @"FFE9";
static NSString *const kDataReadCharacteristicUUID = @"FFE4";
static NSString *const kBatteryReadCharacteristicUUID = @"2A19";
static NSString *const kRSSIReadCharacteristicUUID = @"FFA1";
static NSString *const kRSSICircleWriteCharacteristicUUID = @"FFA2";
static NSString *const kHardwareNameCharacteristicUUID = @"FF91";
static NSString *const kHardwareResetCharacteristicUUID = @"FF94";
static NSString *const kHardwareIDCharacteristicUUID = @"FF96";
static NSString *const kHardwarePowerOffCharacteristicUUID = @"FF99";
static NSString *const kDeviceIDCharacteristicUUID = @"2A23";
static NSString *const kDeviceVersionCharacteristicUUID = @"2A26";


@protocol VMBleConnectorDeledate <NSObject>

@optional

- (void)didUpdateState:(CBCentralManagerState)state;

- (void)didFoundPeripheralInformation:(NSDictionary *)peripheralInfo;

- (void)didConnectPeriphral:(CBPeripheral *)periphral;
- (void)didFailToConnectPeriphral:(CBPeripheral *)periphral;
- (void)didDisconnectPeriphral:(CBPeripheral *)periphral;
- (void)didDiscoverCharacteristicOfService:(CBService *)service fromPeriperal:(CBPeripheral *)periphral;

- (void)didUpdateBattery:(NSUInteger)value;

- (void)didUpdateScaleWeight:(NSUInteger)currentWeight totalWeight:(NSUInteger)totalWeight;
- (void)didUpdateScaleUnit:(VMBleMassUnit)unit;

- (void)didUpdateTimerSettingTime:(NSUInteger *)values index:(NSUInteger)index;
- (void)didUpdateTimerSettingDelay:(NSUInteger *)values index:(NSUInteger)index;
- (void)didUpdateTimerStart:(NSUInteger)index;
- (void)didUpdateTimerStop:(NSUInteger)index;
- (void)didUpdateTimerClear:(NSUInteger)index;
- (void)didUpdateTimerWarningTemperature:(CGFloat)temperature;
- (void)didUpdateTimerTemperatureUnit:(VMBleTemperatureUnit)unit;
- (void)didUpdateTimerTemperature:(CGFloat)temperature;
- (void)didUpdateTimerParameter:(NSUInteger *)time status:(VMBleDeviceTimerStatus *)status index:(NSUInteger)index;
- (void)didUpdateTimerParameterWarningTemperature:(CGFloat)temperature unit:(VMBleTemperatureUnit)unit;

- (void)didUpdateThermometerCurrentTemperature:(CGFloat)temperature;
- (void)didUpdateThermometerWarningTemperature:(CGFloat)temperature;
- (void)didUpdateThermometerTemperatureUnit:(VMBleTemperatureUnit)unit;
- (void)didUpdateThermometerParameter:(CGFloat)warningTemperature unit:(VMBleTemperatureUnit)unit color:(NSUInteger *)color frequency:(NSUInteger)frequency;

@end


@interface VMBleConnector : NSObject

@property (nonatomic, strong) id<VMBleConnectorDeledate>delegate;

+ (instancetype)shareManager;

- (void)startScanPeripherals:(NSArray *)serviceUUIDs;
- (void)stopScanPeripherals;

- (void)connectPeripheral:(CBPeripheral *)peripheral withCompleted:(void(^)(BOOL success))complted;

- (void)scalePoweroff;
- (void)scaleBattery;
- (void)resetScale;
- (void)restoreScale;
- (void)setScaleUnit:(VMBleMassUnit)value;
- (void)setScalePeeling;
- (void)setScaleClear;
- (void)setScaleTargetWeight:(NSUInteger)value;
- (void)setScaleFluidDensity:(NSUInteger)value;
- (void)setScaleSynchroniseParam;

- (void)timerPoweroff;
- (void)timerBattery;
- (void)resetTimer;
- (void)restoreTimer;
- (void)setTimerTime:(NSUInteger *)value index:(NSUInteger)index;
- (void)setTimerDelay:(NSUInteger *)value index:(NSUInteger)index;
- (void)setTimerStart:(NSUInteger)index;
- (void)setTimerStop:(NSUInteger)index;
- (void)setTimerClear:(NSUInteger)index;
- (void)setTimerWarningTemperature:(CGFloat)value;
- (void)setTimerTemperatureUnit:(VMBleTemperatureUnit)value;
- (void)setTimerSynchroniseParam;
- (void)setTimerSynchroniseTime:(NSUInteger *)time1 time2:(NSUInteger *)time2 time3:(NSUInteger *)time3;

- (void)thermometerPoweroff;
- (void)thermometerBattery;
- (void)resetThermometer;
- (void)restoreThermometer;
- (void)setThermometerWarningTemperature:(CGFloat)value;
- (void)setThermometerWarningColor:(NSUInteger *)value;
- (void)setThermometerGlintFrequency:(NSUInteger)value;
- (void)setThermometerTemperatureUnit:(VMBleTemperatureUnit)value;
- (void)setThermometerSynchroniseParam;

@end
