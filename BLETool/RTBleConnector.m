//
//  RTBleConnector.m
//  BLETool
//
//  Created by Jaben on 15/5/6.
//  Copyright (c) 2015年 Jaben. All rights reserved.
//

#import "RTBleConnector.h"
#import "RTCommand.h"

static Byte const BYTE_iOS_Mark = 0x84;
static Byte const BYTE_Head = 0xf0;
static Byte const BYTE_Tail = 0xf1;

//FFF1  == read write
#define kCharacterRW(periphralName) [NSString stringWithFormat:@"RW_%@",periphralName]

// 0734594A-A8E7-4B1A-A6B1-CD5243059A57 ==  notify
#define kCharacterN(periphralName) [NSString stringWithFormat:@"N_%@",periphralName]

// 8B00ACE7-EB0B-49B0-BBE9-9AEE0A26E1A3 == write with no response
#define kCharacterW(periphralName) [NSString stringWithFormat:@"W_%@",periphralName]

// E06D5EFB-4F4A-45C0-9EB1-371AE5A14AD4 == Read notify
#define kCharacterRN(periphralName) [NSString stringWithFormat:@"RN_%@",periphralName]

@interface RTBleConnector ()<JRBluetoothManagerDelegate>

@property (nonatomic, strong) NSMutableDictionary *characteristicDicionary;

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
        
        _characteristicDicionary = [[NSMutableDictionary alloc] init];

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
    
    NSLog(@"servie: %@", [service.UUID UUIDString]);
    if ([[service.UUID UUIDString] isEqualToString:RTServiceUUID]) {
        for(CBCharacteristic *characteristic in service.characteristics) {
            NSString *characteristicID = [characteristic.UUID UUIDString];
            NSLog(@"============ characteristic UUID %@ ============",characteristicID);
            if ([characteristicID isEqualToString:RT_N_ChracteristicUUID]) {
                
                [periphral setNotifyValue:YES forCharacteristic:characteristic];
                [self.characteristicDicionary setObject:characteristic forKey:kCharacterN(periphral.name)];
                
            }else if([characteristicID isEqualToString:RT_RN_ChracteristicUUID]) {
                
                [periphral setNotifyValue:YES forCharacteristic:characteristic];
                [self.characteristicDicionary setObject:characteristic forKey:kCharacterRN(periphral.name)];
                
            }else if([characteristicID isEqualToString:RT_RW_ChracteristicUUID]) {
                
                [self.characteristicDicionary setObject:characteristic forKey:kCharacterRW(periphral.name)];
                
            }else if([characteristicID isEqualToString:RT_W_ChracteristicUUID]) {
                
                [self.characteristicDicionary setObject:characteristic forKey:kCharacterW(periphral.name)];
            }
        }
    }
    
}

- (void)didUpdateValue:(NSData *)data fromPeripheral:(CBPeripheral *)peripheral characteritic:(CBCharacteristic *)characteristic {
    
    if ([[characteristic.UUID UUIDString] isEqualToString:RT_N_ChracteristicUUID]) {
        if (data.length < 17) {
            return;
        }
        
        [self parseData:data];
    }
}

- (void)didWriteValueForCharacteristic:(CBCharacteristic *)characteristic inPeripheral:(CBPeripheral *)peripheral {
    
}

#pragma mark - Misc

#pragma mark - Read

- (void)parseData:(NSData *)rawData {
    /*
     rawData = head(0),body(1-14),checkSum(15),tail(16)
     total:17bytes
     */
    
    Byte *bodyData = (Byte *)[[rawData subdataWithRange:NSMakeRange(1, 14)] bytes]; // 14 bytes
    
    [self parseByteOfAddress1:bodyData[0]];
    [self parseByteOfAddress2:bodyData[1]];

    
}

//地址 2 按摩机芯速度和揉捏头宽度位置指示 机芯速度是指当前设定的目标速度，揉捏头宽度指按摩头当前位置

