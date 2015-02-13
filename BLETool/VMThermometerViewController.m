//
//  VMThermometerViewController.m
//  BLETool
//
//  Created by XPG on 15/1/7.
//  Copyright (c) 2015年 Jaben. All rights reserved.
//

#import "VMThermometerViewController.h"
#import "VMBleConnector.h"
#import "SVProgressHUD.h"
#import "VMAlertUtil.h"

@interface VMThermometerViewController ()<VMBleConnectorDeledate, UIActionSheetDelegate>
{
    VMBleConnector *bleConnector;
    
    VMBleTemperatureUnit currentUnit;
}

@property (weak, nonatomic) IBOutlet UILabel *labelPowerValue;
@property (weak, nonatomic) IBOutlet UILabel *labelCurrentTemp;
@property (weak, nonatomic) IBOutlet UILabel *labelWarningColor;
@property (weak, nonatomic) IBOutlet UITextField *textFieldWarningTemp;
@property (weak, nonatomic) IBOutlet UITextField *textFieldColorR;
@property (weak, nonatomic) IBOutlet UITextField *textFieldColorG;
@property (weak, nonatomic) IBOutlet UITextField *textFieldColorB;
@property (weak, nonatomic) IBOutlet UITextField *textFieldFrequency;
@property (weak, nonatomic) IBOutlet UIButton *buttonUnit;

@end

@implementation VMThermometerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"温度计";
    
    bleConnector = [VMBleConnector shareManager];
    
    bleConnector.delegate = self;
    
    currentUnit = VMBleTemperatureUnitCelsius;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (bleConnector.delegate == nil)
    {
        bleConnector.delegate = self;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (IBAction)actionPowerOff:(id)sender
{
    [bleConnector thermometerPoweroff];
}

- (IBAction)actionSetWarningTemperature:(id)sender
{
    CGFloat temperature = [self.textFieldWarningTemp.text floatValue];
    [bleConnector setThermometerWarningTemperature:temperature];
}

- (IBAction)actionSetUnit:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择单位" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"摄氏度℃", @"华氏度℉", nil];
    [actionSheet showInView:self.view];
}

- (IBAction)actionSetColor:(id)sender
{
    NSUInteger color[3];
    
    color[0] = [self.textFieldColorR.text integerValue];
    color[1] = [self.textFieldColorG.text integerValue];
    color[2] = [self.textFieldColorB.text integerValue];
    
    UIColor *aColor = [UIColor colorWithRed:color[0]/255.0 green:color[1]/255.0 blue:color[2]/255.0 alpha:1];
    self.labelWarningColor.backgroundColor = aColor;
    
    [bleConnector setThermometerWarningColor:color];
}

- (IBAction)actionSetFrequency:(id)sender
{
    NSUInteger frequency = [self.textFieldFrequency.text integerValue];
    [bleConnector setThermometerGlintFrequency:frequency];
}

- (IBAction)actionSynchroniseParam:(id)sender
{
    [bleConnector setThermometerSynchroniseParam];
}

- (IBAction)actionReset:(id)sender
{
    [bleConnector resetThermometer];
}

- (IBAction)actionRestore:(id)sender
{
    [bleConnector restoreThermometer];
}


#pragma mark - VMBle Connector Deledate

- (void)didConnectPeriphral:(CBPeripheral *)periphral
{
    [SVProgressHUD dismiss];
}

- (void)didFailToConnectPeriphral:(CBPeripheral *)periphral
{
    [SVProgressHUD dismiss];
    [VMAlertUtil show:@"连接设备失败"];
}

- (void)didUpdateBattery:(NSUInteger)value
{
    self.labelPowerValue.text = [NSString stringWithFormat:@"%lu%%", value];
}

- (void)didUpdateThermometerWarningTemperature:(CGFloat)temperature
{
    self.textFieldWarningTemp.text = [NSString stringWithFormat:@"%.1f", temperature];
}

- (void)didUpdateThermometerTemperatureUnit:(VMBleTemperatureUnit)unit
{
    switch (unit)
    {
        case VMBleTemperatureUnitCelsius:
            [self.buttonUnit setTitle:@"单位：℃" forState:UIControlStateNormal];
            currentUnit = VMBleTemperatureUnitCelsius;
            break;
            
        case VMBleTemperatureUnitFahrenheit:
            [self.buttonUnit setTitle:@"单位：℉" forState:UIControlStateNormal];
            currentUnit = VMBleTemperatureUnitFahrenheit;
            break;
    }
}

- (void)didUpdateThermometerCurrentTemperature:(CGFloat)temperature
{
    self.labelCurrentTemp.text = [NSString stringWithFormat:@"%.1f", temperature];
}

- (void)didUpdateThermometerParameter:(CGFloat)warningTemperature unit:(VMBleTemperatureUnit)unit color:(NSUInteger *)color frequency:(NSUInteger)frequency
{
    self.textFieldWarningTemp.text = [NSString stringWithFormat:@"%.1f", warningTemperature];
    
    switch (unit)
    {
        case VMBleTemperatureUnitCelsius:
            [self.buttonUnit setTitle:@"单位：℃" forState:UIControlStateNormal];
            currentUnit = VMBleTemperatureUnitCelsius;
            break;
            
        case VMBleTemperatureUnitFahrenheit:
            [self.buttonUnit setTitle:@"单位：℉" forState:UIControlStateNormal];
            currentUnit = VMBleTemperatureUnitFahrenheit;
            break;
    }
    
    NSArray *textFields = @[self.textFieldColorR, self.textFieldColorG, self.textFieldColorB];
    for (int i = 0; i < 3; i++)
    {
        UITextField *textField = (UITextField *)textFields[i];
        textField.text = [NSString stringWithFormat:@"%lu", color[i]];
    }
    UIColor *aColor = [UIColor colorWithRed:color[0]/255.0 green:color[1]/255.0 blue:color[2]/255.0 alpha:1];
    self.labelWarningColor.backgroundColor = aColor;
    
    self.textFieldFrequency.text = [NSString stringWithFormat:@"%lu", frequency];
}

#pragma mark - Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self.buttonUnit setTitle:@"单位：℃" forState:UIControlStateNormal];
        currentUnit = VMBleTemperatureUnitCelsius;
        [bleConnector setThermometerTemperatureUnit:currentUnit];
    }
    else if (buttonIndex == 1)
    {
        [self.buttonUnit setTitle:@"单位：℉" forState:UIControlStateNormal];
        currentUnit = VMBleTemperatureUnitFahrenheit;
        [bleConnector setThermometerTemperatureUnit:currentUnit];
    }
}

@end
