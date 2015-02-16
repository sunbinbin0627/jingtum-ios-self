//
//  conDetailViewController.m
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "conDetailViewController.h"
#import "JingtumJSManager.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "JingtumJSManager+SendTransaction.h"
#import "JingtumJSManager+PaySecret.h"
#import "SVProgressHUD.h"

@interface conDetailViewController ()
{
    UIAlertView *verifyAlert;
    UIAlertView *verifyFailAlert;
    UITextField *verifyFiled;
    UIView *_navView;
    NSDateFormatter *formatter;//时间
}

@property (strong, nonatomic) NSString *catagoryValue;
@property (strong, nonatomic) HZAreaPickerView *locatePicker;

-(void)cancelLocatePicker;

@end

@implementation conDetailViewController
@synthesize catagoryValue=_catagoryValue;
@synthesize locatePicker=_locatePicker;


- (void)viewDidLoad
{
    [super viewDidLoad];
    [AppDelegate  storyBoradAutoLay:self.view];
    
    //时间戳转时间的方法
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationUserLoggedOut:) name:kNotificationUserLoggedOut object:nil];
    
    //自定义navgation
    UIView *statusBarView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, 0.f)];
    if (isIos7 >= 7 && __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1)
    {
        statusBarView.frame = CGRectMake(statusBarView.frame.origin.x, statusBarView.frame.origin.y, statusBarView.frame.size.width, 20.f);
        statusBarView.backgroundColor = [UIColor clearColor];
        ((UIImageView *)statusBarView).backgroundColor = RGBA(62,130,248,1);
        [self.view addSubview:statusBarView];
    }
    
    _navView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, StatusbarSize, self.view.frame.size.width, 44.f+NavViewHeigth)];
    ((UIImageView *)_navView).backgroundColor = RGBA(62,130,248,1);
    [self.view insertSubview:_navView belowSubview:statusBarView];
    _navView.userInteractionEnabled = YES;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((_navView.frame.size.width - 200)/2, (_navView.frame.size.height - 40)/2, 200, 40)];
    [titleLabel setText:@"联系人详情"];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [_navView addSubview:titleLabel];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 2+NavViewHeigth/2, 70, 40)];
    [backButton setTitle:@"联系人" forState:UIControlStateNormal];
    [backButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [backButton setTintColor:[UIColor whiteColor]];
    [backButton setBackgroundColor:[UIColor clearColor]];
    backButton.titleLabel.font=[UIFont systemFontOfSize:13];
    [backButton addTarget:self action:@selector(backtoGround) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:backButton];
    
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(11, (_navView.frame.size.height - 20)/2+5, 7, 10)];
    imageView.image=[UIImage imageNamed:@"title-left.png"];
    [_navView addSubview:imageView];
    
    self.nameLabel.text=self.name;
    self.addressLabel.text=self.address;
    self.cataTextFiled.delegate=self;
}

- (void)backtoGround
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setCatagoryValue:(NSString *)catagoryValue
{
    if (![_catagoryValue isEqualToString:catagoryValue])
    {
        self.cataTextFiled.text=catagoryValue;
    }
    
}

-(void)cancelLocatePicker
{
    [self.locatePicker cancelPicker];
    self.locatePicker.delegate = nil;
    self.locatePicker = nil;
}

#pragma mark - HZAreaPicker delegate

- (void)pickerDidChaneStatus:(HZAreaPickerView *)picker
{
    if (picker.pickerStyle == HZAreaPickerWithCatagory)
    {
        self.catagoryValue = [NSString stringWithFormat:@"%@", picker.locate.catagory];
    }
}

#pragma mark - TextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.cataTextFiled])
    {
        [self.priceTextFiled resignFirstResponder];
        [self cancelLocatePicker];
        self.locatePicker = [[HZAreaPickerView alloc] initWithStyle:HZAreaPickerWithCatagory delegate:self];
        [self.locatePicker showInView:self.view];
        self.cataTextFiled.text=@"SWT";
        return NO;
    }
    else if ([textField isEqual:self.priceTextFiled])
    {
        return YES;
    }
    return YES;
    
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = textField.frame;
    int offset = frame.origin.y + 32 - (self.view.frame.size.height - 216.0);//键盘高度216
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    if(offset > 0)
    {
        CGRect rect = CGRectMake(0.0f, -offset-100,width,height);
        self.view.frame = rect;
    }
    [UIView commitAnimations];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self cancelLocatePicker];
}



- (IBAction)send:(id)sender
{
    [self.priceTextFiled resignFirstResponder];
    [self.cataTextFiled resignFirstResponder];
    [self.locatePicker cancelPicker];
    [SVProgressHUD showWithStatus:@"转账中..." maskType:SVProgressHUDMaskTypeGradient];
    NSString *flag=[USERDEFAULTS objectForKey:USERDEFAULTS_JINGTUM_PAYSECRET];
    
    if ([flag isEqualToString:@"0"])
    {
        [self sendData];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入6位支付密码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        alert.alertViewStyle=UIAlertViewStyleSecureTextInput;
        verifyFiled=[alert textFieldAtIndex:0];
        verifyFiled.delegate=self;
        verifyFiled.placeholder=@"请输入密码";
        [verifyFiled setKeyboardType:UIKeyboardTypeNumberPad];
        verifyFiled.secureTextEntry=YES;
        
        verifyAlert=alert;
        [alert show];
    }


}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == verifyAlert)
    {
        if (buttonIndex==0)
        {
            [[JingtumJSManager shared] VerifyPaySecret:verifyFiled.text withBlock:^(id responseData) {
                
                NSLog(@"verify responseData%@",responseData);
                
                if ([responseData objectForKey:@"data"] && ![[responseData objectForKey:@"data"] isEqual:[NSNull null]] && [[responseData objectForKey:@"data"] isEqualToString:@"SUCCESS"])
                {
                    [self sendData];
                    
                }
                else
                {
                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"密码错误,请重新输入" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    verifyFailAlert=alert;
                    [alert show];
                    
                }
                
            }];

        }
        else
        {
             [SVProgressHUD dismiss];
        }
        
    }
    else if (alertView == verifyFailAlert)
    {
        if (buttonIndex == 0)
        {
            verifyFiled.text=@"";
            [verifyAlert show];
        }
        else
        {
            [SVProgressHUD dismiss];
        }
    }

   
}


- (IBAction)background:(id)sender
{
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    self.view.frame = rect;
    [UIView commitAnimations];
    
    [self.view endEditing:YES];
    [self.locatePicker cancelPicker];
}

//删除自身的观察者身份
- (void)notificationUserLoggedOut:(NSNotification *) notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)sendData
{
    NSDecimalNumber *amount=[NSDecimalNumber decimalNumberWithString:self.priceTextFiled.text];
    RPNewTransaction *transaction=[RPNewTransaction new];
    transaction.to_address=self.addressLabel.text;
    transaction.to_currency=self.cataTextFiled.text;
    transaction.to_amount=amount;
    transaction.from_currency=self.cataTextFiled.text;
    transaction.to_issuer=JINGTUM_ISSURE;
    
    [[JingtumJSManager shared] wrapperSendSubmit:transaction withBlock:^(NSError *error) {
        if (!error)
        {
            NSLog(@"交易成功");
            [self.navigationController popViewControllerAnimated:YES];
            [SVProgressHUD showSuccessWithStatus:@"成功"];
            
        }
        else
        {
            NSString *message=[NSString stringWithFormat:@"错误:%@",error.localizedDescription];
            [SVProgressHUD showErrorWithStatus:message];
        }
    }];

}



@end
