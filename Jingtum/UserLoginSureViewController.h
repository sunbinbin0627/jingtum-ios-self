//
//  UserLoginSureViewController.h
//  Jingtum
//
//  Created by sunbinbin on 15-1-13.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserLoginSureViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *passwordTextFiled;

@property (strong, nonatomic) IBOutlet UITextField *passwordSureTextFiled;

- (IBAction)sendBtn:(id)sender;

@end
