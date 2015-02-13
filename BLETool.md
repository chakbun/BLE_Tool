README
===
## 描叙

BLE(bluetooth low energy)，低功耗蓝牙，蓝牙4.0

## 框架
CoreBluetooth

官网：
https://developer.apple.com/library/ios/documentation/NetworkingInternetWeb/Conceptual/CoreBluetooth_concepts/AboutCoreBluetooth/Introduction.html

## 设备要求

* iOS5.0 +
* iPhone4s +
* iPad3 +

## 应用情景

使用iPhone连接一个电子温度计，电子温度计将测量的数据上传到iPhone。<br>
场景中iPhone表示一个中心center, 电子温度计表示一个外设periphral。中心可主动扫描，连接，断开，读写外设。

实现上面的场景，我们一步步来。

### 中心CBCentralManager

#### 扫描与连接

现在有一台iPhone6在手，首先中心需要找出外设。扫描的作用就是这样了。
依赖一个CBCentralManager实例完成，实现它的几个回调方法,包括：

* 方法c1:蓝牙状态


```
-(void)centralManagerDidUpdateState:(CBCentralManager *)central;
```

* 方法c2:发现外设

```
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;
```

* 方法c3:连接外设成功

```
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;
```

* 方法c4:连接外设失败

```
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
```

* 方法c5:连接断开

```
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
```

在方法c1中， centeral.state == CBCentralManagerStatePoweredOn 就可以扫描外设，采用CBCentralManager的实例方法


```
-(void)scanForPeripheralsWithServices:(NSArray *)serviceUUIDs options:(NSDictionary *)options;
```

当发现外设，方法c2就会被调用。(⚠只有在CBCentralManagerStatePoweredOn下扫描才会回调哦)。方法c2中，已经找到了外设CBPeripheral，还有广播信息advertisementData以及信号强度RSSI

找到外设，就连接它吧。还是CBCentralManager的实例方法

```
-(void)connectPeripheral:(CBPeripheral *)peripheral options:(NSDictionary *)options;
```

连接成功后👉方法c3会被执行。（失败的话👉方法c4）

到这里，iPhone6 已经成功连接到电子温度计了。🎉 👏 

### 外设CBPeripheral

我们说回外设CBPeripheral，包含着name，state 和 services几个属性。

怎么理解services❓ services表示着外设可提供给中心的服务。电子温度计有设备的信息给中心知道，也可以让中心去实现开关，读取，设置的控制服务。（这些服务以及下面的特性（通道）是电子温度计厂商决定）

同中心一样，现实CBPeripheral几个回调方法，包括：

方法p1:　发现服务

```
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error;
```


方法p2:　发现特性（通道）

```
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
```


方法p3:　读回调

```
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
```


方法p4:　写回调

```
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{}
```


#### 发现服务&特性

在中心连接外设成功后，设置外设代理，执行CBPeripheral的实例方法

```
-(void)discoverServices:(NSArray *)serviceUUIDs;
```


发现服务后会执行方法p1，留意一下CBService,包含name ，characteristics等几个属性。characteristics就是上面提及到的特性（通道）。
怎么理解characteristic❓characteristic可以说是通信的通道。读写的数据都包含在characteristic的value属性里面。

假设电子温度计包含着设备信息和控制两个服务，那么设备信息有可能包含：设备名字，厂家信息，出产时间等characteristic。控制服务可能包含：开关，读取温度，设置温度，电量等characteristic。 

我们需要发现特性才能跟外设进行通信，所以发现服务后，执行CBPeripheral的实例方法

```
-(void)discoverCharacteristics:(NSArray *)characteristicUUIDs forService:(CBService *)service;
```


发现特性后，方法p2会被回调啦。执行外设实例方法，将enabled设置成yes。

```
-(void)setNotifyValue:(BOOL)enabled forCharacteristic:(CBCharacteristic *)characteristic;
```

当外设有数据主动上传到中心，方法p3会被回调。

中心写数据到外设，执行外设的实例方法

```
-(void)writeValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)type;
```

你会发现当中有一个参数是characteristic，这就是为什么要经过这么多步骤找到特性的原因了！







