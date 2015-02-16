//
//  AddContractViewController.h
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddContractViewController : JingtumStatusViewController<UIAlertViewDelegate,UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *mAddressTextFiled;

@property (strong, nonatomic) IBOutlet UITextField *mNameTextFiled;


- (IBAction)mSendBtn:(id)sender;

@end
