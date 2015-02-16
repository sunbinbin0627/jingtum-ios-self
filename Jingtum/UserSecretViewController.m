//
//  UserSecretViewController.m
//  Jingtum
//
//  Created by sunbinbin on 15-1-13.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "UserSecretViewController.h"
#import "GesturePasswordController.h"
#import "GestureChangeViewController.h"
#import "AppDelegate.h"
#import "JingtumJSManager.h"
#import "JingtumJSManager+NetworkStatus.h"
#import "NSString+Hashes.h"

@interface UserSecretViewController ()
{
    UIView *_navView;
    UISwitch *gestureSwitchView;
    UISwitch *paySecretSwitchView;
    BOOL isfirst;
    NSString *flag;
    
    UIAlertView *setAlert;
    UIAlertView *verifyAlert;
    UIAlertView *setFailAlert;
    UIAlertView *verifyFailAlert;
    UITextField *setFiled;
    UITextField *setVerifyFiled;
    UITextField *verifyFiled;
    
}
@end

@implementation UserSecretViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [AppDelegate  storyBoradAutoLay:self.view];
    
    isfirst=YES;
    
    gestureSwitchView=[[UISwitch alloc] initWithFrame:CGRectMake1(260, 8, 40, 20)];
    [gestureSwitchView addTarget:self action:@selector(gestureSwitchAction:) forControlEvents:UIControlEventValueChanged];
    
    
    paySecretSwitchView=[[UISwitch alloc] initWithFrame:CGRectMake1(260, 8, 40, 20)];
    [paySecretSwitchView addTarget:self action:@selector(paySecretSwitchAction:) forControlEvents:UIControlEventValueChanged];
    
    flag=[USERDEFAULTS objectForKey:USERDEFAULTS_JINGTUM_PAYSECRET];
    NSLog(@"flag->%@",flag);
    if ([flag isEqualToString:@"0"])
    {
        [paySecretSwitchView setOn:NO];
    }
    else
    {
        [paySecretSwitchView setOn:YES];
    }
    
    AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appdelegate.isGesture)
    {
        [gestureSwitchView setOn:YES];
    }
    else
    {
        [gestureSwitchView setOn:NO];
    }
    
    //添加通知观察者
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSecret) name:kNotificationUserSecret object:nil];
    
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
    [titleLabel setText:@"密码设置"];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [_navView addSubview:titleLabel];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 2+NavViewHeigth/2, 70, 40)];
    [backButton setTitle:@"系统设置" forState:UIControlStateNormal];
    [backButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [backButton setTintColor:[UIColor whiteColor]];
    [backButton setBackgroundColor:[UIColor clearColor]];
    backButton.titleLabel.font=[UIFont systemFontOfSize:13];
    [backButton addTarget:self action:@selector(backtoGround) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:backButton];
    
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(11, (_navView.frame.size.height - 20)/2+5, 7, 10)];
    imageView.image=[UIImage imageNamed:@"title-left.png"];
    [_navView addSubview:imageView];
    
    self.list=[NSMutableArray arrayWithObjects:@"登录密码",@"支付密码",@"修改支付密码",@"开启手势密码",@"修改手势密码", nil];
    
    self.tableView.tableFooterView=[[UIView alloc] init];
    
}

- (void)updateSecret
{
    [gestureSwitchView setOn:NO];
    [self.tableView reloadData];
}

