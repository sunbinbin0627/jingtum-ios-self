//
//  shopDetailViewController.h
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface shopDetailViewController : UIViewController<UIScrollViewDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *infoLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UILabel *sendLabel;
@property (strong, nonatomic) IBOutlet UILabel *mNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *mNameLabel2;
@property (strong, nonatomic) IBOutlet UILabel *mDataLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *mCurrencyNameLabel;


- (IBAction)mBuyBtn:(id)sender;
- (IBAction)mAddressBtn:(id)sender;
- (IBAction)mPhoneBtn:(id)sender;
- (IBAction)mUsersureBtn:(id)sender;
- (IBAction)mInfoBtn:(id)sender;



@property (strong, nonatomic) IBOutlet UIButton *mBuyButton;
@property (strong, nonatomic) IBOutlet UIScrollView *mScrollView;




@property (nonatomic,strong) NSString *tempName;
@property (nonatomic,strong) NSString *shopName;
@property (nonatomic,strong) NSString *infoName;
@property (nonatomic,strong) NSString *detalieName;
@property (nonatomic,strong) NSString *useSureName;
@property (nonatomic,strong) NSString *priceName;
@property (nonatomic,strong) NSString *sendName;
@property (nonatomic,strong) NSString *dataName;
@property (nonatomic,strong) NSString *addressName;
@property (nonatomic,strong) NSArray *imageName;
@property (nonatomic,strong) NSString *phoneName;
@property (nonatomic,strong) NSString *currencyTypeName;
@property (nonatomic,strong) NSString *niufuCurrencyName;
@end
