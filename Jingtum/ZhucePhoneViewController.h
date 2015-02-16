//
//  ZhucePhoneViewController.h
//  Jingtum
//
//  Created by sunbinbin on 14-11-26.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZhucePhoneViewController : UIViewController


@property (strong, nonatomic) IBOutlet UILabel *mPhoneNumLabel;

- (IBAction)sendBtn:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *sendButton;

- (IBAction)mNextBtn:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *mNextButton;

@property (strong, nonatomic) IBOutlet UITextField *makesureTextFiled;


@property (strong, nonatomic) IBOutlet UILabel *sendLabel;


@property (nonatomic,strong) NSString *tmpPhone;
@property (nonatomic,strong) NSString *tmpPhoneCode;

@end
