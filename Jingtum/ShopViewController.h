//
//  ShopViewController.h
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopViewController : JingtumStatusViewController<UITableViewDataSource,UITableViewDelegate,UISearchDisplayDelegate>


@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UITabBarItem *walletItem;

@end