- (void)parseByteOfAddress2:(Byte)addr {
    /*
     //揉捏头宽度位置
     00：未知（上电后，揉捏电机还未加电，并且此时揉捏头不处于宽、中、窄三个点）
     01：揉捏头最窄
     02：揉捏头中间
     03：揉捏头最宽
     */
    int kneadFlag = (addr & 3);
    /*
     00（二进制000）：停止，
     01（二进制001）速度最小，
     02（二进制010）速度较小，
     03（二进制011）速度中小，
     04（二进制100）速度中大，
     05（二进制101）速度较大，
     06（二级制110）速度最大，
     07（二进制111）：保留
     */
    int speedFlag = (addr >> 2) & 7;
    /*
     0：滚轮关，当滚轮关闭时速度必然为零
     1：滚轮开
     手动模式滚轮开，速度可进行三档调节，在自动模式滚轮速度受自动程序控制
     */
    int rollerFlag = (addr >> 5) & 1;
    /*
     0：关
     1：开
     */
    int heatingFlag = (addr >> 6) & 1;
}

// 地址 1 按摩椅程序运行状态和按摩手法

- (void)parseByteOfAddress1:(Byte)addr {
    /*
     3D标示
     0：机器无3D功能
     1:机器具备3D功能
     */
    int _3dFlag = addr & 1;
    
    /*
     小腿伸缩标示
     0：机器具备小腿伸缩功能
     1:机器无小腿伸缩，此时APP程序中的腿部伸缩按钮变灰
     */
    int calfStretchFlag = (addr >> 1) & 1;
    /*
     新程序名称标识
     0：旧程序名称
     1:新程序名称
     */
    int nameFlag = (addr >> 2) & 1;
    /*
     按摩手法
     00：停止
     01：揉捏
     02：敲击
     03：揉敲同步
     04：叩击
     05：指压
     06：韵律按摩
     07：搓背
     */
    int massageFlag = (addr >> 3) & 7;
    /*
     按摩椅运行状态
     0：按摩椅处于待机,主电源关闭，省电模式
     1：按摩椅处于非待机状态，此时手控器相应的图标点亮
     */
    int state = (addr >> 6) & 1;
}

#pragma mark - Write


- (NSData *)dataWithFuc:(NSInteger)fuctionCommand {
    
    // fucByte = 1 byte ---> 功能键
    /*
     7位校验和（Checksum）将地址1和地址2的数据相加后取反码，再与0x7F相与变为7位数据
     */
    NSInteger sumData = fuctionCommand + (NSInteger)BYTE_iOS_Mark;
    NSInteger contraryData =  ~sumData;
    NSInteger checkSum = contraryData & 0x7f;
    
    Byte commandBody[] = {BYTE_iOS_Mark, fuctionCommand, checkSum};
    
    NSData *bodayData = [NSData dataWithBytes:&commandBody length:3];
    
    /*
     bodayData = 3byte ---> 控制设备标识 功能键 校验
     */
    return bodayData;
}

- (NSData *)fillDataHeadAndTail:(NSData *)data {
    
    /*
     5 bytes:
     1: 协议头，2:控制设备标识 3:功能键 4:校验 5:尾部
     */
    
    NSMutableData *sendData = [NSMutableData dataWithBytes:&BYTE_Head length:1];
    [sendData appendData:data];
    [sendData appendBytes:&BYTE_Tail length:1];
    return sendData;
}

- (void)sendDataToPeripheral:(NSData *)data {
    
    CBCharacteristic *writeCharacteritic = self.characteristicDicionary[kCharacterW(RTLocalName)];
    
    [[JRBluetoothManager shareManager] writeData:data toPeriperalWithName:RTLocalName characteritic:writeCharacteritic type:CBCharacteristicWriteWithoutResponse];
}

#pragma mark - Public
#pragma mark - BLE


- (void)startScanRTPeripheral:(NSArray *)serviceUUIDs {
    [[JRBluetoothManager shareManager] startScanPeripherals:serviceUUIDs];
}

- (void)stopScanRTPeripheral {
    [[JRBluetoothManager shareManager] stopScanPeripherals];
}

- (void)connectRTPeripheral:(CBPeripheral *)peripheral {
    [[JRBluetoothManager shareManager] connectPeripheral:peripheral];
}

- (void)cancelConnectRTPeripheral:(CBPeripheral *)peripheral {
    [[JRBluetoothManager shareManager] cancelConnectPeriphral:peripheral];
}

#pragma mark - Command

- (void)controlMode:(RTControlMode)mode {
    
    NSInteger commnad[] = {NORMAL_CTRL,ENGGER_CTRL};
    
    NSData *bodyData = [self dataWithFuc:commnad[mode]];
    NSData *sendData = [self fillDataHeadAndTail:bodyData];
    [self sendDataToPeripheral:sendData];
}

@end
