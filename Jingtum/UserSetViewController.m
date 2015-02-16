//
//  UserSetViewController.m
//  Jingtum
//
//  Created by sunbinbin on 15-1-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "UserSetViewController.h"
#import "AppDelegate.h"

@interface UserSetViewController ()
{
    UIView *_navView;
}
@end

@implementation UserSetViewController

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
    [titleLabel setText:@"系统设置"];
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
    
    self.list=@[@"密码管理",@"通用设置"];
    self.imageList=@[@"passwordrevise.png",@"set.png"];
    
//    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.tableView.tableFooterView=[[UIView alloc] init];
    

    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)backtoGround
{
    [self.navigationController popViewControllerAnimated:YES];
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
    if (indexPath.row == 0)
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
        AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        appdelegate.lastLogin=NO;
        [self performSegueWithIdentifier:@"secret" sender:nil];
    }
    else if (indexPath.row==1)
    {
//        [self performSegueWithIdentifier:@"" sender:nil];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
