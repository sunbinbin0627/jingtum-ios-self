//
//  UserWithdrawViewController.m
//  Jingtum
//
//  Created by sunbinbin on 15-1-21.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "UserWithdrawViewController.h"
#import "AppDelegate.h"
#import "JingtumJSManager.h"
#import "JingtumJSManager+SendTransaction.h"
#import "JingtumJSManager+PaySecret.h"
#import "JingtumJSManager+NetworkStatus.h"
#import "UserWithdrawTableViewCell.h"
#import "UserSelectBankViewController.h"


@interface UserWithdrawViewController ()
{
    UIView *_navView;
    NSArray *list;
    UITextField *priceTextFiled;
    NSString *passwordFlag;
    UIAlertView *setAlert;
    UITextField *setFiled;
    UIAlertView *verifyAlert;
    UITextField *verifyFiled;
    UIAlertView *setFailAlert;
    UIAlertView *verifyFailAlert;
    
    NSString *amountStr;
    NSString *bankLastNum;
    NSString *cnyStr;
    
    
}
@end

@implementation UserWithdrawViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [AppDelegate  storyBoradAutoLay:self.view];
    
    passwordFlag=[USERDEFAULTS objectForKey:USERDEFAULTS_JINGTUM_PAYSECRET];
    
    cnyStr=[USERDEFAULTS objectForKey:USERDEFAULTS_JINGTUM_CNY];
    
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
    [titleLabel setText:@"提 现"];
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
    
    list=@[@[@"账户余额(CNY)"],@[@"选择银行卡",@"提现金额(元)"]];
    
    self.view.backgroundColor=RGBA(239, 239, 244, 1);
    self.tableView.backgroundView = [[UIView alloc]init];
    self.tableView.backgroundColor = RGBA(239, 239, 244, 1);
    self.tableView.tableFooterView=[[UIView alloc] init];
    
}

- (void)backtoGround
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate UITableViewDataSource

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
    UserWithdrawTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"withdrawCell"];
    
    cell.mTitleLabel.text=[[list objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    priceTextFiled=cell.mDetailTextFiled;
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            cell.accessoryType=UITableViewCellAccessoryNone;
            if (!cnyStr)
            {
                cnyStr=@"0.00";
            }
//            NSLog(@"CNY->%@",cnyStr);
            cell.mDetailTextFiled.text=cnyStr;
            cell.mDetailTextFiled.enabled=NO;
        }
        
    }
    if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            cell.mDetailTextFiled.enabled=NO;
            cell.mDetailTextFiled.text=bankLastNum;
        }
        else if (indexPath.row == 1)
        {
            cell.accessoryType=UITableViewCellAccessoryNone;
            cell.mDetailTextFiled.placeholder=@"请输入提现金额";
            [cell.mDetailTextFiled setKeyboardType:UIKeyboardTypeDecimalPad];
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
            [self performSegueWithIdentifier:@"select" sender:nil];
        }
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    if (textField == priceTextFiled)
    {
//    CGRect frame = textField.frame;
//    int offset = frame.origin.y + 32 - (self.view.frame.size.height - 216.0);//键盘高度216
        NSTimeInterval animationDuration = 0.30f;
        [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
        [UIView setAnimationDuration:animationDuration];
//    float width = self.view.frame.size.width;
//    float height = self.view.frame.size.height;
//    if(offset > 0)
//    {
//        CGRect rect = CGRectMake(0.0f, -offset-100,width,height);
//        self.view.frame = rect;
//    }
        CGRect rect = CGRectMake(0.0f, -156,self.view.frame.size.width,self.view.frame.size.height);
        self.view.frame = rect;
        [UIView commitAnimations];
    }

}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    amountStr=textField.text;
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"select"]) {
        UserSelectBankViewController * view = [segue destinationViewController];
        view.withdrawDelegate=self;
    }
}

#pragma mark - WithdrawDelegate

-(void)withdrawValue:(NSDictionary *)value
{
//    NSLog(@"value->%@",value);
    bankLastNum=[NSString stringWithFormat:@"尾号 %@",[value objectForKey:@"card_last"]];
    [self.tableView reloadData];
}

- (void)sendCNY
{
    NSDecimalNumber *amount=[NSDecimalNumber decimalNumberWithString:priceTextFiled.text];
    RPNewTransaction *transaction=[RPNewTransaction new];
    transaction.to_address=@"jUzZHim4iQ7zR9QHaoUM5LjuNzKvyCA9eV";
    transaction.to_currency=@"CNY";
    transaction.to_amount=amount;
    transaction.from_currency=@"CNY";
    transaction.to_issuer=JINGTUM_ISSURE;
    
    [[JingtumJSManager shared] wrapperSendSubmit:transaction withBlock:^(NSError *error) {
        if (!error)
        {
            NSLog(@"交易成功");
//            [self accountHash:<#(NSString *)#> andAmount:priceTextFiled.text];
        }
        else
        {
//            NSString *message=[NSString stringWithFormat:@"错误:%@",error.localizedDescription];
//            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//            [alert show];
        }
    }];

}


- (void)accountHash:(NSString *)hash andAmount:(NSString *)amount
{
    
    NSString *urlStr = [NSString stringWithFormat:@"http://rztong.jingtum.com/api/withdraw/addWithdraw"];
    NSString *url = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *dict=@{@"userAddress":[[JingtumJSManager shared] jingtumWalletAddress],
                         @"account":@"4324243145456434535",
                         @"address":@"江苏农业xxx分行",
                         @"amount":amount,
                         @"bank":@"ABC",
                         @"city":@"140500",
                         @"currency":@"CNY",
                         @"name":@"孙彬彬",
                         @"province":@"140000",
                         @"remark":@"收到了么",
                         @"status":@"0",
                         @"thirdAddress":@"jUzZHim4iQ7zR9QHaoUM5LjuNzKvyCA9eV",
                         @"transaction":hash,
                         @"type":@""};
    
    [[JingtumJSManager shared] operationManagerPOST:url parameters:dict withBlock:^(NSString *error, id responseData) {
        if ([error isEqualToString:@"0"])
        {
            NSLog(@"体现请求返回数据->%@",responseData);
        }
        else
        {
            NSLog(@"体现请求失败");
        }
    }];
    
    
}


- (IBAction)mSendBtn:(id)sender
{
    [priceTextFiled resignFirstResponder];
    
}





@end
