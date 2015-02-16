//
//  UserAddBankViewController.m
//  Jingtum
//
//  Created by sunbinbin on 15-1-22.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "UserAddBankViewController.h"
#import "UserAddBankTableViewCell.h"
#import "UserBankViewController.h"
#import "UserCityViewController.h"
#import "AppDelegate.h"
#import "JingtumJSManager+NetworkStatus.h"

@interface UserAddBankViewController ()
{
    UIView *_navView;
    NSArray *list;

}
@end

@implementation UserAddBankViewController

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
    [titleLabel setText:@"添加银行卡"];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [_navView addSubview:titleLabel];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 2+NavViewHeigth/2, 70, 40)];
    [backButton setTitle:@"取 消" forState:UIControlStateNormal];
    [backButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [backButton setTintColor:[UIColor whiteColor]];
    [backButton setBackgroundColor:[UIColor clearColor]];
    backButton.titleLabel.font=[UIFont systemFontOfSize:13];
    [backButton addTarget:self action:@selector(backtoGround) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:backButton];
    
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(11, (_navView.frame.size.height - 20)/2+5, 7, 10)];
    imageView.image=[UIImage imageNamed:@"title-left.png"];
    [_navView addSubview:imageView];
    
    list=@[@[@"持卡人姓名"],@[@"选择银行",@"银行卡号",@"开户城市",@"开户支行"]];
    
    self.tableView.tableFooterView=[[UIView alloc] init];
    self.tableView.backgroundColor = RGBA(239, 239, 244, 1);
    self.view.backgroundColor=RGBA(239, 239, 244, 1);
    
}

- (void)backtoGround
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}
    

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return list.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        
    return [[list objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserAddBankTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"addCell"];
    cell.mTitleLabel.text=[[list objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            cell.accessoryType=UITableViewCellAccessoryNone;
            cell.mDetailTextFiled.enabled=NO;
            NSDictionary *userDict=[USERDEFAULTS objectForKey:USERDEFAULTS_JINGTUM_USERSURE];
            cell.mDetailTextFiled.text=[userDict objectForKey:@"name"];
            
        }
       
    }
    if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            cell.mDetailTextFiled.enabled=NO;
            cell.mDetailTextFiled.text=self.bankName;
//            NSLog(@"bankName->%@ bankCode->%@",self.bankName,self.bankCode);
        }
        else if (indexPath.row == 1)
        {
            cell.accessoryType=UITableViewCellAccessoryNone;
            cell.mDetailTextFiled.keyboardType=UIKeyboardTypeNumberPad;
            cell.mDetailTextFiled.placeholder=@"请输入银行卡号";
        }
        else if (indexPath.row == 2)
        {
            cell.mDetailTextFiled.enabled=NO;
            cell.mDetailTextFiled.text=self.cityName;
//            NSLog(@"provinceCode:%@  cityCode:%@",self.provinceCode,self.cityCode);
        }
        else if (indexPath.row == 3)
        {
            cell.accessoryType=UITableViewCellAccessoryNone;
            cell.mDetailTextFiled.placeholder=@"请输入开户支行名称";
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            [self performSegueWithIdentifier:@"selectbank" sender:nil];
        }
        else if (indexPath.row == 2)
        {
            [self performSegueWithIdentifier:@"selectcity" sender:nil];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"selectbank"])
    {
        UserBankViewController *vc=(UserBankViewController *)segue.destinationViewController;
        vc.addVC=self;
    }
    else if ([segue.identifier isEqualToString:@"selectcity"])
    {
        UserCityViewController *vc=(UserCityViewController *)segue.destinationViewController;
        vc.addVC=self;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    

    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    CGRect rect = CGRectMake(0.0f, -216,self.view.frame.size.width,self.view.frame.size.height);
    self.view.frame = rect;
    [UIView commitAnimations];
    
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
 

- (IBAction)mSendBtn:(id)sender
{
//    [self BindingBank];
}

//绑定银行卡
- (void)BindingBank
{
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSLog(@"uuid->%@",uuid);
 
    
    NSString *url = [NSString stringWithFormat:@"http://192.168.10.224:3004/api/deposit/bindCard"];
    url= [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *dict=@{@"merchantaccount":@"",
                         @"cardno":@"",
                         @"idcardtype":@"01",
                         @"idcardno":@"342623199006270350",
                         @"username":@"孙彬彬",
                         @"phone":@"15155441200",
                         @"requestid":@"",
                         @"userip":@"",
                         @"productcatalog":@"",
                         @"identityid":@"",
                         @"identitytype":@"",
                         @"terminaltype":@2,
                         @"terminalid":uuid};
    
    [[JingtumJSManager shared] operationManagerPOST:url parameters:dict withBlock:^(NSString *error, id responseData) {
        if ([error isEqualToString:@"0"])
        {
            NSLog(@"绑卡请求返回数据->%@",responseData);
        }
        else
        {
            NSLog(@"绑卡请求失败");
        }
        
    }];
    
    
}

//获取手机验证码
- (void)phoneNum
{
    
    NSString * url = [NSString stringWithFormat:@"http://192.168.10.224:3004/api/deposit/bindCardResendSMS"];
    url= [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *dict=@{@"requestid":@"123456"};
    
    [[JingtumJSManager shared] operationManagerPOST:url parameters:dict withBlock:^(NSString *error, id responseData) {
        if ([error isEqualToString:@"0"])
        {
            NSLog(@"获取手机验证码请求返回数据->%@",responseData);
        }
        else
        {
            NSLog(@"获取手机验证码请求失败");
        }
        
    }];

     
}

//验证手机短信验证码
- (void)checkSMS
{
    NSString * url = [NSString stringWithFormat:@"http://192.168.10.224:3004/api/deposit/bindCardCheckSMS"];
    url= [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *dict=@{@"validatecode":@"3636271",
                         @"requestid":@"123456"};

    [[JingtumJSManager shared] operationManagerPOST:url parameters:dict withBlock:^(NSString *error, id responseData) {
        if ([error isEqualToString:@"0"])
        {
            NSLog(@"验证手机短信请求返回数据->%@",responseData);
        }
        else
        {
            NSLog(@"验证手机短信请求失败");
        }
        
    }];
    
}



@end
