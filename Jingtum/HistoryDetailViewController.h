//
//  HistoryDetailViewController.h
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryDetailViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *mPaymentNumLabel;
@property (strong, nonatomic) IBOutlet UILabel *mPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *mSelfAddress;
@property (strong, nonatomic) IBOutlet UILabel *mPaymentLabel;
@property (strong, nonatomic) IBOutlet UILabel *mOppoAddress;
@property (strong, nonatomic) IBOutlet UILabel *mChargeLabel;
@property (strong, nonatomic) IBOutlet UILabel *mAccountNum;

@property (nonatomic,strong) NSString *hashStr;

@end
