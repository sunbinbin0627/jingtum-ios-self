//
//  UserSetViewController.h
//  Jingtum
//
//  Created by sunbinbin on 15-1-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserSetViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) NSArray *list;
@property (nonatomic,strong) NSArray *imageList;


@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
