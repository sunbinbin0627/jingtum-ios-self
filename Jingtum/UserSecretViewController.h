//
//  UserSecretViewController.h
//  Jingtum
//
//  Created by sunbinbin on 15-1-13.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GesturePasswordController.h"
@interface UserSecretViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIAlertViewDelegate>

@property (nonatomic,strong) NSMutableArray *list;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) GesturePasswordController *gestureVC;

@end