- (void)backtoGround
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" ];
    
    cell.textLabel.textColor=RGBA(109, 109, 109, 1);
    cell.textLabel.font=[UIFont fontWithName:@"Helvetica" size:14.0];
    cell.textLabel.text=self.list[indexPath.row];

   
    if (indexPath.row == 0)
    {
        if (isfirst)
        {
            UILabel *loginLabel=[[UILabel alloc] initWithFrame:CGRectMake1(188, 12, 100, 20)];
            loginLabel.textAlignment=NSTextAlignmentRight;
            loginLabel.textColor=RGBA(109, 109, 109, 1);
            loginLabel.font=[UIFont fontWithName:@"Helvetica" size:14.0];
            loginLabel.text=[NSString stringWithFormat:@"修改"];
            [cell.contentView addSubview:loginLabel];
        }

    }
    else if (indexPath.row == 1)
    {
        if (isfirst)
        {
            cell.accessoryType=UITableViewCellAccessoryNone;
            [cell.contentView addSubview:paySecretSwitchView];
        }
    }
    else if (indexPath.row == 2)
    {
        if ([flag isEqualToString:@"0"])
        {
            cell.hidden=YES;
        }
        else
        {
            cell.hidden=NO;
        }
    }
    else if (indexPath.row == 3)
    {
        if (isfirst)
        {
            cell.accessoryType=UITableViewCellAccessoryNone;
            [cell.contentView addSubview:gestureSwitchView];

        }
        
    }
    
    if (indexPath.row == 4)
    {
        AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (appdelegate.isGesture)
        {
            cell.hidden=NO;
        }
        else
        {
            cell.hidden=YES;
        }
        
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row==0)
    {
        [self performSegueWithIdentifier:@"Next" sender:nil];
        AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        appdelegate.isLoginSecret=NO;
    }
    else if (indexPath.row == 1)
    {
//        [self performSegueWithIdentifier:@"pay" sender:nil];
    }
    else if (indexPath.row == 2)
    {
        [self performSegueWithIdentifier:@"Next" sender:nil];
        AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        appdelegate.isLoginSecret=YES;
    }
    else if (indexPath.row == 4)
    {
        [self presentViewController:[[GestureChangeViewController alloc] init] animated:YES completion:nil];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)gestureSwitchAction:(id)sender
{
    AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UISwitch *whichSwitch = (UISwitch *)sender;
    if (whichSwitch.isOn)
    {
        isfirst=NO;
        appdelegate.isGesture=YES;
        [self presentViewController:[[GesturePasswordController alloc] init] animated:YES completion:nil];
        [self.tableView reloadData];
        NSLog(@"打开了");
    }
    else
    {
        isfirst=NO;
        appdelegate.isGesture=NO;
        GesturePasswordController *vc=[[GesturePasswordController alloc] init];
        [vc clear];
        [self.tableView reloadData];
        NSLog(@"关闭了");
    }
}

- (void)paySecretSwitchAction:(id)sender
{
    UISwitch *whichSwitch = (UISwitch *)sender;
    if (whichSwitch.isOn)
    {
        isfirst=NO;
        [self takeMoney];
        NSLog(@"打开了");
    }
    else
    {
        isfirst=NO;
        [self takeMoney];
        NSLog(@"关闭了");
    }

}

 
- (void)takeMoney
{
    if ([flag isEqualToString:@"0"])
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"请设置6位数字支付密码." delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        alert.alertViewStyle=UIAlertViewStyleLoginAndPasswordInput;
        setFiled=[alert textFieldAtIndex:0];
        setVerifyFiled=[alert textFieldAtIndex:1];
        setFiled.delegate=self;
        setVerifyFiled.delegate=self;
        setFiled.placeholder=@"请输入设置密码";
        setVerifyFiled.placeholder=@"请输入确认密码";
        [setFiled setKeyboardType:UIKeyboardTypeNumberPad];
        [setVerifyFiled setKeyboardType:UIKeyboardTypeNumberPad];
        setFiled.secureTextEntry=YES;
        setVerifyFiled.secureTextEntry=YES;
        
        setAlert=alert;
        [alert show];
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


#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == setAlert)
    {
        if (buttonIndex == 0)
        {
            [self setSecret];
        }
        else
        {
            flag=@"0";
            [paySecretSwitchView setOn:NO animated:YES];
            [self.tableView reloadData];
        }
    }
    else if (alertView == setFailAlert)
    {
        if (buttonIndex == 0)
        {
            setFiled.text=@"";
            setVerifyFiled.text=@"";
            [setAlert show];
        }
        else
        {
            flag=@"0";
            [paySecretSwitchView setOn:NO animated:YES];
            [self.tableView reloadData];
        }
    }

    else if (alertView == verifyAlert)
    {
        if (buttonIndex == 0)
        {
            [self verifySecret];
        }
        else
        {
            [paySecretSwitchView setOn:YES animated:YES];
            [self.tableView reloadData];
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
            [paySecretSwitchView setOn:YES animated:YES];
            [self.tableView reloadData];
        }
    }
}


