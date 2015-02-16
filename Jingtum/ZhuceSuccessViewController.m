//
//  ZhuceSuccessViewController.m
//  Jingtum
//
//  Created by sunbinbin on 14-11-26.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "ZhuceSuccessViewController.h"
#import "SMS_SDK/SMS_SDK.h"
#import "SMS_SDK/CountryAndAreaCode.h"
#import "Base64.h"
#import "NSString+Hashes.h"
#import "SVProgressHUD.h"
#import "JingtumJSManager+Register.h"
#import "JingtumJSManager+NetworkStatus.h"
#import "AppDelegate.h"

@interface ZhuceSuccessViewController ()
{
    UIView *_navView;
    UIAlertView *alert2;
    NSString *walletAccountStr;
}

@end

@implementation ZhuceSuccessViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
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
    [titleLabel setText:@"登陆信息"];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [_navView addSubview:titleLabel];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(18, 2+NavViewHeigth/2, 70, 40)];
    [backButton setTitle:@"填写验证码" forState:UIControlStateNormal];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.mNameTextFiled becomeFirstResponder];
    
}

- (void)backtoGround
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.mNameTextFiled)
    {
         self.tipLabel.hidden=YES;
    }
    
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ([textField isEqual:self.mNameTextFiled])
    {
        if (self.mNameTextFiled.text.length < 6 && self.mNameTextFiled.text.length > 0)
        {
            self.tipLabel.hidden=NO;
            self.tipLabel.text=@"用户名不能短于6个字符";
        }
        else if (self.mNameTextFiled.text.length == 0)
        {
            self.tipLabel.hidden=NO;
            self.tipLabel.text=@"用户名不能为空";
        }
    }
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.mNameTextFiled)
    {
        [self.mPasswordTextFiled becomeFirstResponder];
    }
    else if (textField == self.mPasswordTextFiled)
    {
        [self.mSureTextFiled becomeFirstResponder];
    }
    else if (textField == self.mSureTextFiled)
    {
        [self.mSureTextFiled resignFirstResponder];
    }
    return YES;
}


- (IBAction)mDoneBtn:(id)sender
{
    if (self.mNameTextFiled.text != NULL)
    {
        if (self.mPasswordTextFiled.text.length>=6)
        {
            if ([self.mPasswordTextFiled.text isEqualToString:self.mSureTextFiled.text])
            {
                
                [SVProgressHUD showWithStatus:@"注册中..." maskType:SVProgressHUDMaskTypeGradient];
                NSString *userSha256;
                if (![self.mNameTextFiled.text isEqualToString:@""])
                {
                    NSString *usernameStr=[self.mNameTextFiled.text lowercaseString];
                    userSha256=[NSString stringWithFormat:@"%@",[usernameStr sha256]];
                }
                [[JingtumJSManager shared] RegisterForMassterId:@"" withBlock:^(id responseData) {
                    NSString *walletsecertStr=responseData;
                    NSLog(@"walletsecertStr===%@",walletsecertStr);
                    [[JingtumJSManager shared] RegisterForAccountId:responseData withBlock:^(id responseData) {
                        
                        NSString *walletidStr=responseData;
                        walletAccountStr=responseData;
                        NSLog(@"walletidStr--->%@",walletidStr);
                        
                        NSString *keyStr=[NSString stringWithFormat:@"%lu|%@%@",(unsigned long)self.mNameTextFiled.text.length,self.mNameTextFiled.text,self.mPasswordTextFiled.text];
                        NSLog(@"keyStr-->%@",keyStr);
                        NSDictionary *dict=@{
                                             @"account_id":walletidStr,
                                             @"master_seed":walletsecertStr
                                             
                                             };
                        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
                        NSString *strEncrypt = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        NSLog(@"strEncrypt--->%@",strEncrypt);
                        
                        [[JingtumJSManager shared] RegisterEncrypt:@{@"key":keyStr,@"encrypt":strEncrypt} withBlock:^(id responseData) {
                            
                            NSLog(@"responseData----====>%@",responseData);
                            NSString *encryptCodeStr=[responseData base64EncodedString];
//                            NSLog(@"code-----===>%@",encryptCodeStr);
                            
                            NSString *areaCode=[self.tmpPhoneCode stringByReplacingOccurrencesOfString:@"+" withString:@""];
                            //最终发送的json包
                            NSDictionary *dictTemp=@{@"account":userSha256,
                                                     @"secret":encryptCodeStr,
                                                     @"areacode":areaCode,
                                                     @"mobilephone":self.tmpPhone,
                                                     @"publickey":walletidStr,
                                                     @"type":@"2"};
                            NSLog(@"dictTemp-->%@",dictTemp);
                           
                            NSString *urlRegister=[NSString stringWithFormat:@"%@/register",GLOBAL_BLOB_VAULT];//注册
                            NSLog(@"urlRegister-->%@",urlRegister);
                            [[JingtumJSManager shared] operationManagerPOST:urlRegister parameters:dictTemp withBlock:^(NSString *error, id responseData) {
                                if ([error isEqualToString:@"0"])
                                {
                                    NSLog(@"注册返回数据->%@",responseData);
                                    if ([responseData[@"data"] isEqual:@"success"])
                                    {
                                        [SVProgressHUD dismiss];
                                        [USERDEFAULTS setObject:self.tmpPhone forKey:USERDEFAULTS_JINGTUM_PHONE];
                                        [USERDEFAULTS setObject:self.mNameTextFiled.text forKey:USERDEFAULTS_JINGTUM_USERNAME];
                                        [self savetoken];
                                        [self.navigationController popToRootViewControllerAnimated:YES];
                                    }
                                    else if ([[responseData[@"error"] objectForKey:@"code"] isEqualToString:@"ER_DUP_ENTRY"])
                                    {
                                        [SVProgressHUD dismiss];
                                        [self.mNameTextFiled becomeFirstResponder];
                                        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"用户名已存在" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                                        [alert show];
                                    }
                                    else
                                    {
                                        [SVProgressHUD dismiss];
                                        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"注册失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                                        [alert show];
                                        
                                    }

                                }
                                else
                                {
                                    [SVProgressHUD dismiss];
                                    NSLog(@"注册请求失败");
                                }
                            }];
                            
                        }];
                    }];
                }];
            }else{
                [self.mSureTextFiled becomeFirstResponder];
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"密码需与确认密码相同" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
            
        }else{
            [self.mPasswordTextFiled becomeFirstResponder];
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"密码最少为6个字符" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
        
    }else{
        [self.mNameTextFiled becomeFirstResponder];
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"用户名不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
    
}

- (void)savetoken
{
    NSString *tokenStr=[USERDEFAULTS objectForKey:JINGTUM_SAVETOKEN];
    NSString *urlStr = [NSString stringWithFormat:@"%@/saveUserToken",GLOBAL_BLOB_VAULT];
    NSString *url = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *dict=@{@"userType":@"1",@"address":walletAccountStr,@"token":tokenStr};
    
    [[JingtumJSManager shared] operationManagerPOST:url parameters:dict withBlock:^(NSString *error, id responseData) {
        if ([error isEqualToString:@"0"])
        {
            NSLog(@"注册保存token返回数据->%@",responseData);
        }
        else
        {
            NSLog(@"注册保存token请求失败");
        }
            
    }];
    
}

- (IBAction)background:(id)sender
{
    [self.view endEditing:YES];
}


@end
