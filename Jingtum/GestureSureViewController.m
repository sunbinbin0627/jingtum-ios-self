 //
//  GestureSureViewController.m
//  Jingtum
//
//  Created by sunbinbin on 15-1-13.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <Security/Security.h>
#import <CoreFoundation/CoreFoundation.h>

#import "GestureSureViewController.h"
#import "AppDelegate.h"

#import "KeychainItemWrapper.h"

@interface GestureSureViewController ()

@property (nonatomic,strong) GesturePasswordView *gesturePasswordView;

@end

@implementation GestureSureViewController
{
    NSString *previousString;
    NSString *password;
    int num;
}

@synthesize gesturePasswordView;


- (void)viewDidLoad {
    [super viewDidLoad];
   
    num=0;
    
    previousString=@"";
    KeychainItemWrapper * keychin = [[KeychainItemWrapper alloc]initWithIdentifier:@"Gesture" accessGroup:nil];
    password = [keychin objectForKey:(__bridge id)kSecValueData];
    [self verify];
}


#pragma mark - 验证手势密码
- (void)verify{
    gesturePasswordView = [[GesturePasswordView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [gesturePasswordView.state setTextColor:[UIColor colorWithRed:2/255.f green:174/255.f blue:240/255.f alpha:1]];
    [gesturePasswordView.backButton setHidden:YES];
    [gesturePasswordView.state setText:@"请输入手势密码"];
    [gesturePasswordView.tentacleView setRerificationDelegate:self];
    [gesturePasswordView.tentacleView setStyle:1];
    [gesturePasswordView setGesturePasswordDelegate:self];
    [self.view addSubview:gesturePasswordView];
}


- (BOOL)verification:(NSString *)result{
    if ([result isEqualToString:password]) {
        [gesturePasswordView.state setTextColor:[UIColor colorWithRed:2/255.f green:174/255.f blue:240/255.f alpha:1]];
        [gesturePasswordView.state setText:@"输入正确"];
        [self dismissViewControllerAnimated:YES completion:nil];
        return YES;
    }
    num+=1;
    if (num==5)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"您已经连续5次输入错误,系统将退出登陆。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
    
    NSString *message=[NSString stringWithFormat:@"手势密码错误,您还有%i次机会",5-num];
    [self retryVerify:message];
//    [gesturePasswordView.state setTextColor:[UIColor redColor]];
//    [gesturePasswordView.state setText:message];
    return NO;
}


- (void)retryVerify:(NSString *)message
{
    gesturePasswordView = [[GesturePasswordView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [gesturePasswordView.state setTextColor:[UIColor redColor]];
    [gesturePasswordView.backButton setHidden:YES];
    [gesturePasswordView.state setText:message];
    [gesturePasswordView.tentacleView setRerificationDelegate:self];
    [gesturePasswordView.tentacleView setStyle:1];
    [gesturePasswordView setGesturePasswordDelegate:self];
    [self.view addSubview:gesturePasswordView];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0)
    {
        AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appdelegate setmainview];
    }
}

- (void)forget
{
    
}
- (void)change
{
    
}
- (void)back
{
    
}


@end
