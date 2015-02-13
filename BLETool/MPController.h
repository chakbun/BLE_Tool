//
//  MPController.h
//  BLETool
//
//  Created by Jaben on 15/2/12.
//  Copyright (c) 2015年 Jaben. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JRBluetoothManager.h"

@interface MPController : UIViewController

@property (nonatomic, strong) JRCBPeripheral *jrPeriphral;

- (IBAction)wrtie1ButtonAction:(id)sender;
- (IBAction)write2ButtonAction:(id)sender;
- (IBAction)write3ButtoAction:(id)sender;

@end
