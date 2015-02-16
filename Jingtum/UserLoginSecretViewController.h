//
//  UserLoginSecretViewController.h
//  Jingtum
//
//  Created by sunbinbin on 15-1-13.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserLoginSecretViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) IBOutlet UIButton *numButton;

@property (strong, nonatomic) IBOutlet UITextField *sureNumTextFiled;
@property (strong, nonatomic) IBOutlet UILabel *phoneLabel;
@property (strong, nonatomic) IBOutlet UILabel *sureLabel;



- (IBAction)getNumBtn:(id)sender;
- (IBAction)nextBtn:(id)sender;





@end
