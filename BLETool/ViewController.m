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
#import "MPController.h"

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
        MPController *targetController = segue.destinationViewController;
        if ([targetController respondsToSelector:@selector(setJrPeriphral:)]) {
            targetController.jrPeriphral = sender;
        }
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
    
    JRCBPeripheral *peripheral = blePeriphrals[indexPath.row];
    cell.textLabel.text = peripheral.peripheral.name?:@"Periphral";
    cell.detailTextLabel.text = [peripheral.peripheral.identifier UUIDString];
    
    return cell;
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    JRCBPeripheral *jrPeriphral = blePeriphrals[indexPath.row];
//    [SVProgressHUD showWithStatus:@"正在连接..." maskType:SVProgressHUDMaskTypeClear];
    NSLog(@"statue %ld",jrPeriphral.peripheral.state);
    if (jrPeriphral.peripheral.state == CBPeripheralStateConnected) {
        
    }else {
        [[JRBluetoothManager shareManager] connectPeripheral:jrPeriphral];
    }
    
    if ([jrPeriphral.peripheral.name isEqualToString:kDeviceThermometerName]) {
        [self performSegueWithIdentifier:@"thermometerViewController" sender:nil];
        
    }else if([jrPeriphral.peripheral.name isEqualToString:kDeviceTimerName]) {
        [self performSegueWithIdentifier:@"timerViewController" sender:nil];
        
    }else if([jrPeriphral.peripheral.name isEqualToString:kDeviceScaleName]) {
        [self performSegueWithIdentifier:@"scaleViewController" sender:nil];
    }else {
        [self performSegueWithIdentifier:@"mpSegue" sender:jrPeriphral];
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

- (void)didFoundPeripheral:(JRCBPeripheral *)peripheral
{
    for(JRCBPeripheral *jrPeriphral in blePeriphrals) {
        if([[jrPeriphral.peripheral.identifier UUIDString] isEqualToString:[peripheral.peripheral.identifier UUIDString]]) {
            return;
        }
    }
    [blePeriphrals addObject:peripheral];
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
