//
//  UserCityViewController.h
//  Jingtum
//
//  Created by sunbinbin on 15-1-23.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserAddBankViewController;

@interface UserCityViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UISearchDisplayDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *mSearchBarView;

@property (strong, nonatomic) IBOutlet UITableView *tableView;


@property (nonatomic,weak) UserAddBankViewController *addVC;


@property (nonatomic, strong) NSMutableDictionary *cities;

@property (nonatomic, strong) NSMutableArray *keys; //城市首字母
@property (nonatomic, strong) NSMutableArray *arrayCitys;   //城市数据
@property (nonatomic, strong) NSMutableArray *arrayHotCity;


@end
