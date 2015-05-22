//
//  RTController.m
//  BLETool
//
//  Created by Jaben on 15/5/20.
//  Copyright (c) 2015年 Jaben. All rights reserved.
//

#import "RTController.h"
#import "RTBleConnector.h"

@interface RTController ()

@end

@implementation RTController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Action

- (IBAction)normalControlAction:(id)sender {
    [[RTBleConnector shareManager] controlMode:RTControlModeNormal];
}
- (IBAction)EnggerControlAction:(id)sender {
    [[RTBleConnector shareManager] controlMode:RTControlModeEngger];
}

@end
