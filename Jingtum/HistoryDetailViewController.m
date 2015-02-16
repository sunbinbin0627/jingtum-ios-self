//
//  HistoryDetailViewController.m
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "HistoryDetailViewController.h"
#import "JingtumJSManager+AccountTx.h"
#import "AppDelegate.h"

@interface HistoryDetailViewController ()
{
    UIView *_navView;
}

@end

@implementation HistoryDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [AppDelegate storyBoradAutoLay:self.view];
    
    
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
    [titleLabel setText:@"账单详情"];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [_navView addSubview:titleLabel];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(14, 2+NavViewHeigth/2, 70, 40)];
    [button setTitle:@"账 单" forState:UIControlStateNormal];
    [button setTintColor:[UIColor whiteColor]];
    [button setBackgroundColor:[UIColor clearColor]];
    button.titleLabel.font=[UIFont systemFontOfSize:13];
    [button addTarget:self action:@selector(backtoGround) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:button];
    
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(11, (_navView.frame.size.height - 20)/2+5, 7, 10)];
    imageView.image=[UIImage imageNamed:@"title-left.png"];
    [_navView addSubview:imageView];
    
    
    [self getInfomation];
    
}

- (void)backtoGround
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)getInfomation
{
    [[JingtumJSManager shared] wrapperAccountTx_transation:self.hashStr withBlock:^(id responseData) {
        
//        NSLog(@"tx_transation->%@",responseData);
        if ([[[responseData objectForKey:@"meta"] objectForKey:@"TransactionResult"] isEqualToString:@"tesSUCCESS"])
        {
            NSString *paymentNum=[NSString stringWithFormat:@"%@",[responseData objectForKey:@"hash"]];
            NSString *paymentStr=[NSString stringWithFormat:@"%@",[responseData objectForKey:@"TransactionType"]];
            NSString *accountNum=[NSString stringWithFormat:@"%@",[responseData objectForKey:@"inLedger"]];
            NSString *amountStr,*selfAccount,*oppoAccount;
            
            if ([[responseData objectForKey:@"TransactionType"] isEqualToString:@"Payment"])
            {
                selfAccount=[NSString stringWithFormat:@"%@",[responseData objectForKey:@"Account"]];
                oppoAccount=[NSString stringWithFormat:@"%@",[responseData objectForKey:@"Destination"]];
                
                if ([[responseData objectForKey:@"Amount"] isKindOfClass:[NSString class]])
                {
                    if ([selfAccount isEqualToString:[[JingtumJSManager shared] jingtumWalletAddress]])
                    {
                        amountStr=[NSString stringWithFormat:@"-%.2f",[[responseData objectForKey:@"Amount"] floatValue]*0.000001];
                    }
                    else
                    {
                        amountStr=[NSString stringWithFormat:@"+%.2f",[[responseData objectForKey:@"Amount"] floatValue]*0.000001];
                    }
                    
                }
                else if ([[responseData objectForKey:@"Amount"] isKindOfClass:[NSDictionary class]])
                {
                    NSDictionary *dict=[responseData objectForKey:@"Amount"];
                    if ([selfAccount isEqualToString:[[JingtumJSManager shared] jingtumWalletAddress]])
                    {
                        amountStr=[NSString stringWithFormat:@"-%.2f",[[dict objectForKey:@"value"] floatValue]];
                    }
                    else
                    {
                        amountStr=[NSString stringWithFormat:@"+%.2f",[[dict objectForKey:@"value"] floatValue]];
                    }
                    
                }

            }
            else if ([[responseData objectForKey:@"TransactionType"] isEqualToString:@"OfferCreate"])
            {
                selfAccount=[NSString stringWithFormat:@"%@",JINGTUM_ISSURE];
                oppoAccount=[NSString stringWithFormat:@"%@",[responseData objectForKey:@"Account"]];
                
                NSDictionary *takerPayDict=[responseData objectForKey:@"TakerPays"];
                amountStr=[NSString stringWithFormat:@"+%.2f",[[takerPayDict objectForKey:@"value"] floatValue]];
            }
            
            self.mPaymentNumLabel.text=paymentNum;
            self.mPriceLabel.text=amountStr;
            self.mSelfAddress.text=selfAccount;
            self.mPaymentLabel.text=paymentStr;
            self.mOppoAddress.text=oppoAccount;
            self.mAccountNum.text=accountNum;
            self.mChargeLabel.text=@"0.000012";
        }
        
        
    }];

}


@end
