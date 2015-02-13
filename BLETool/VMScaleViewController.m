//
//  VMScaleViewController.m
//  BLETool
//
//  Created by XPG on 15/1/7.
//  Copyright (c) 2015年 Jaben. All rights reserved.
//

#import "VMScaleViewController.h"
#import "VMBleConnector.h"

@interface VMScaleViewController ()<VMBleConnectorDeledate, UIActionSheetDelegate>
{
    VMBleConnector *bleConnector;
    VMBleMassUnit currentUnit;
}

@property (weak, nonatomic) IBOutlet UITextField *textFieldWeight;
@property (weak, nonatomic) IBOutlet UITextField *textFieldDensity;
@property (weak, nonatomic) IBOutlet UILabel *labelPowerValue;
@property (weak, nonatomic) IBOutlet UILabel *labelCurrentWeight;
@property (weak, nonatomic) IBOutlet UILabel *labelTotalWeight;
@property (weak, nonatomic) IBOutlet UIButton *buttonUnit;

@end

@implementation VMScaleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"厨房秤";
    
    bleConnector = [VMBleConnector shareManager];
    bleConnector.delegate = self;
    
    currentUnit = VMBleMassUnitGram;
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

- (IBAction)actionSetWeight:(id)sender
{
    CGFloat fWeight = [self.textFieldWeight.text floatValue];
    
    if (currentUnit == VMBleMassUnitGram)
    {
        [bleConnector setScaleTargetWeight:(fWeight * 10)];
    }
    else
    {
        [bleConnector setScaleTargetWeight:(fWeight * 100)];
    }
}

- (IBAction)actionSetDensity:(id)sender
{
    CGFloat fDensity = [self.textFieldDensity.text floatValue];
    
    [bleConnector setScaleFluidDensity:(fDensity * 1000)];
}

- (IBAction)actionSelectUnit:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择单位" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"g", @"lb/oz", nil];
    [actionSheet showInView:self.view];
}

- (IBAction)actionPowerOff:(id)sender
{
    [bleConnector scalePoweroff];
}

- (IBAction)actionPeeling:(id)sender
{
    [bleConnector setScalePeeling];
}

- (IBAction)actionClear:(id)sender
{
    [bleConnector setScaleClear];
}

- (IBAction)actionSynchroniseParam:(id)sender
{
    [bleConnector setScaleSynchroniseParam];
}

- (IBAction)actionReset:(id)sender
{
    [bleConnector resetScale];
}

- (IBAction)actionRestore:(id)sender
{
    [bleConnector restoreScale];
}

#pragma mark - VMBle Connector Deledate

- (void)didUpdateBattery:(NSUInteger)value
{
    NSLog(@"--->> 厨房秤更新电量.");
    self.labelPowerValue.text = [NSString stringWithFormat:@"%lu%%", value];
}

- (void)didUpdateScaleUnit:(VMBleMassUnit)unit
{
    if (currentUnit != unit)
    {
        currentUnit = unit;
        
        if (currentUnit == VMBleMassUnitGram)
        {
            [self.buttonUnit setTitle:@"单位：g" forState:UIControlStateNormal];
        }
        else
        {
            [self.buttonUnit setTitle:@"单位：lb/oz" forState:UIControlStateNormal];
        }
    }
}

- (void)didUpdateScaleWeight:(NSUInteger)currentWeight totalWeight:(NSUInteger)totalWeight
{
    if (currentUnit == VMBleMassUnitGram)
    {
        self.labelCurrentWeight.text = [NSString stringWithFormat:@"%.1fg", currentWeight/10.0f];
        self.labelTotalWeight.text = [NSString stringWithFormat:@"%.1fg", totalWeight/10.0f];
    }
    else
    {
        CGFloat clb = 0, coz = 0;
        CGFloat tlb = 0, toz = 0;
        CGFloat fCurrentWeight = currentWeight / 100.0f;
        CGFloat fTotalWeight = totalWeight / 100.0f;
        
        clb = fCurrentWeight / 16;
        coz = fCurrentWeight - clb * 16.0f;
        
        tlb = fTotalWeight / 16;
        toz = fTotalWeight - clb * 16.0f;
        
        if ((int)clb == 0)
        {
            self.labelCurrentWeight.text = [NSString stringWithFormat:@"%.2foz", coz];
        }
        else
        {
            self.labelCurrentWeight.text = [NSString stringWithFormat:@"%dlb %.2foz", (int)clb, coz];
        }
        
        if ((int)tlb == 0)
        {
            self.labelTotalWeight.text = [NSString stringWithFormat:@"%.2foz", toz];
        }
        else
        {
            self.labelTotalWeight.text = [NSString stringWithFormat:@"%dlb %.2foz", (int)tlb, toz];
        }
    }
}

#pragma mark - Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self.buttonUnit setTitle:@"单位：g" forState:UIControlStateNormal];
        currentUnit = VMBleMassUnitGram;
        [bleConnector setScaleUnit:currentUnit];
    }
    else if (buttonIndex == 1)
    {
        [self.buttonUnit setTitle:@"单位：lb/oz" forState:UIControlStateNormal];
        currentUnit = VMBleMassUnitPoundAndOunce;
        [bleConnector setScaleUnit:currentUnit];
    }
}

@end
