//
//  LoginViewController.m
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "LoginViewController.h"
#import "JingtumJSManager.h"
#import "JingtumJSManager+Authentication.h"
#import "JingtumJSManager+NetworkStatus.h"
#import "SVProgressHUD.h"
#import "myTextFiled.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"

@interface LoginViewController () <UITextFieldDelegate, UIAlertViewDelegate>
{
    UITextField *textFiledUsername;
    UITextField *textFiledpassword;
    UIAlertView *smsAlert;
    UITextField *smsTextFiled;//登陆短信验证的输入框
}

@property (strong, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation LoginViewController

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView == smsAlert)
    {
        if (buttonIndex == 0)
        {
            NSString *afterHashStr=[USERDEFAULTS objectForKey:USERDEFAULTS_JINGTUM_USERNAMEDECRYPT];
            NSString *tokenstr=[USERDEFAULTS objectForKey:JINGTUM_SAVETOKEN];
            [self afnetWorkLogin:smsTextFiled.text andKey:afterHashStr andToken:tokenstr];
        }
    }
    else
    {
        if (buttonIndex == alertView.cancelButtonIndex) {
            // Cancel
        }
        else {
            // Retry
            [self login];
        }
    }
}

-(IBAction)signupButton:(id)sender
{
    [self performSegueWithIdentifier:@"zhuce" sender:nil];
}

