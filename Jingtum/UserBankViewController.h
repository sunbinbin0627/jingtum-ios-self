//
//  UserBankViewController.h
//  Jingtum
//
//  Created by sunbinbin on 15-1-22.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserAddBankViewController;

@interface UserBankViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UISearchDisplayDelegate>



@property (nonatomic,weak) UserAddBankViewController *addVC;

@property (strong, nonatomic) IBOutlet UISearchBar *mSearchBarView;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
