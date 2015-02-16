//
//  HistoryViewController.h
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;


@property (nonatomic,strong) NSIndexPath *selectIndex;
@property (nonatomic,assign) BOOL isopen;


@property(nonatomic,strong) NSArray *cataArr;
@property(nonatomic,strong) NSArray *paymentArr;
@property(nonatomic,strong) NSArray *currentAreaArr;


@property (strong, nonatomic) IBOutlet UIButton *allButton;

@property (strong, nonatomic) IBOutlet UIButton *selectButton;


- (IBAction)allBtn:(id)sender;
- (IBAction)selectBtn:(id)sender;


@end