- (void)setSecret
{
    if (setFiled.text.length == 6)
    {
        if ([setFiled.text isEqualToString:setVerifyFiled.text])
        {
            NSString *urlStr = [NSString stringWithFormat:@"%@/setTransactionPassword",GLOBAL_BLOB_VAULT];
            
            NSString *secretStr=[NSString stringWithFormat:@"%@",[setFiled.text sha256]];
            NSDictionary *dict=@{@"account":[[JingtumJSManager shared] jingtumUserNameDecrypt],@"transactionPassword":secretStr,@"transactionPasswordFlag":@1};
            
            [[JingtumJSManager shared] operationManagerPOST:urlStr parameters:dict withBlock:^(NSString *error, id responseData) {
                
                NSLog(@"设置密码 responseData-->%@",responseData);
                if ([error isEqualToString:@"0"])
                {
                    if ([responseData objectForKey:@"data"] && ![[responseData objectForKey:@"data"] isEqual:[NSNull null]] && [[responseData objectForKey:@"data"] isEqualToString:@"SUCCESS"])
                    {
                        flag=@"1";
                        [USERDEFAULTS setObject:flag forKey:USERDEFAULTS_JINGTUM_PAYSECRET];
                        [self.tableView reloadData];
                    }
                    else
                    {
                        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"服务器错误,请重新再试。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                        setFailAlert=alert;
                        [alert show];
                        
                    }

                }
                
            }];

        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"确认密码需与设置密码相同" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            setFailAlert=alert;
            [alert show];
        }
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"设置失败:请正确输入6位数字密码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        setFailAlert=alert;
        [alert show];
    }
    
}

- (void)verifySecret
{
    NSString * urlStr = [NSString stringWithFormat:@"%@/checkTransactionPassword",GLOBAL_BLOB_VAULT];
    
    NSString *secretStr=[NSString stringWithFormat:@"%@",[verifyFiled.text sha256]];
    NSDictionary *dict=@{@"account":[[JingtumJSManager shared] jingtumUserNameDecrypt],@"transactionPassword":secretStr};
    
    [[JingtumJSManager shared] operationManagerPOST:urlStr parameters:dict withBlock:^(NSString *error, id responseData) {
        
        NSLog(@"确认密码 responseData%@",responseData);
        if ([error isEqualToString:@"0"])
        {
            if ([responseData objectForKey:@"data"] && ![[responseData objectForKey:@"data"] isEqual:[NSNull null]] && [[responseData objectForKey:@"data"] isEqualToString:@"SUCCESS"])
            {
                
                NSString *urlStr2 = [NSString stringWithFormat:@"%@/setTransactionPassword",GLOBAL_BLOB_VAULT];
                NSDictionary *dict2=@{@"account":[[JingtumJSManager shared] jingtumUserNameDecrypt],@"transactionPassword":@"",@"transactionPasswordFlag":@0};
                
                [[JingtumJSManager shared] operationManagerPOST:urlStr2 parameters:dict2 withBlock:^(NSString *error, id responseData){
                    
                    NSLog(@"取消支付密码 responseData-->%@",responseData);
                    if ([error isEqualToString:@"0"])
                    {
                        if ([responseData objectForKey:@"data"] && ![[responseData objectForKey:@"data"] isEqual:[NSNull null]] && [[responseData objectForKey:@"data"] isEqualToString:@"SUCCESS"])
                        {
                            flag=@"0";
                            [USERDEFAULTS setObject:@"0" forKey:USERDEFAULTS_JINGTUM_PAYSECRET];
                            [self.tableView reloadData];
                        }
                        else
                        {
                            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"服务器错误,请稍后再试。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                            [alert show];
                            
                        }
                        
                    }
                    
                }];
                
            }
            else
            {
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"密码错误,请重新输入" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                verifyFailAlert=alert;
                [alert show];
                
            }

        }
      
    }];
    
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
