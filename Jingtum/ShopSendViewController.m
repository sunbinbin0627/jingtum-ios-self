//
//  ShopSendViewController.m
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "ShopSendViewController.h"
#import "JingtumJSManager.h"
#import "JingtumJSManager+SendTransaction.h"
#import "JingtumJSManager+PaySecret.h"
#import "JingtumJSManager+NetworkStatus.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"

@interface ShopSendViewController ()
{
    UIView *_navView;
    NSDateFormatter *formatter;
    
    UIAlertView *verifyAlert;
    UIAlertView *verifyFailAlert;
    UITextField *verifyFiled;
}
@end

@implementation ShopSendViewController

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
    
    NSLog(@"tempCurrency-->%@",self.tempCurrency);
    
    //自定义navgation
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
    [titleLabel setText:@"确认结算"];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [_navView addSubview:titleLabel];
    
    UIButton *shopButton = [[UIButton alloc] initWithFrame:CGRectMake(14, 2+NavViewHeigth/2, 70, 40)];
    [shopButton setTitle:@"商品详情" forState:UIControlStateNormal];
    [shopButton setTintColor:[UIColor whiteColor]];
    [shopButton setBackgroundColor:[UIColor clearColor]];
    shopButton.titleLabel.font=[UIFont systemFontOfSize:13];
    [shopButton addTarget:self action:@selector(backtoGround) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:shopButton];
    
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(11, (_navView.frame.size.height - 20)/2+5, 7, 10)];
    imageView.image=[UIImage imageNamed:@"title-left.png"];
    [_navView addSubview:imageView];
    
    self.mNumTextFiled.text=@"1";
    self.mTitleLabel.text=self.tempTitle;
    self.mPriceLabel.text=self.tempPrice;
    self.mTotalLabel.text=self.tempPrice;
    
    //时间戳转时间的方法
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    
}

