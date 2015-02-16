//
//  UserParSecretViewController.m
//  Jingtum
//
//  Created by sunbinbin on 15-2-10.
//  Copyright (c) 2015年 OpenCoin Inc. All rights reserved.
//

#import "UserParSecretViewController.h"
#import "AppDelegate.h"
#import "JingtumJSManager.h"
#import "JingtumJSManager+NetworkStatus.h"
#import "NSString+Hashes.h"

@interface UserParSecretViewController ()
{
    UIView *_navView;
}
@end

@implementation UserParSecretViewController

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
    
    if (self.passwordFiled.text.length == 6)
    {
        if ([self.passwordFiled.text isEqualToString:self.passwordSureFiled.text])
        {
            
             NSString *urlStr = [NSString stringWithFormat:@"%@/setTransactionPassword",GLOBAL_BLOB_VAULT];
            
             NSString *secretStr=[NSString stringWithFormat:@"%@",[self.passwordFiled.text sha256]];
             NSDictionary *dict=@{@"account":[[JingtumJSManager shared] jingtumUserNameDecrypt],@"transactionPassword":secretStr,@"transactionPasswordFlag":@1};
            
            [[JingtumJSManager shared] operationManagerPOST:urlStr parameters:dict withBlock:^(NSString *error, id responseData) {
                
                if ([error isEqualToString:@"0"])
                {
                    NSLog(@"设置密码 responseData-->%@",responseData);
                    
                    if ([responseData objectForKey:@"data"] && ![[responseData objectForKey:@"data"] isEqual:[NSNull null]] && [[responseData objectForKey:@"data"] isEqualToString:@"SUCCESS"])
                    {
                        NSLog(@"修改密码成功");
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }
                    else
                    {
                        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"修改密码失败,请重新再试。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                        [alert show];
                        
                    }

                }
                
            }];
            
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"确认密码需与设置密码相同" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"请设置6位数字密码" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
    
}


- (IBAction)background:(id)sender
{
    [self.view endEditing:YES];
}



@end
