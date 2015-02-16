//
//  CardInfoViewController.h
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"

@interface CardInfoViewController : UIViewController<UIScrollViewDelegate,ZBarReaderDelegate,UITextFieldDelegate,UIAlertViewDelegate>


@property (strong, nonatomic) IBOutlet UIScrollView *mScrollView;


@property (strong, nonatomic) IBOutlet UILabel *mPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *mDataLabel;
@property (strong, nonatomic) IBOutlet UILabel *mNumLabel;
@property (strong, nonatomic) IBOutlet UILabel *mNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *mShopInfoLabel;
@property (strong, nonatomic) IBOutlet UILabel *mNameLabel2;
@property (strong, nonatomic) IBOutlet UILabel *mCurrencyNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *mAddressLabel;
@property (strong, nonatomic) IBOutlet UIButton *useButton;


- (IBAction)useBtn:(id)sender;
- (IBAction)addressBtn:(id)sender;
- (IBAction)phoneBtn:(id)sender;
- (IBAction)sureBtn:(id)sender;
- (IBAction)detailBtn:(id)sender;



@property (nonatomic,strong) NSString *tempCurrencyTypeName;
@property (nonatomic,strong) NSString *tempPhoneNum;
@property (nonatomic,strong) NSArray *tempImageArr;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

@end
