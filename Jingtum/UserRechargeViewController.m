//
//  UserRechargeViewController.m
//  Jingtum
//
//  Created by sunbinbin on 15-1-21.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "UserRechargeViewController.h"
#import "UserRechargeTableViewCell.h"
#import "AppDelegate.h"
#import "IPDetector.h"
#import "JingtumJSManager+NetworkStatus.h"

@interface UserRechargeViewController ()
{
    UIView *_navView;
    UITextField *priceFiled;
    NSString *bankLastNum;
}
@end

@implementation UserRechargeViewController

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
    [titleLabel setText:@"充 值"];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [_navView addSubview:titleLabel];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 2+NavViewHeigth/2, 70, 40)];
    [backButton setTitle:@"资金管理" forState:UIControlStateNormal];
    [backButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [backButton setTintColor:[UIColor whiteColor]];
    [backButton setBackgroundColor:[UIColor clearColor]];
    backButton.titleLabel.font=[UIFont systemFontOfSize:13];
    [backButton addTarget:self action:@selector(backtoGround) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:backButton];
    
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(11, (_navView.frame.size.height - 20)/2+5, 7, 10)];
    imageView.image=[UIImage imageNamed:@"title-left.png"];
    [_navView addSubview:imageView];
    
    
    self.view.backgroundColor=RGBA(239, 239, 244, 1);
    self.tableView.backgroundView = [[UIView alloc]init];
    self.tableView.backgroundColor = RGBA(239, 239, 244, 1);
    self.tableView.tableFooterView=[[UIView alloc] init];
    
}

- (void)backtoGround
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    UserRechargeTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"bankCell"];
    priceFiled=cell.mDetailTextFiled;
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            cell.mTitleLabel.text=@"选择银行卡";
            cell.mDetailTextFiled.enabled=NO;
            cell.mDetailTextFiled.text=bankLastNum;
        }
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            cell.accessoryType=UITableViewCellAccessoryNone;
            cell.mTitleLabel.text=@"金额";
            cell.mDetailTextFiled.placeholder=@"请输入充值金额";
            cell.mDetailTextFiled.keyboardType=UIKeyboardTypeDecimalPad;
            cell.mDetailTextFiled.delegate=self;
            
        }
    }
    return cell;
   
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
        [self performSegueWithIdentifier:@"select" sender:nil];
        }

    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    CGRect rect = CGRectMake(0.0f, -46,self.view.frame.size.width,self.view.frame.size.height);
    self.view.frame = rect;
    [UIView commitAnimations];
    
}


#pragma mark - RechargeDelegate

-(void)rechargeValue:(NSDictionary *)value
{
//    NSLog(@"value->%@",value);
    bankLastNum=[NSString stringWithFormat:@"尾号 %@",[value objectForKey:@"card_last"]];
    [self.tableView reloadData];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"select"]) {
        UserSelectBankViewController * view = [segue destinationViewController];
        view.rechargeDelegate=self;
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
}


- (IBAction)mSendBtn:(id)sender
{
    [self.view endEditing:YES];
    
//    [self sendRecharge];
    
}

- (void)sendRecharge
{
    [IPDetector getLANIPAddressWithCompletion:^(NSString *IPAddress) {
        NSLog(@"IPAddress-->%@",IPAddress);
        
        NSString *url = [NSString stringWithFormat:@"http://192.168.10.113:3004/api/deposit/testDebitCardPay"];
        url= [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSNumber *amountNum=[NSNumber numberWithInteger:[priceFiled.text integerValue]];
        NSDictionary *dict=@{@"amount":amountNum,
                             @"bindid":@"739",
                             @"currency":@156,
                             @"identityid":@"493002407599521",
                             @"identitytype":@0,
                             @"other":@"",
                             @"productcatalog":@"1",
                             @"productdesc":@"魔剑-阿波菲斯 鬼剑士 极品神装 全红字（绑卡支付）",
                             @"productname":@"魔剑-阿波菲斯",
                             @"userip":IPAddress,
                             @"callbackurl":@"http://172.18.66.107:8082/payapi-java-demo/callback",
                             @"terminaltype":@1,
                             @"terminalid":@"00-10-5C-AD-72-E3"};
        
        [[JingtumJSManager shared] operationManagerPOST:url parameters:dict withBlock:^(NSString *error, id responseData) {
            if ([error isEqualToString:@"0"])
            {
                NSLog(@"充值请求返回数据->%@",responseData);
            }
            else
            {
                NSLog(@"充值请求失败");
            }
        }];

        
    }];
    
}



@end
