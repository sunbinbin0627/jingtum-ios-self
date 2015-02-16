//
//  ContractViewController.h
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"
#import "LXActionSheet.h"

@interface ContractViewController : JingtumStatusViewController<UITableViewDataSource,UITableViewDelegate,UISearchDisplayDelegate,ZBarReaderDelegate,UITextFieldDelegate,LXActionSheetDelegate,UITabBarControllerDelegate,UIAlertViewDelegate>

@property (nonatomic,strong) NSMutableArray *nameList;
@property (nonatomic,strong) NSMutableArray *addresslist;
@property (nonatomic,strong) NSMutableArray *tagList;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *namearray;
@property (nonatomic,strong) NSMutableArray *xingarray;
@property (nonatomic,strong) NSMutableArray *addressarray;

@property (strong, nonatomic) IBOutlet UITabBarItem *walletItem;

@property (strong, nonatomic) LXActionSheet *actionSheet;

@end
