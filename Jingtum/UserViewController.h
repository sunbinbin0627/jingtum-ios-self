//
//  UserViewController.h
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JingtumJSManager.h"
#import "LXActionSheet.h"

@interface UserViewController : JingtumStatusViewController<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,LXActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSArray *list;
@property (nonatomic,strong) NSArray *imageList;

@property (strong, nonatomic) IBOutlet UITabBarItem *walletItem;

@property (strong,nonatomic) LXActionSheet *actionSheet;

- (IBAction)quitBtn:(id)sender;




@end
