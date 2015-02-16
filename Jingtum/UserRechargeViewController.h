//
//  UserRechargeViewController.h
//  Jingtum
//
//  Created by sunbinbin on 15-1-21.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserSelectBankViewController.h"

@interface UserRechargeViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,RechargeDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)mSendBtn:(id)sender;

-(void)rechargeValue:(NSDictionary *)value;

@end
