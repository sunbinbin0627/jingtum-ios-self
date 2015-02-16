//
//  UserWithdrawViewController.h
//  Jingtum
//
//  Created by sunbinbin on 15-1-21.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserSelectBankViewController.h"

@interface UserWithdrawViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIAlertViewDelegate,WithdrawDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)mSendBtn:(id)sender;


-(void)withdrawValue:(NSDictionary *)value;

@end
