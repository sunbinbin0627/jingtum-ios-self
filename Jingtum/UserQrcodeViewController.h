//
//  UserQrcodeViewController.h
//  Jingtum
//
//  Created by sunbinbin on 14-12-2.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserQrcodeViewController : UIViewController<UIAlertViewDelegate>



@property (strong, nonatomic) IBOutlet UIButton *mQrcodeButton;

@property (strong, nonatomic) IBOutlet UILabel *mAddressLabel;

- (IBAction)copyBtn:(id)sender;

@end
