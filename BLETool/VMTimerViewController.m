//
//  VMTimerViewController.m
//  BLETool
//
//  Created by XPG on 15/1/7.
//  Copyright (c) 2015年 Jaben. All rights reserved.
//

#import "VMTimerViewController.h"
#import "VMBleConnector.h"

@interface VMTimerViewController ()<VMBleConnectorDeledate, UIActionSheetDelegate>
{
    VMBleConnector *bleConnector;
    VMBleTemperatureUnit currentUnit;
    
    NSTimer *timer1;
    NSTimer *timer2;
    NSTimer *timer3;
    NSTimeInterval timer1Millisecond;
    NSTimeInterval timer2Millisecond;
    NSTimeInterval timer3Millisecond;
    NSTimeInterval timer1Delay;
    NSTimeInterval timer2Delay;
    NSTimeInterval timer3Delay;
}

@property (weak, nonatomic) IBOutlet UITextField *textFieldWarningTemp;
@property (weak, nonatomic) IBOutlet UITextField *textFieldTime1;
@property (weak, nonatomic) IBOutlet UITextField *textFieldDelay1;
@property (weak, nonatomic) IBOutlet UITextField *textFieldTime2;
@property (weak, nonatomic) IBOutlet UITextField *textFieldDelay2;
@property (weak, nonatomic) IBOutlet UITextField *textFieldTime3;
@property (weak, nonatomic) IBOutlet UITextField *textFieldDelay3;
@property (weak, nonatomic) IBOutlet UILabel *labelCurrentTemp;
@property (weak, nonatomic) IBOutlet UILabel *labelPowerValue;
@property (weak, nonatomic) IBOutlet UIButton *buttonUnit;

@end

@implementation VMTimerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"定时器";
    
    bleConnector = [VMBleConnector shareManager];
    bleConnector.delegate = self;
    
    currentUnit = VMBleTemperatureUnitCelsius;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (bleConnector.delegate == nil)
    {
        bleConnector.delegate = self;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)sender
{
    if (self.textFieldDelay3.editing || self.textFieldTime3.editing)
    {
        NSValue *value = sender.userInfo[@"UIKeyboardBoundsUserInfoKey"];
        CGRect frame;
        [value getValue:&frame];
        
        NSNumber *duration = sender.userInfo[@"UIKeyboardAnimationDurationUserInfoKey"];
        
        [UIView animateWithDuration:[duration floatValue] animations:^{
            
            self.view.frame = CGRectMake(0, -frame.size.height, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)sender
{
    if (CGRectGetMinY(self.view.frame) < 0)
    {
        NSNumber *duration = sender.userInfo[@"UIKeyboardAnimationDurationUserInfoKey"];
        [UIView animateWithDuration:[duration floatValue] animations:^{
            
            self.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
        }];
    }
}

#pragma mark - 操作

- (NSUInteger *)parseTime:(NSString *)stringTime
{
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@": -"];
    NSArray *arrayTime = [stringTime componentsSeparatedByCharactersInSet:set];
    
    if (arrayTime.count != 3)
    {
        return nil;
    }
    
    NSUInteger *time = (NSUInteger *)malloc(3*sizeof(NSUInteger));
    
    printf("\n--->> 时:分:秒 ");
    for (int i = 0; i < 3; i++)
    {
        @try
        {
            time[i] = [arrayTime[i] integerValue];
            printf("%lu ", time[i]);
        }
        @catch (NSException *exception)
        {
            return nil;
        }
    }
    
    return time;
}

- (NSString *)stringFromTime:(NSTimeInterval)time
{
    int hour = time / 3600;
    int minute = (time - hour * 3600) / 60;
    int second = (int)time % 60;
    
    NSString *stringTime = [NSString stringWithFormat:@"%d小时%d分%d秒", hour, minute, second];
    
    return stringTime;
}

- (IBAction)actionPowerOff:(id)sender
{
    [bleConnector timerPoweroff];
}

- (IBAction)actionSetWarningTemperature:(id)sender
{
    CGFloat temperature = [self.textFieldWarningTemp.text floatValue];
    [bleConnector setTimerWarningTemperature:temperature];
}

- (IBAction)actionSelectUnit:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择单位" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"摄氏度℃", @"华氏度℉", nil];
    [actionSheet showInView:self.view];
}

- (IBAction)actionSynchroniseParam:(id)sender
{
    [bleConnector setTimerSynchroniseParam];
}

- (IBAction)actionSynchroniseTime:(id)sender
{
    NSUInteger *time1 = [self parseTime:self.textFieldTime1.text];
    NSUInteger *time2 = [self parseTime:self.textFieldTime2.text];
    NSUInteger *time3 = [self parseTime:self.textFieldTime3.text];
    
    if (time1 == nil || time2 == nil || time3 == nil)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"时间格式错误" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    [bleConnector setTimerSynchroniseTime:time1 time2:time2 time3:time3];
}

- (IBAction)actionReset:(id)sender
{
    [bleConnector resetTimer];
}

- (IBAction)actionRestore:(id)sender
{
    [bleConnector restoreTimer];
}

- (void)timer1Start
{
    [self timer1Stop];
    
    timer1 = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timer1Timing) userInfo:nil repeats:YES];
}

