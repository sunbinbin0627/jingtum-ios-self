//
//  ZhuceSuccessViewController.h
//  Jingtum
//
//  Created by sunbinbin on 14-11-26.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZhuceSuccessViewController : JingtumStatusViewController<UIAlertViewDelegate,UITextFieldDelegate>


@property (strong, nonatomic) IBOutlet UITextField *mNameTextFiled;

@property (strong, nonatomic) IBOutlet UITextField *mPasswordTextFiled;

@property (strong, nonatomic) IBOutlet UITextField *mSureTextFiled;


- (IBAction)mDoneBtn:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *mDoneButton;

@property (strong, nonatomic) IBOutlet UILabel *tipLabel;

@property (nonatomic,strong) NSString *tmpPhone;
@property (nonatomic,strong) NSString *tmpPhoneCode;

@end
