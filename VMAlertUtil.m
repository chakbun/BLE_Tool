//
//  VMAlertUtil.m
//  BLETool
//
//  Created by XPG on 15/1/12.
//  Copyright (c) 2015年 Jaben. All rights reserved.
//

#import "VMAlertUtil.h"
#import <UIKit/UIKit.h>

@implementation VMAlertUtil

+ (void)show:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"确认"
                                              otherButtonTitles:nil];
    
    [alertView show];
}

@end