- (void)timer1Stop
{
    if (timer1 != nil)
    {
        [timer1 invalidate];
        timer1 = nil;
    }
}

- (void)timer1Clear
{
    self.textFieldTime1.text = @"";
    self.textFieldDelay1.text = @"";
    timer1Millisecond = 0;
    timer1Delay = 0;
}

- (void)timer2Start
{
    [self timer1Stop];
    
    timer2 = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timer2Timing) userInfo:nil repeats:YES];
}

- (void)timer2Stop
{
    if (timer2 != nil)
    {
        [timer2 invalidate];
        timer2 = nil;
    }
}

- (void)timer2Clear
{
    self.textFieldTime2.text = @"";
    self.textFieldDelay2.text = @"";
    timer2Millisecond = 0;
    timer2Delay = 0;
}

- (void)timer3Start
{
    [self timer1Stop];
    
    timer3 = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timer3Timing) userInfo:nil repeats:YES];
}

- (void)timer3Stop
{
    if (timer3 != nil)
    {
        [timer3 invalidate];
        timer3 = nil;
    }
}

- (void)timer3Clear
{
    self.textFieldTime3.text = @"";
    self.textFieldDelay3.text = @"";
    timer3Millisecond = 0;
    timer3Delay = 0;
}

// 定时器1

- (IBAction)actionSetTime1:(id)sender
{
    [self setTimerTime:self.textFieldTime1 index:VMBleDeviceTimer1];
}

- (IBAction)actionSetDelay1:(id)sender
{
    [self setTimerDelay:self.textFieldDelay1 index:VMBleDeviceTimer1];
}

- (IBAction)actionStart1:(id)sender
{
    [self timer1Start];
    
    [bleConnector setTimerStart:VMBleDeviceTimer1];
}

- (IBAction)actionStop1:(id)sender
{
    [self timer1Stop];
    
    [bleConnector setTimerStop:VMBleDeviceTimer1];
}

- (IBAction)actionClear1:(id)sender
{
    [self timer1Clear];
    
    [bleConnector setTimerClear:VMBleDeviceTimer1];
}

// 定时器2

- (IBAction)actionSetTime2:(id)sender
{
    [self setTimerTime:self.textFieldTime2 index:VMBleDeviceTimer2];
}

- (IBAction)actionSetDelay2:(id)sender
{
    [self setTimerDelay:self.textFieldDelay2 index:VMBleDeviceTimer2];
}

- (IBAction)actionStart2:(id)sender
{
    [self timer2Start];
    
    [bleConnector setTimerStart:VMBleDeviceTimer2];
}

- (IBAction)actionStop2:(id)sender
{
    [self timer2Stop];
    
    [bleConnector setTimerStop:VMBleDeviceTimer2];
}

- (IBAction)actionClear2:(id)sender
{
    [self timer2Clear];
    
    [bleConnector setTimerClear:VMBleDeviceTimer2];
}

// 定时器3

- (IBAction)actionSetTime3:(id)sender
{
    [self setTimerTime:self.textFieldTime3 index:VMBleDeviceTimer3];
}

- (IBAction)actionSetDelay3:(id)sender
{
    [self setTimerDelay:self.textFieldDelay3 index:VMBleDeviceTimer3];
}

- (IBAction)actionStart3:(id)sender
{
    [self timer3Start];
    
    [bleConnector setTimerStart:VMBleDeviceTimer3];
}