-(void)login
{

    [[JingtumJSManager shared] login:textFiledUsername.text andPassword:textFiledpassword.text withBlock:^(NSError *error) {
        
        if (!error) {
            textFiledUsername.text = @"";
            textFiledpassword.text = @"";
            
            [self performSegueWithIdentifier:@"Next" sender:nil];
        }
        else if ([error.localizedDescription isEqualToString:@"异地登陆"])
        {
            NSString *phoneStr=[USERDEFAULTS objectForKey:@"jingtumLoginPhone"];
            NSString *afterPhone=[NSString stringWithFormat:@"%@",[phoneStr stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"]];
            NSString *messageStr=[NSString stringWithFormat:@"您的账号曾在另一个手机上登录!为了确认您的身份,我们已经发送验证码到%@.",afterPhone];
            [self showAlertView:messageStr];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"登录失败"
                                  message: error.localizedDescription
                                  delegate: self
                                  cancelButtonTitle:@"确定"
                                  otherButtonTitles:@"重试", nil];
            [alert show];
        }
    }];
}

- (void)showAlertView:(NSString *)message
{
    smsAlert=[[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    smsAlert.alertViewStyle=UIAlertViewStylePlainTextInput;
    smsTextFiled=[smsAlert textFieldAtIndex:0];
    [smsTextFiled setKeyboardType:UIKeyboardTypeNumberPad];
    [smsTextFiled setPlaceholder:@"请输入验证码"];
    [smsAlert show];
}


//登录验证
- (void)afnetWorkLogin:(NSString *)smsCode andKey:(NSString *)tmpKey andToken:(NSString *)tmpToken
{
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/checkLoginSmsCode",GLOBAL_BLOB_VAULT];
    NSString *url= [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *dict=@{@"smsCode":smsCode,@"userType":@"1",@"key":tmpKey,@"token":tmpToken};
    
    [[JingtumJSManager shared] operationManagerPOST:url parameters:dict withBlock:^(NSString *error, id responseData) {
        if ([error isEqualToString:@"0"])
        {
            if ([[responseData objectForKey:@"error"] isEqual:[NSNull null]])
            {
                [self login];
            }
            else
            {
                NSString *messagestr=[NSString stringWithFormat:@"验证码错误,请重新输入."];
                [self showAlertView:messagestr];
            }
        }
        
    }];
    
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
}

- (IBAction)entryBtn:(id)sender
{
    
    [textFiledUsername resignFirstResponder];
    [textFiledpassword resignFirstResponder];
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    self.view.frame = rect;
    [UIView commitAnimations];
    
    [self login];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField==textFiledUsername)
    {
        [textFiledUsername setReturnKeyType:UIReturnKeyNext];
    }
    else if (textField==textFiledpassword)
    {
        [textFiledpassword setReturnKeyType:UIReturnKeyDone];
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField == textFiledUsername) {
        
        [textFiledpassword becomeFirstResponder];
    }
    else if (textField == textFiledpassword) {
        
        [textFiledUsername resignFirstResponder];
        [textFiledpassword resignFirstResponder];
        NSTimeInterval animationDuration = 0.30f;
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
        self.view.frame = rect;
        [UIView commitAnimations];
        [self login];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.layer.borderColor=[RGBA(54, 189, 237, 1) CGColor];
    if (textField==textFiledUsername)
    {
        
        CGRect frame = textField.frame;
        int offset = frame.origin.y + 92 - (self.view.frame.size.height - 216.0);//键盘高度216
        NSTimeInterval animationDuration = 0.30f;
        [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        float width = self.view.frame.size.width;
        float height = self.view.frame.size.height;
        if(offset > 0)
        {
            CGRect rect = CGRectMake(0.0f, -offset-160,width,height);
            self.view.frame = rect;
        }
        [UIView commitAnimations];
    }
    CGRect frame = textField.frame;
    int offset = frame.origin.y + 32 - (self.view.frame.size.height - 216.0);//键盘高度216
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    if(offset > 0)
    {
        CGRect rect = CGRectMake(0.0f, -offset-160,width,height);
        self.view.frame = rect;
    }
    [UIView commitAnimations];
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.layer.borderColor=[RGBA(172, 174, 171, 1) CGColor];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([[JingtumJSManager shared] jingtumUserName])
    {
        textFiledUsername.text=[[JingtumJSManager shared] jingtumUserName];
        [textFiledpassword becomeFirstResponder];
    }
    
//    if ([[JingtumJSManager shared] isLoggedIn]) {
//        [self performSegueWithIdentifier:@"Next" sender:nil];
//    }
//    else {
//        [textFiledUsername becomeFirstResponder];
//    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [AppDelegate  storyBoradAutoLay:self.view];
    
    //设置textFiled
    UIImageView *image=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user.png"]];
    image.frame=CGRectMake(0, 0, 17, 22);
    if (SCREEN_HEIGHT == 480)
    {
        textFiledUsername=[[myTextFiled alloc] initWithFrame:CGRectMake(40, 216, 241, 43) Icon:image];
    }
    else
    {
        textFiledUsername=[[myTextFiled alloc] initWithFrame:CGRectMake1(40, 304, 241, 43) Icon:image];//297
    }
    textFiledUsername.placeholder=@"请输入账号";
    textFiledUsername.borderStyle=UITextBorderStyleRoundedRect;
    textFiledUsername.keyboardType=UIKeyboardAppearanceDefault;
    textFiledUsername.textColor=RGBA(128, 128, 128, 1);
    [textFiledUsername setBorderStyle:UITextBorderStyleLine];
    textFiledUsername.layer.borderWidth=1.0;
    textFiledUsername.layer.cornerRadius=4;
    textFiledUsername.layer.borderColor=[RGBA(172, 174, 171, 1) CGColor];
    textFiledUsername.delegate=self;
    [self.view addSubview:textFiledUsername];

    
    UIImageView *image2=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"key.png"]];
    image2.frame=CGRectMake(0, 0, 27, 12);
    if (SCREEN_HEIGHT == 480)
    {
        textFiledpassword=[[myTextFiled alloc] initWithFrame:CGRectMake(40, 276, 241, 43) Icon:image2];
    }
    else
    {
        textFiledpassword=[[myTextFiled alloc] initWithFrame:CGRectMake1(40, 364, 241, 43) Icon:image2];//359
    }
    textFiledpassword.placeholder=@"请输入密码";
    textFiledpassword.secureTextEntry=YES;
    textFiledpassword.borderStyle=UITextBorderStyleRoundedRect;
    textFiledpassword.keyboardType=UIKeyboardAppearanceDefault;
    textFiledpassword.textColor=RGBA(128, 128, 128, 1);
    [textFiledpassword setBorderStyle:UITextBorderStyleLine];
    textFiledpassword.layer.borderWidth=1.0;
    textFiledpassword.layer.cornerRadius=4;
    textFiledpassword.layer.borderColor=[RGBA(172, 174, 171, 1) CGColor];
    textFiledpassword.delegate=self;
    [self.view addSubview:textFiledpassword];
    

    textFiledUsername.text=@"bbbb15";
    textFiledpassword.text=@"123456";
    self.navigationController.navigationBarHidden = YES;
    
    
}


CG_INLINE CGRect//注意：这里的代码要放在.m文件最下面的位置
CGRectMake1(CGFloat x, CGFloat y, CGFloat width, CGFloat height)
{
    AppDelegate *myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CGRect rect;
    rect.origin.x = x * myDelegate.autoSizeScaleX; rect.origin.y = y * myDelegate.autoSizeScaleY;
    rect.size.width = width * myDelegate.autoSizeScaleX; rect.size.height = height * myDelegate.autoSizeScaleY;
    return rect;
}




@end
