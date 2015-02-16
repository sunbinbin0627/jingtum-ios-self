//
//  UserAccountViewController.h
//  Jingtum
//
//  Created by sunbinbin on 14-11-17.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserAccountViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>


@property (nonatomic,strong) NSArray *titleList;
@property (nonatomic,strong) NSArray *imageList;

@property (strong, nonatomic) IBOutlet UITableView *tableView;


@end
