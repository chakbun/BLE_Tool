//
//  ViewController.m
//  BLETool
//
//  Created by Jaben on 14-12-23.
//  Copyright (c) 2014年 Jaben. All rights reserved.
//

#import "ViewController.h"
#import "JRBluetoothManager.h"
#import "VMBleConnector.h"
#import "SVProgressHUD.h"
#import "VMAlertUtil.h"

@interface ViewController () <VMBleConnectorDeledate>
{
    NSMutableArray *blePeriphrals;
    
    NSArray *segueIdentifiers;
    
    VMBleConnector *bleConnector;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"蓝牙设备列表";
    
    blePeriphrals = [[NSMutableArray alloc] init];
    
    bleConnector = [VMBleConnector shareManager];
    segueIdentifiers = @[@"scaleViewController", @"timerViewController", @"thermometerViewController"];

    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshTableView)];
    self.navigationItem.rightBarButtonItem = refreshItem;
}

- (void)viewWillAppear:(BOOL)animated {
    bleConnector.delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [bleConnector stopScanPeripherals];
    bleConnector.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"mpSegue"]) {
        
    }
}

#pragma mark - TableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return blePeriphrals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuserId = @"BLE_PERIPHRAL_CELL";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuserId];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuserId];
    }
    
    NSDictionary *peripheralInfo = blePeriphrals[indexPath.row];
    CBPeripheral *peripheral = peripheralInfo[VM_Periperal];
    cell.textLabel.text = peripheral.name?:@"Periphral";
    cell.detailTextLabel.text = [peripheral.identifier UUIDString];
    
    return cell;
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSDictionary *peripheralInfo = blePeriphrals[indexPath.row];
    CBPeripheral *peripheral = peripheralInfo[VM_Periperal];

    NSLog(@"statue %ld",peripheral.state);
    if (peripheral.state == CBPeripheralStateConnected) {
        
    }else {
        [[JRBluetoothManager shareManager] connectPeripheral:peripheral];
    }
    
    if ([peripheral.name isEqualToString:kDeviceThermometerName]) {
        [self performSegueWithIdentifier:@"thermometerViewController" sender:nil];
        
    }else if([peripheral.name isEqualToString:kDeviceTimerName]) {
        [self performSegueWithIdentifier:@"timerViewController" sender:nil];
        
    }else if([peripheral.name isEqualToString:kDeviceScaleName]) {
        [self performSegueWithIdentifier:@"scaleViewController" sender:nil];
    }
}

#pragma mark - VMBle Connector Deledate

- (void)didUpdateState:(CBCentralManagerState)state
{
    if (state == CBCentralManagerStatePoweredOn)
    {
        [bleConnector startScanPeripherals:nil];
    }
}

- (void)didConnectPeriphral:(CBPeripheral *)periphral
{
    [SVProgressHUD dismiss];
    //[self performSegueWithIdentifier:@"thermometerViewController" sender:nil];
}

- (void)didFailToConnectPeriphral:(CBPeripheral *)periphral
{
    [SVProgressHUD dismiss];
    [VMAlertUtil show:@"连接设备失败"];
}

- (void)didFoundPeripheralInformation:(NSDictionary *)peripheralInfo
{
 
    CBPeripheral *newPeripheral = peripheralInfo[VM_Periperal];

    for(NSDictionary *tempInfo in blePeriphrals) {
        CBPeripheral *existPeripheral = tempInfo[VM_Periperal];
        
        if([[existPeripheral.identifier UUIDString] isEqualToString:[newPeripheral.identifier UUIDString]]) {
            return;
        }
    }
    [blePeriphrals addObject:peripheralInfo];
    [self.periphralTableView reloadData];
}

#pragma mark --Misc

- (void)refreshTableView {
    [blePeriphrals removeAllObjects];
    [self.periphralTableView reloadData];
    [bleConnector stopScanPeripherals];
    [bleConnector startScanPeripherals:nil];
}


@end