- (void)backtoGround
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)mBuyBtn:(id)sender
{
    [SVProgressHUD showWithStatus:@"购买中..." maskType:SVProgressHUDMaskTypeGradient];
    NSString *cnyStr=[USERDEFAULTS objectForKey:USERDEFAULTS_JINGTUM_CNY];
    if ([cnyStr integerValue] >= [self.mTotalLabel.text integerValue])
    {
        [self OfferCreate];
    }
    else
    {
        [SVProgressHUD dismiss];
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"余额不足" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
    
}

- (IBAction)mReduceBtn:(id)sender
{
    NSString *beforeStr=self.mNumTextFiled.text;
    NSString *afterStr=[NSString stringWithFormat:@"%d",[beforeStr intValue]-1];
    if ([afterStr intValue]<=1)
    {
        self.mNumTextFiled.text=@"1";
    }
    else
    {
        self.mNumTextFiled.text=afterStr;
    }
    
   
    if ([self.mNumTextFiled.text isEqualToString:@"1"])
    {
        [self.mReduceButton setImage:[UIImage imageNamed:@"min.png"] forState:UIControlStateNormal];
    }
    else
    {
        [self.mReduceButton setImage:[UIImage imageNamed:@"minclick.png"] forState:UIControlStateNormal];
    }
    
    NSString *totalStr=[NSString stringWithFormat:@"%d",[self.mNumTextFiled.text intValue]*[self.mPriceLabel.text intValue]];
    self.mTotalLabel.text=totalStr;
    
}

- (IBAction)mAddBtn:(id)sender
{
    NSString *beforeStr=self.mNumTextFiled.text;
    NSString *afterStr=[NSString stringWithFormat:@"%d",[beforeStr intValue]+1];
    self.mNumTextFiled.text=afterStr;
    [self.mReduceButton setImage:[UIImage imageNamed:@"minclick.png"] forState:UIControlStateNormal];
    
    NSString *totalStr=[NSString stringWithFormat:@"%d",[self.mNumTextFiled.text intValue]*[self.mPriceLabel.text intValue]];
    self.mTotalLabel.text=totalStr;
    
}

- (IBAction)background:(id)sender
{
    [self.view endEditing:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.mNumTextFiled)
    {
        NSString *totalStr=[NSString stringWithFormat:@"%d",[textField.text intValue]*[self.mPriceLabel.text intValue]];
        self.mTotalLabel.text=totalStr;
    }
  
}

- (void)OfferCreate
{
    NSString *flag=[USERDEFAULTS objectForKey:USERDEFAULTS_JINGTUM_PAYSECRET];

    if ([flag isEqualToString:@"0"])
    {
        [self buyShop];
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

- (void)buyShop
{
    NSDecimalNumber *amount=[NSDecimalNumber decimalNumberWithString:self.mNumTextFiled.text];
    NSDecimalNumber *actualAmount=[NSDecimalNumber decimalNumberWithString:self.mTotalLabel.text];
    RPCreatorder *transaction=[RPCreatorder new];
    transaction.sell_currency=self.tempCurrency;
    transaction.buy_currency=self.tempNiufuCurrency;
    transaction.amount=amount;
    transaction.actualTotal=actualAmount;
    transaction.flag=@"buy";
    
    [[JingtumJSManager shared] offcreate:transaction withBlock:^(NSError *error) {
        if (!error)
        {
            NSLog(@"交易成功");
            
            NSDictionary *dicttmp=[USERDEFAULTS objectForKey:USERDEFAULTS_JINGTUM_SHOPSURE];
            NSMutableDictionary *tmpshopDict=[NSMutableDictionary dictionaryWithDictionary:dicttmp];
            [tmpshopDict setObject:self.tempName forKey:self.tempCurrency];
            [USERDEFAULTS setObject:tmpshopDict forKey:USERDEFAULTS_JINGTUM_SHOPSURE];
            
            
            NSDate *senddate=[NSDate date];
            NSString *locationString=[formatter stringFromDate:senddate];
            NSLog(@"locationString:%@",locationString);
            [SVProgressHUD showSuccessWithStatus:@"成功"];
            NSString *notifitionStr=[NSString stringWithFormat:@"你已成功购买%@个%@",self.mNumTextFiled.text,self.tempName];
            
            NSDictionary *selfdict=@{@"type":@"shopbuy"};
            
            [self afnetWorkContent:notifitionStr andSelfPlayLoad:selfdict];
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        }
        else
        {
            NSString *message=[NSString stringWithFormat:@"失败:%@",error.localizedDescription];
            [SVProgressHUD showErrorWithStatus:message];
            NSLog(@"error:%@",error.localizedDescription);
        }
    }];

}


- (void)afnetWorkContent:(NSString *)content andSelfPlayLoad:(NSDictionary *)selfTmpPlayLoad
{
    NSString *urlStr = [NSString stringWithFormat:JINGTUM_TIPS_SEVER];
    NSString *url = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSArray *arr=@[@{@"address":[[JingtumJSManager shared] jingtumWalletAddress],@"content":content,@"payload":selfTmpPlayLoad}];
    
    [[JingtumJSManager shared] operationManagerPOST:url parameters:arr withBlock:^(NSString *error, id responseData) {
        
        if ([error isEqualToString:@"0"])
        {
            NSLog(@"发送tips返回数据->%@",responseData);
        }
        else
        {
            NSLog(@"发送tips请求失败");
        }
    }];
    
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == verifyAlert)
    {
        if (buttonIndex == 0)
        {
            [[JingtumJSManager shared] VerifyPaySecret:verifyFiled.text withBlock:^(id responseData) {
                
                NSLog(@"verify responseData%@",responseData);
                
                if ([responseData objectForKey:@"data"] && ![[responseData objectForKey:@"data"] isEqual:[NSNull null]] && [[responseData objectForKey:@"data"] isEqualToString:@"SUCCESS"])
                {
                    [self buyShop];

                }
                else
                {
                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"密码错误,请重新输入" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    verifyFailAlert=alert;
                    [alert show];
                    
                }
                
            }];

        }
        else
        {
            [SVProgressHUD dismiss];
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
            [SVProgressHUD dismiss];
        }
    }
}



@end
