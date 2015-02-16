//
//  UserSelectBankViewController.m
//  Jingtum
//
//  Created by sunbinbin on 15-1-22.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "UserSelectBankViewController.h"
#import "UserSelectCardTableViewCell.h"
#import "UserWithdrawViewController.h"
#import "UserRechargeViewController.h"
#import "AppDelegate.h"
#import "JingtumJSManager+NetworkStatus.h"

@interface UserSelectBankViewController ()
{
    UIView *_navView;
    NSMutableArray *listArr;
}
@end

@implementation UserSelectBankViewController

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
    [titleLabel setText:@"我的银行卡"];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [_navView addSubview:titleLabel];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 2+NavViewHeigth/2, 70, 40)];
    [backButton setTitle:@"返 回" forState:UIControlStateNormal];
    [backButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [backButton setTintColor:[UIColor whiteColor]];
    [backButton setBackgroundColor:[UIColor clearColor]];
    backButton.titleLabel.font=[UIFont systemFontOfSize:13];
    [backButton addTarget:self action:@selector(backtoGround) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:backButton];
    
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(11, (_navView.frame.size.height - 20)/2+5, 7, 10)];
    imageView.image=[UIImage imageNamed:@"title-left.png"];
    [_navView addSubview:imageView];
    
    self.tableView.tableFooterView=[[UIView alloc] init];
    
    listArr=[NSMutableArray arrayWithArray:@[@"添加银行卡"]];
    
//    [self getBankCard];
    
}


- (void)backtoGround
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getBankCard
{
    
//    NSMutableArray *cardarray=[[NSMutableArray alloc] init];
//    NSDictionary *cardTmp=@{@"card_name":@"农业银行",@"card_last":@"1232"};
//    [cardarray addObject:cardTmp];
//    [listArr insertObject:cardarray atIndex:0];
//    NSLog(@"listArr->%@",listArr);
//    [self.tableView reloadData];

    
    NSString *urlStr = [NSString stringWithFormat:@"http://192.168.10.113:3004/api/deposit/testBankCheck?identityid=493002407599521&identitytype=0"];
    NSString *url = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[JingtumJSManager shared] operationManagerGET:url parameters:nil withBlock:^(NSString *error, id responseData) {
        
        if ([error isEqualToString:@"0"])
        {
            NSLog(@"查询银行卡返回数据==>%@",responseData);
            NSMutableArray *cardarray=[[NSMutableArray alloc] init];
            if ([[responseData objectForKey:@"cardlist"] count] > 0)
            {
                for (NSDictionary *cardTmp in [responseData objectForKey:@"cardlist"])
                {
                    [cardarray addObject:cardTmp];
                }
                [listArr insertObjects:cardarray atIndexes:0];
                [self.tableView reloadData];
            }

        }
        else
        {
            NSLog(@"查询银行卡请求失败");
        }
        
    }];
    

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return listArr.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (listArr.count == 1)
    {
        return 1;
    }
    else if (listArr.count == 2)
    {
        if (section == 0)
        {
            return [[listArr objectAtIndex:0] count];
        }
        else if (section == 1)
        {
            return 1;
        }
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (listArr.count == 1)
    {
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"Cell"];
        cell.textLabel.textColor=RGBA(109, 109, 109, 1);
        cell.textLabel.font=[UIFont fontWithName:@"Helvetica" size:14.0];
        cell.textLabel.text=[listArr objectAtIndex:indexPath.row];
        
        return cell;
    }
    else if (listArr.count == 2)
    {
        if (indexPath.section == 0)
        {
            UserSelectCardTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cardCell"];
            
            NSDictionary *cardDict=[[listArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            cell.mTitleLabel.text=[cardDict objectForKey:@"card_name"];
            cell.mDetailLabel.text=[cardDict objectForKey:@"card_last"];
            
            return cell;
        }
        else if (indexPath.section == 1)
        {
            UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"Cell"];
            cell.textLabel.textColor=RGBA(109, 109, 109, 1);
            cell.textLabel.font=[UIFont fontWithName:@"Helvetica" size:14.0];
            cell.textLabel.text=[listArr objectAtIndex:indexPath.section];
            
            return cell;

        }
            
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (listArr.count == 1)
    {
        return 50;
    }
    else if (listArr.count == 2)
    {
        if (indexPath.section == 0)
        {
            return 70;
        }
        else if (indexPath.section == 1)
        {
            return 50;
        }
    }
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (listArr.count == 1)
    {
       [self performSegueWithIdentifier:@"add" sender:nil];
    }
    else if (listArr.count == 2)
    {
        if (indexPath.section == 0)
        {
            NSDictionary *cardDict=[[listArr objectAtIndex:0] objectAtIndex:indexPath.row];
            AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
            if (appdelegate.isWithdraw == NO)
            {
                [self.rechargeDelegate rechargeValue:cardDict];
            }
            else if (appdelegate.isWithdraw == YES)
            {
                [self.withdrawDelegate withdrawValue:cardDict];
            }
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if (indexPath.section == 1)
        {
            [self performSegueWithIdentifier:@"add" sender:nil];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



@end