- (IBAction)actionStop3:(id)sender
{
    [self timer3Stop];
    
    [bleConnector setTimerStop:VMBleDeviceTimer3];
}

- (IBAction)actionClear3:(id)sender
{
    [self timer3Clear];
    
    [bleConnector setTimerClear:VMBleDeviceTimer3];
}

#pragma mark - VMBle Connector Deledate

- (void)didUpdateBattery:(NSUInteger)value
{
    self.labelPowerValue.text = [NSString stringWithFormat:@"%lu%%", value];
}

- (void)didUpdateTimerStart:(NSUInteger)index
{
    switch (index)
    {
        case VMBleDeviceTimer1:
            [self timer1Start];
            break;
            
        case VMBleDeviceTimer2:
            [self timer2Start];
            break;
            
        case VMBleDeviceTimer3:
            [self timer3Start];
            break;
    }
}

- (void)didUpdateTimerStop:(NSUInteger)index
{
    switch (index)
    {
        case VMBleDeviceTimer1:
            [self timer1Stop];
            break;
            
        case VMBleDeviceTimer2:
            [self timer2Stop];
            break;
            
        case VMBleDeviceTimer3:
            [self timer3Stop];
            break;
    }
}

- (void)didUpdateTimerClear:(NSUInteger)index
{
    switch (index)
    {
        case VMBleDeviceTimer1:
            [self timer1Clear];
            break;
            
        case VMBleDeviceTimer2:
            [self timer2Clear];
            break;
            
        case VMBleDeviceTimer3:
            [self timer3Clear];
            break;
    }
}

- (void)didUpdateTimerWarningTemperature:(CGFloat)temperature
{
    self.textFieldWarningTemp.text = [NSString stringWithFormat:@"%.1f", temperature];
}

- (void)didUpdateTimerTemperatureUnit:(VMBleTemperatureUnit)unit
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

- (void)didUpdateTimerTemperature:(CGFloat)temperature
{
    self.labelCurrentTemp.text = [NSString stringWithFormat:@"%.1f", temperature];
}

- (void)didUpdateTimerSettingTime:(NSUInteger *)values index:(NSUInteger)index
{
    UITextField *textField;
    
    NSTimeInterval millisecond = values[0] * 3600 + values[1] * 60 + values[2];
    
    switch (index)
    {
        case VMBleDeviceTimer1:
            textField = self.textFieldTime1;
            timer1Millisecond = millisecond;
            break;
            
        case VMBleDeviceTimer2:
            textField = self.textFieldTime2;
            timer2Millisecond = millisecond;
            break;
            
        case VMBleDeviceTimer3:
            textField = self.textFieldTime3;
            timer3Millisecond = millisecond;
            break;
    }
    textField.text = [NSString stringWithFormat:@"%lu小时%lu分%lu秒", values[0], values[1], values[2]];
}

- (void)didUpdateTimerSettingDelay:(NSUInteger *)values index:(NSUInteger)index
{
    UITextField *textField;
    
    NSTimeInterval millisecond = values[0] * 3600 + values[1] * 60 + values[2];
    
    switch (index)
    {
        case VMBleDeviceTimer1:
            textField = self.textFieldDelay1;
            timer1Delay = millisecond;
            break;
            
        case VMBleDeviceTimer2:
            textField = self.textFieldDelay2;
            timer2Delay = millisecond;
            break;
            
        case VMBleDeviceTimer3:
            textField = self.textFieldDelay3;
            timer3Delay = millisecond;
            break;
    }
    textField.text = [NSString stringWithFormat:@"%lu小时%lu分%lu秒", values[0], values[1], values[2]];
}

- (void)didUpdateTimerParameter:(NSUInteger *)time status:(VMBleDeviceTimerStatus *)status index:(NSUInteger)index
{
    UITextField *textField;
    
    NSTimeInterval millisecond = time[0] * 3600 + time[1] * 60 + time[2];
    
    switch (index)
    {
        case VMBleDeviceTimer1:
            textField = self.textFieldTime1;
            timer1Millisecond = millisecond;
            break;
            
        case VMBleDeviceTimer2:
            textField = self.textFieldTime2;
            timer2Millisecond = millisecond;
            break;
            
        case VMBleDeviceTimer3:
            textField = self.textFieldTime3;
            timer3Millisecond = millisecond;
            break;
    }
    textField.text = [NSString stringWithFormat:@"%lu小时%lu分%lu秒", time[0], time[1], time[2]];
    
    if (status[0] == VMBleDeviceTimerOn)
    {
        [self timer1Start];
    }
    else
    {
        [self timer1Stop];
    }
    
    if (status[1] == VMBleDeviceTimerOn)
    {
        [self timer2Start];
    }
    else
    {
        [self timer2Stop];
    }
    
    if (status[2] == VMBleDeviceTimerOn)
    {
        [self timer3Start];
    }
    else
    {
        [self timer3Stop];
    }
}

