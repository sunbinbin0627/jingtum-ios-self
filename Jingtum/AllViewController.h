//
//  AllViewController.h
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"

@interface AllViewController : JingtumStatusViewController<ZBarReaderDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIActionSheetDelegate,UIAlertViewDelegate>

- (IBAction)sendBtn:(id)sender;
- (IBAction)receiveBtn:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) IBOutlet UIButton *receiveButton;
@property (weak, nonatomic) IBOutlet UITabBarItem *wallettabitem;



@property (strong, nonatomic) IBOutlet UISegmentedControl *mSegementView;
- (IBAction)mSegementedChange:(UISegmentedControl *)sender;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSArray *cataList;
@property (nonatomic,strong) NSArray *imageList;
@property (nonatomic,strong) NSArray *credList;
@property (nonatomic,strong) NSArray *credImageList;
@property (nonatomic,strong) NSString *badgeNum;
@property (nonatomic,assign) int notifition;

@property (nonatomic,strong) NSIndexPath *selectIndex;
@property (nonatomic,assign) BOOL isopen;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

@end
