//
//  UserMoneyViewController.m
//  Jingtum
//
//  Created by sunbinbin on 15-1-20.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "UserMoneyViewController.h"
#import "UserWithdrawViewController.h"
#import "UserRechargeViewController.h"
#import "AppDelegate.h"

@interface UserMoneyViewController ()
{
    UIView *_navView;
}
@end

@implementation UserMoneyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [AppDelegate  storyBoradAutoLay:self.view];
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIView *statusBarView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, 0.f)];
    if (isIos7 >= 7 && __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1)
    {
        statusBarView.frame = CGRectMake(statusBarView.frame.origin.x, statusBarView.frame.origin.y, statusBarView.frame.size.width, 20.f);
        statusBarView.backgroundColor = [UIColor clearColor];
        ((UIImageView *)statusBarView).backgroundColor = RGBA(62,130,248,1);
        [self.view addSubview:statusBarView];
    }
    
    _navView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, StatusbarSize, self.view.frame.size.width, 44.f+NavViewHeigth)];
    ((UIImageView *)_navView).backgroundColor = RGBA(62,130,248,1);
    [self.view insertSubview:_navView belowSubview:statusBarView];
    _navView.userInteractionEnabled = YES;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((_navView.frame.size.width - 200)/2, (_navView.frame.size.height - 40)/2, 200, 40)];
    [titleLabel setText:@"资金管理"];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [_navView addSubview:titleLabel];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 2+NavViewHeigth/2, 70, 40)];
    [backButton setTitle:@"设 置" forState:UIControlStateNormal];
    [backButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [backButton setTintColor:[UIColor whiteColor]];
    [backButton setBackgroundColor:[UIColor clearColor]];
    backButton.titleLabel.font=[UIFont systemFontOfSize:13];
    [backButton addTarget:self action:@selector(backtoGround) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:backButton];
    
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(11, (_navView.frame.size.height - 20)/2+5, 7, 10)];
    imageView.image=[UIImage imageNamed:@"title-left.png"];
    [_navView addSubview:imageView];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(_navView.frame.size.width-41, 2+NavViewHeigth/2, 40, 40)];
    [button setTitle:@"记录" forState:UIControlStateNormal];
    [button setTintColor:[UIColor whiteColor]];
    [button setBackgroundColor:[UIColor clearColor]];
    button.titleLabel.font=[UIFont systemFontOfSize:13];
    [button addTarget:self action:@selector(pushToAccount) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:button];
    
    
    self.list=@[@"充值",@"提现"];
    self.imageList=@[@"recharge.png",@"cash.png"];
    
    //    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.tableView.tableFooterView=[[UIView alloc] init];
    
}

- (void)backtoGround
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pushToAccount
{
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" ];
    
    cell.textLabel.textColor=RGBA(109, 109, 109, 1);
    cell.textLabel.font=[UIFont fontWithName:@"Helvetica" size:14.0];
    cell.textLabel.text=self.list[indexPath.row];
    cell.imageView.image=[UIImage imageNamed:self.imageList[indexPath.row]];
    
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
        [self performSegueWithIdentifier:@"pay" sender:nil];
        AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        appdelegate.isWithdraw=NO;
    }
    else if (indexPath.row==1)
    {
        [self performSegueWithIdentifier:@"get" sender:nil];
        AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        appdelegate.isWithdraw=YES;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"get"]) {
        UserWithdrawViewController * view = [segue destinationViewController];
        view.hidesBottomBarWhenPushed=YES;
        
    }
    else if ([segue.identifier isEqualToString:@"pay"]){
        UserRechargeViewController * view = [segue destinationViewController];
        view.hidesBottomBarWhenPushed=YES;
    }
}




@end