- (void)didUpdateTimerParameterWarningTemperature:(CGFloat)temperature unit:(VMBleTemperatureUnit)unit
{
    self.textFieldWarningTemp.text = [NSString stringWithFormat:@"%.1f", temperature];
    
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

#pragma mark - Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self.buttonUnit setTitle:@"单位：℃" forState:UIControlStateNormal];
        currentUnit = VMBleTemperatureUnitCelsius;
        [bleConnector setTimerTemperatureUnit:currentUnit];
    }
    else if (buttonIndex == 1)
    {
        [self.buttonUnit setTitle:@"单位：℉" forState:UIControlStateNormal];
        currentUnit = VMBleTemperatureUnitFahrenheit;
        [bleConnector setTimerTemperatureUnit:currentUnit];
    }
}

#pragma mark 定时器1计时

- (void)timer1Timing
{
    if (timer1Delay > 0)
    {
        self.textFieldDelay1.text = [self stringFromTime:--timer1Delay];
    }
    else
    {
        if (timer1Millisecond > 0)
        {
            self.textFieldTime1.text = [self stringFromTime:--timer1Millisecond];
        }
        else
        {
            [timer1 invalidate];
            timer1 = nil;
        }
    }
}

#pragma mark 定时器2计时

- (void)timer2Timing
{
    if (timer2Delay > 0)
    {
        self.textFieldDelay2.text = [self stringFromTime:--timer2Delay];
    }
    else
    {
        if (timer2Millisecond > 0)
        {
            self.textFieldTime2.text = [self stringFromTime:--timer2Millisecond];
        }
        else
        {
            [timer2 invalidate];
            timer2 = nil;
        }
    }
}

#pragma mark 定时器3计时

- (void)timer3Timing
{
    if (timer3Delay > 0)
    {
        self.textFieldDelay3.text = [self stringFromTime:--timer3Delay];
    }
    else
    {
        if (timer3Millisecond > 0)
        {
            self.textFieldTime3.text = [self stringFromTime:--timer3Millisecond];
        }
        else
        {
            [timer3 invalidate];
            timer3 = nil;
        }
    }
}

- (void)setTimerTime:(UITextField *)textField index:(NSUInteger)index
{
    NSUInteger *time = [self parseTime:textField.text];
    
    if (time == nil)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"时间格式错误" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    NSTimeInterval millisecond = time[0] * 3600 + time[1] * 60 + time[2];
    
    switch (index)
    {
        case VMBleDeviceTimer1:
            timer1Millisecond = millisecond;
            break;
        case VMBleDeviceTimer2:
            timer2Millisecond = millisecond;
            break;
        case VMBleDeviceTimer3:
            timer3Millisecond = millisecond;
            break;
    }
    
    textField.text = [NSString stringWithFormat:@"%lu小时%lu分%lu秒", time[0], time[1], time[2]];
    [textField resignFirstResponder];
    
    [bleConnector setTimerTime:time index:index];
}

- (void)setTimerDelay:(UITextField *)textField index:(NSUInteger)index
{
    NSUInteger *time = [self parseTime:textField.text];
    
    if (time == nil)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"时间格式错误" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    NSTimeInterval millisecond = time[0] * 3600 + time[1] * 60 + time[2];
    
    switch (index)
    {
        case VMBleDeviceTimer1:
            timer1Delay = millisecond;
            break;
            
        case VMBleDeviceTimer2:
            timer2Delay = millisecond;
            break;
            
        case VMBleDeviceTimer3:
            timer3Delay = millisecond;
            break;
    }
    
    textField.text = [NSString stringWithFormat:@"%lu小时%lu分%lu秒", time[0], time[1], time[2]];
    [textField resignFirstResponder];
    
    [bleConnector setTimerDelay:time index:index];
}

@end
