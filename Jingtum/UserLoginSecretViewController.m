//
//  UserLoginSecretViewController.m
//  Jingtum
//
//  Created by sunbinbin on 15-1-13.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "UserLoginSecretViewController.h"
#import "SMS_SDK/SMS_SDK.h"
#import "SMS_SDK/CountryAndAreaCode.h"
#import "AppDelegate.h"

@interface UserLoginSecretViewController ()
{
    UIView *_navView;
    NSMutableArray *areaArray;
}
@end

@implementation UserLoginSecretViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [AppDelegate  storyBoradAutoLay:self.view];
    
    self.view.backgroundColor = [UIColor whiteColor];
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
    [titleLabel setText:@"短信验证"];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [_navView addSubview:titleLabel];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 2+NavViewHeigth/2, 70, 40)];
    [backButton setTitle:@"密码设置" forState:UIControlStateNormal];
    [backButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [backButton setTintColor:[UIColor whiteColor]];
    [backButton setBackgroundColor:[UIColor clearColor]];
    backButton.titleLabel.font=[UIFont systemFontOfSize:13];
    [backButton addTarget:self action:@selector(backtoGround) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:backButton];
    
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(11, (_navView.frame.size.height - 20)/2+5, 7, 10)];
    imageView.image=[UIImage imageNamed:@"title-left.png"];
    [_navView addSubview:imageView];
    
    NSString *phone=[USERDEFAULTS objectForKey:USERDEFAULTS_JINGTUM_PHONE];
    NSString *phonenum=[NSString stringWithFormat:@"%@",[phone stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"]];
    self.phoneLabel.text=phonenum;
    
    
    [SMS_SDK getZone:^(enum SMS_ResponseState state, NSArray *array) {
        if (1==state)
        {
            NSLog(@"block 获取区号成功");
            //区号数据
            areaArray=[NSMutableArray arrayWithArray:array];
            //            NSLog(@"==========%@",areaArray);
        }
        else if (0==state)
        {
            NSLog(@"block 获取区号失败");
        }
        
    }];
    
    
}

- (void)backtoGround
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)getNumBtn:(id)sender
{
    
    [self startTime];
    
    NSString *phoneStr=[USERDEFAULTS objectForKey:USERDEFAULTS_JINGTUM_PHONE];
    [SMS_SDK getVerifyCodeByPhoneNumber:phoneStr AndZone:@"86" result:^(enum SMS_GetVerifyCodeResponseState state) {
        if (1==state) {
            NSLog(@"block 获取验证码成功");
            
        }
        else if(0==state)
        {
            NSLog(@"block 获取验证码失败");
            NSString* str=[NSString stringWithFormat:@"验证码发送失败 请稍后重试"];
            UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"发送失败" message:str delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
        else if (SMS_ResponseStateMaxVerifyCode==state)
        {
            NSString* str=[NSString stringWithFormat:@"请求验证码超上限 请稍后重试"];
            UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"超过上限" message:str delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
        else if(SMS_ResponseStateGetVerifyCodeTooOften==state)
        {
            NSString* str=[NSString stringWithFormat:@"客户端请求发送短信验证过于频繁"];
            UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"提示" message:str delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];

}

- (IBAction)nextBtn:(id)sender
{
    if(self.sureNumTextFiled.text.length!=4)
    {
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"验证码格式错误,请重新填写" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        NSLog(@"去服务端进行验证中...");
        
        //[[SMS_SDK sharedInstance] commitVerifyCode:self.verifyCodeField.text];
        [SMS_SDK commitVerifyCode:self.sureNumTextFiled.text result:^(enum SMS_ResponseState state)
         {
             if (1==state)
             {
                 NSLog(@"block 验证成功");
                 AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
                 if (appdelegate.isLoginSecret == NO)
                 {
                     [self performSegueWithIdentifier:@"login" sender:nil];

                 }
                 else
                 {
                     [self performSegueWithIdentifier:@"pay" sender:nil];
                 }
                 
                                  
             }
             else if(0==state)
             {
                 NSLog(@"block 验证失败");
                 NSString* str=[NSString stringWithFormat:@"验证码无效 请重新获取验证码"];
                 UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"验证失败" message:str delegate:self cancelButtonTitle:@"确定"  otherButtonTitles:nil, nil];
                 [alert show];
                 
             }
         }];
        
    }

}

- (void)startTime
{
    //设计倒计时
    __block int timeout=60; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                self.numButton.hidden=NO;
                self.sureLabel.hidden=YES;
            });
        }else{
            //            int minutes = timeout / 60;
            int seconds = timeout % 60;
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                //                NSLog(@"____%@",strTime);
                self.numButton.hidden=YES;
                self.sureLabel.hidden=NO;
                self.sureLabel.text=[NSString stringWithFormat:@"%@秒后重新获取",strTime];
                //                [self.sendButton setTitle:[NSString stringWithFormat:@"未收到？重新获取验证码（%@秒)",strTime] forState:UIControlStateNormal];
                
                
            });
            timeout--;
            
        }
    });
    dispatch_resume(_timer);
}

- (IBAction)background:(id)sender
{
    [self.view endEditing:YES];
}

@end
