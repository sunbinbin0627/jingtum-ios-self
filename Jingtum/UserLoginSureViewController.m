//
//  UserLoginSureViewController.m
//  Jingtum
//
//  Created by sunbinbin on 15-1-13.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "UserLoginSureViewController.h"
#import "JingtumJSManager+Register.h"
#import "JingtumJSManager+NetworkStatus.h"
#import "JingtumJSManager.h"
#import "Base64.h"
#import "AppDelegate.h"

@interface UserLoginSureViewController ()
{
    UIView *_navView;
    NSString *walletAccountStr;
}
@end

@implementation UserLoginSureViewController

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
    [titleLabel setText:@"修改密码"];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [_navView addSubview:titleLabel];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 2+NavViewHeigth/2, 70, 40)];
    [backButton setTitle:@"短信验证" forState:UIControlStateNormal];
    [backButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [backButton setTintColor:[UIColor whiteColor]];
    [backButton setBackgroundColor:[UIColor clearColor]];
    backButton.titleLabel.font=[UIFont systemFontOfSize:13];
    [backButton addTarget:self action:@selector(backtoGround) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:backButton];
    
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(11, (_navView.frame.size.height - 20)/2+5, 7, 10)];
    imageView.image=[UIImage imageNamed:@"title-left.png"];
    [_navView addSubview:imageView];

    
}

- (void)backtoGround
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)sendBtn:(id)sender
{
    NSString *userName=[[JingtumJSManager shared] jingtumUserName];
    NSString *usercrypt=[[JingtumJSManager shared] jingtumUserNameDecrypt];
    NSString *accountId=[[JingtumJSManager shared] jingtumWalletAddress];
    NSString *accoundSeed=[[JingtumJSManager shared] jingtumWalletSecrt];
            
    NSString *keyStr=[NSString stringWithFormat:@"%lu|%@%@",(unsigned long)userName.length,userName,self.passwordTextFiled.text];
    NSLog(@"keyStr-->%@",keyStr);
    NSDictionary *dict=@{
                         @"account_id":accountId,
                         @"master_seed":accoundSeed
                         
                         };
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    NSString *strEncrypt = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"strEncrypt--->%@",strEncrypt);
    
    [[JingtumJSManager shared] RegisterEncrypt:@{@"key":keyStr,@"encrypt":strEncrypt} withBlock:^(id responseData) {
        
        NSLog(@"responseData----====>%@",responseData);
        NSString *encryptCodeStr=[responseData base64EncodedString];
        NSLog(@"code-----===>%@",encryptCodeStr);
        
        NSString *urlRester=[NSString stringWithFormat:@"%@/resetUser",GLOBAL_BLOB_VAULT];
        
        //最终发送的json包
        NSDictionary *dictTemp=@{@"account":usercrypt,
                                 @"publickey":accountId,
                                 @"secret":encryptCodeStr
                                 };
        
         [[JingtumJSManager shared] operationManagerPOST:urlRester parameters:dictTemp withBlock:^(NSString *error, id responseData) {
             
             if ([error isEqualToString:@"0"])
             {
                 NSLog(@"修改登陆密码responseData->%@",responseData);
                 if ([[responseData objectForKey:@"data"] isEqualToString:@"Y"])
                 {
                     [self.navigationController popToRootViewControllerAnimated:YES];
                 }
                 else
                 {
                     UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"修改失败,请稍后再试!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                     [alert show];
                 }

             }
             
         }];
        
    }];
    
}

- (IBAction)background:(id)sender
{
    [self.view endEditing:YES];
}


@end
