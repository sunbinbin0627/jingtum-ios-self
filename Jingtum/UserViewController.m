//
//  UserViewController.m
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "UserViewController.h"
#import "JingtumJSManager+Authentication.h"
#import "JingtumJSManager+SendTransaction.h"
#import "LoginViewController.h"
#import "UserAbountViewController.h"
#import "UserAccountViewController.h"
#import "UserSetViewController.h"
#import "UserMoneyViewController.h"
#import "AppDelegate.h"
#import "JingtumJSManager.h"
#import <sqlite3.h>

@interface UserViewController ()
{
    NSString *secret;
    UIView *_navView;
    sqlite3 *db;//sqlite 数据库对象
    
}
@end

@implementation UserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [AppDelegate  storyBoradAutoLay:self.view];
    
    AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appdelegate.firstLogin == 1 || appdelegate.lastLogin == YES)
    {
        //在tabbar上添加小红点
        UIImageView *dotImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"redcircular.png"]];
        dotImage.backgroundColor = [UIColor clearColor];
        dotImage.tag = 111;
        CGRect tabFrame = self.tabBarController.tabBar.frame;
        CGFloat x = ceilf(0.91 * tabFrame.size.width);
        CGFloat y = ceilf(0.2 * tabFrame.size.height);
        dotImage.frame = CGRectMake(x, y, 6, 6);
        [self.tabBarController.tabBar addSubview:dotImage];
    }
    else
    {
        //去除tabbar上得小红点
        UIImageView *dotImage = [[UIImageView alloc] init];
        dotImage.backgroundColor = [UIColor clearColor];
        dotImage.tag = 222;
        CGRect tabFrame = self.tabBarController.tabBar.frame;
        CGFloat x = ceilf(0.91 * tabFrame.size.width);
        CGFloat y = ceilf(0.2 * tabFrame.size.height);
        dotImage.frame = CGRectMake(x, y, 10, 10);
        [self.tabBarController.tabBar addSubview:dotImage];
    }
    
    //tabbar图标
#ifdef IOS7_SDK_AVAILABLE
    _walletItem.image = [[UIImage imageNamed:@"moreOff.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _walletItem.selectedImage  = [[UIImage imageNamed:@"moreon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
#endif
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIView *statusBarView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, -20.f, self.view.frame.size.width, 0.f)];
    if (isIos7 >= 7 && __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1)
    {
        statusBarView.frame = CGRectMake(statusBarView.frame.origin.x, statusBarView.frame.origin.y, statusBarView.frame.size.width, 20.f);
        statusBarView.backgroundColor = [UIColor clearColor];
        ((UIImageView *)statusBarView).backgroundColor = RGBA(62,130,248,1);
        [self.view addSubview:statusBarView];
    }

    _navView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, StatusbarSize-20.f, self.view.frame.size.width, 44.f+NavViewHeigth)];
    ((UIImageView *)_navView).backgroundColor = RGBA(62,130,248,1);
    [self.view insertSubview:_navView belowSubview:statusBarView];
    _navView.userInteractionEnabled = YES;

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((_navView.frame.size.width - 200)/2, (_navView.frame.size.height - 40)/2, 200, 40)];
    [titleLabel setText:@"设 置"];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [_navView addSubview:titleLabel];
    
    
    self.list=@[@"账户设置",@"关于井通",@"系统设置",@"资金管理"];
    self.imageList=@[@"userAccount.png",@"userAbout.png",@"userAystem.png",@"money.png"];
    
//    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];

    self.tableView.tableFooterView=[[UIView alloc] init];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" ];
    
    cell.textLabel.textColor=RGBA(109, 109, 109, 1);
    cell.textLabel.font=[UIFont fontWithName:@"Helvetica" size:14.0];
    cell.textLabel.text=self.list[indexPath.row];
    cell.imageView.image=[UIImage imageNamed:self.imageList[indexPath.row]];
    if (indexPath.row == 0)
    {
        AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (appdelegate.firstLogin == 1)
        {
            UIImageView *dotImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"redcircular.png"]];
            dotImage.backgroundColor = [UIColor clearColor];
            dotImage.frame=CGRectMake(120, 14, 6, 6);
            [cell.contentView addSubview:dotImage];
        }
    }
    if (indexPath.row == 2)
    {
        AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (appdelegate.lastLogin == YES)
        {
            UIImageView *dotImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"redcircular.png"]];
            dotImage.backgroundColor = [UIColor clearColor];
            dotImage.frame=CGRectMake(120, 14, 6, 6);
            [cell.contentView addSubview:dotImage];
        }
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row==0)
    {
        [self performSegueWithIdentifier:@"account" sender:nil];
    }
    else if (indexPath.row==1)
    {
        [self performSegueWithIdentifier:@"abount" sender:nil];
    }
    else if (indexPath.row == 2)
    {
        [self performSegueWithIdentifier:@"set" sender:nil];
    }
    else
    {
        [self performSegueWithIdentifier:@"money" sender:nil];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - LXActionSheetDelegate

- (void)didClickOnButtonIndex:(NSInteger *)buttonIndex
{
//    int index=(int)buttonIndex;
//    NSLog(@"%d",index);
}

- (void)didClickOnDestructiveButton
{
//    NSLog(@"destructuctive");
    
    [[JingtumJSManager shared] logout];
    
    AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appdelegate  setmainview];
    
}

- (void)didClickOnCancelButton
{
//    NSLog(@"cancelButton");
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"account"]) {
        UserAccountViewController * view = [segue destinationViewController];
        view.hidesBottomBarWhenPushed=YES;
       
    }
    else if ([segue.identifier isEqualToString:@"abount"])
    {
        UserAbountViewController *vc=[segue destinationViewController];
        vc.hidesBottomBarWhenPushed=YES;
    }
    else if ([segue.identifier isEqualToString:@"set"])
    {
        UserSetViewController *vc=[segue destinationViewController];
        vc.hidesBottomBarWhenPushed=YES;
    }
    else
    {
        UserMoneyViewController *vc=[segue destinationViewController];
        vc.hidesBottomBarWhenPushed=YES;
    }
}


- (IBAction)quitBtn:(id)sender
{
    
    self.actionSheet=[[LXActionSheet alloc] initWithTitle:@"退出后不会删除任何历史数据,下次登录依然可以使用本账号。" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"退出登陆" otherButtonTitles:nil];
    [self.actionSheet showInView:self.view];
    
    
}
@end
