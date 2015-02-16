//
//  UserAbountViewController.h
//  Jingtum
//
//  Created by sunbinbin on 14-10-21.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface UserAbountViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,UIActionSheetDelegate,MFMailComposeViewControllerDelegate>


@property (nonatomic,strong) NSArray *list;


@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)aggrementBtn:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *mVersionLabel;

@end
