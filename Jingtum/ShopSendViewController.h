//
//  ShopSendViewController.h
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopSendViewController : JingtumStatusViewController<UITextFieldDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *mTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *mPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *mTotalLabel;

- (IBAction)mBuyBtn:(id)sender;

- (IBAction)mReduceBtn:(id)sender;
- (IBAction)mAddBtn:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *mReduceButton;
@property (strong, nonatomic) IBOutlet UIButton *mAddButton;

@property (strong, nonatomic) IBOutlet UITextField *mNumTextFiled;

@property (nonatomic,strong) NSString *tempTitle;
@property (nonatomic,strong) NSString *tempPrice;
@property (nonatomic,strong) NSString *tempCurrency;
@property (nonatomic,strong) NSString *tempNiufuCurrency;
@property (nonatomic,strong) NSString *tempName;

@end
