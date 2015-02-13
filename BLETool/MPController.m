//
//  MPController.m
//  BLETool
//
//  Created by Jaben on 15/2/12.
//  Copyright (c) 2015年 Jaben. All rights reserved.
//

#import "MPController.h"

@interface MPController ()

@end

@implementation MPController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)wrtie1ButtonAction:(id)sender {
    NSLog(@"periphral's name = %@",self.jrPeriphral.peripheral.name);
    [[JRBluetoothManager shareManager] writeData:nil toPeriperalWithName:@"iPod touch" characteritic:nil];
}

- (IBAction)write2ButtonAction:(id)sender {
    NSLog(@"periphral's name = %@",self.jrPeriphral.peripheral.name);
    [[JRBluetoothManager shareManager] writeData:nil toPeriperalWithName:@"__无邪_" characteritic:nil];
}

- (IBAction)write3ButtoAction:(id)sender {
}
@end
