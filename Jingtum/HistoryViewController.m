//
//  HistoryViewController.m
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "HistoryViewController.h"
#import "JingtumJSManager.h"
#import "JingtumJSManager+AccountTx.h"
#import "RPContact.h"
#import "HistoryTableViewCell.h"
#import "MJRefresh.h"
#import "AppDelegate.h"
#import <sqlite3.h>
#import "UserDB.h"
#import "RPHistory.h"
#import "FSDropDownMenu.h"
#import "HistoryDetailViewController.h"

@interface HistoryViewController () <FSDropDownMenuDataSource,FSDropDownMenuDelegate>//<DOPDropDownMenuDataSource,DOPDropDownMenuDelegate>
{

    NSMutableArray *contracts;

    NSArray *timeArr,*paymentArr,*catagoryArr;//分类下拉
    AFHTTPRequestOperationManager * myOperationManager;//请求联系人
    UIView *_navView;
    
    
    NSDateFormatter* formatter;//时间
    NSDictionary *yearDate;//十二个月对应的天数
    sqlite3 *db;//sqlite 数据库对象
    
    NSMutableDictionary *historyAllDict;//历史总账单
    NSMutableArray *sectionArr;//段标题
    NSInteger indexNum;//判断是筛选中的那个tableview
    BOOL isDown;
    NSString *hashTmp;
    
    int historyTxNum;
    
}
@end

@implementation HistoryViewController
@synthesize paymentArr;
@synthesize cataArr;
@synthesize currentAreaArr;

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
    
    FSDropDownMenu *menu = [[FSDropDownMenu alloc] initWithOrigin:CGPointMake(0, 64+30) andHeight:240];
    menu.tag = 1001;
    menu.dataSource = self;
    menu.delegate = self;
    menu.rightTableView.tableFooterView=[[UIView alloc] init];
    menu.leftTableView.tableFooterView=[[UIView alloc] init];
    [self.view addSubview:menu];
    
    self.cataArr = @[@"币种",@"交易类型"];
    self.paymentArr = @[
                 @[@"SWT",@"CNY",@"USD"],
                 @[@"发送",@"接收"]
                 ];
    self.currentAreaArr = self.paymentArr[0];
    
    indexNum=0;
    
    isDown=YES;
    
    historyTxNum=0;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateHistoryTx:) name:kNotificationUpdatedAccountTx object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationUserLoggedOut:) name:kNotificationUserLoggedOut object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationHistoryChange:) name:kNotificationHistoryChange object:nil];
    
    //设置tableView的下划线
//    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
     self.tableView.tableFooterView=[[UIView alloc] init];
    
    //自定义navgation
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
    [titleLabel setText:@"账 单"];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [_navView addSubview:titleLabel];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(14, 2+NavViewHeigth/2, 70, 40)];
    [button setTitle:@"我的钱包" forState:UIControlStateNormal];
    [button setTintColor:[UIColor whiteColor]];
    [button setBackgroundColor:[UIColor clearColor]];
    button.titleLabel.font=[UIFont systemFontOfSize:13];
    [button addTarget:self action:@selector(backtoGround) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:button];
    
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(11, (_navView.frame.size.height - 20)/2+5, 7, 10)];
    imageView.image=[UIImage imageNamed:@"title-left.png"];
    [_navView addSubview:imageView];
    
    //时间戳转时间的方法
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    
    yearDate=@{@"01":@"01月01日-01月30日",
               @"02":@"02月01日-02月28日",
               @"03":@"03月01日-03月31日",
               @"04":@"04月01日-04月30日",
               @"05":@"05月01日-05月31日",
               @"06":@"06月01日-06月30日",
               @"07":@"07月01日-07月31日",
               @"08":@"08月01日-08月31日",
               @"09":@"09月01日-09月30日",
               @"10":@"10月01日-10月31日",
               @"11":@"11月01日-11月30日",
               @"12":@"12月01日-12月31日"};
    
    myOperationManager = [AFHTTPRequestOperationManager manager];
    
    [self setupRefresh];
    
}

- (void)backtoGround
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - 更新账单

- (void)updateTx
{
    NSArray *history=[[UserDB shareInstance] findAllHistory];
    historyAllDict=[[NSMutableDictionary alloc] init];
    sectionArr=[[NSMutableArray alloc] init];
    
    NSArray *keys=[yearDate allKeys];
    for (NSString *key in keys)
    {
        NSMutableDictionary *sectionDict=[[NSMutableDictionary alloc] init];
        NSMutableArray *tempArr=[[NSMutableArray alloc] init];
        for (RPHistory *rp in history)
        {
//             NSLog(@"%@ %@ %@ %@ %@ %@ %@ %@ %@ %@ %@ %@",rp.type,rp.accountType,rp.accountResult,rp.image,rp.price,rp.message,rp.key,rp.detailTime,rp.mounthTime,rp.mounthDay,rp.address,rp.hash);
            if ([rp.mounthTime isEqualToString:key])
            {
                NSMutableDictionary *tmpDict=[[NSMutableDictionary alloc ] init];
                [tmpDict setObject:rp.image forKey:@"image"];
                [tmpDict setObject:rp.price forKey:@"price"];
                [tmpDict setObject:rp.detailTime forKey:@"time"];
                [tmpDict setObject:rp.accountResult forKey:@"result"];
                [tmpDict setObject:rp.accountType forKey:@"type"];
                [tmpDict setObject:rp.message forKey:@"message"];
                [tmpDict setObject:rp.hash forKey:@"hash"];
                [tempArr addObject:tmpDict];
                [sectionDict setObject:rp.mounthDay forKey:@"month"];
                [historyAllDict setObject:tempArr forKey:rp.mounthDay];
                
            }
        }
        if (tempArr.count != 0)
        {
            [sectionArr addObject:[sectionDict objectForKey:@"month"]];
        
        }
        
    }
    
//    [sectionArr replaceObjectAtIndex:0 withObject:@"本月"];
//    NSLog(@"sectionArr->%@",sectionArr);
    NSLog(@"historyAllDict->%@",historyAllDict);
    if (sectionArr.count != 0)
    {
        NSString *tmp;
        for (int i=0; i<=sectionArr.count-1; i++)
        {
            for (int j=0; j<sectionArr.count-i-1; j++)
            {
                if ([sectionArr[j] integerValue] < [sectionArr[j+1] integerValue])
                {
                    tmp=sectionArr[j];
                    sectionArr[j]=sectionArr[j+1];
                    sectionArr[j+1]=tmp;
                }
            }
        }
//    NSLog(@"sectionArrAfter->%@",sectionArr);
    }
   
    
    [self.tableView reloadData];
    [self.tableView headerEndRefreshing];
    [self.tableView footerEndRefreshing];
    
}



- (void)updateSelectTx:(NSString *)type andSqlite:(NSString *)sqlite
{
    NSArray *history=[[UserDB shareInstance] searchHistory:type andSqlite:sqlite];
    historyAllDict=[[NSMutableDictionary alloc] init];
    sectionArr=[[NSMutableArray alloc] init];
    
    NSArray *keys=[yearDate allKeys];
    for (NSString *key in keys)
    {
        NSMutableDictionary *sectionDict=[[NSMutableDictionary alloc] init];
        NSMutableArray *tempArr=[[NSMutableArray alloc] init];
        for (RPHistory *rp in history)
        {
            NSLog(@"%@ %@ %@ %@ %@ %@ %@ %@ %@ %@ %@ %@",rp.type,rp.accountType,rp.accountResult,rp.image,rp.price,rp.message,rp.key,rp.detailTime,rp.mounthTime,rp.mounthDay,rp.address,rp.hash);
            if ([rp.mounthTime isEqualToString:key])
            {
                NSMutableDictionary *tmpDict=[[NSMutableDictionary alloc ] init];
                [tmpDict setObject:rp.image forKey:@"image"];
                [tmpDict setObject:rp.price forKey:@"price"];
                [tmpDict setObject:rp.detailTime forKey:@"time"];
                [tmpDict setObject:rp.accountResult forKey:@"result"];
                [tmpDict setObject:rp.accountType forKey:@"type"];
                [tmpDict setObject:rp.message forKey:@"message"];
                [tmpDict setObject:rp.hash forKey:@"hash"];
                [tempArr addObject:tmpDict];
                [sectionDict setObject:rp.mounthDay forKey:@"month"];
                [historyAllDict setObject:tempArr forKey:rp.mounthDay];
                
            }
        }
        if (tempArr.count != 0)
        {
            [sectionArr addObject:[sectionDict objectForKey:@"month"]];
            
        }
        
    }
    
    //    [sectionArr replaceObjectAtIndex:0 withObject:@"本月"];
//    NSLog(@"sectionArr->%@",sectionArr);
    NSLog(@"historyAllDict->%@",historyAllDict);
    if (sectionArr.count != 0)
    {
        NSString *tmp;
        for (int i=0; i<=sectionArr.count-1; i++)
        {
            for (int j=0; j<sectionArr.count-i-1; j++)
            {
                if ([sectionArr[j] integerValue] < [sectionArr[j+1] integerValue])
                {
                    tmp=sectionArr[j];
                    sectionArr[j]=sectionArr[j+1];
                    sectionArr[j+1]=tmp;
                }
            }
        }

    }
    
    [self.tableView reloadData];
    
}



#pragma mark - 下拉上拉刷新

- (void)setupRefresh
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    [self.tableView headerBeginRefreshing];//一进入程序就下拉刷新
    
    //2 上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
    
    // 设置文字(也可以不设置,默认的文字在MJRefreshConst中修改)
    self.tableView.headerPullToRefreshText = @"下拉可以刷新了";
    self.tableView.headerReleaseToRefreshText = @"松开马上刷新了";
    self.tableView.headerRefreshingText = @"刷新中";
    
    self.tableView.footerPullToRefreshText = @"上拉可以加载更多数据了";
    self.tableView.footerReleaseToRefreshText = @"松开马上加载更多数据了";
    self.tableView.footerRefreshingText = @"加载中";
}

- (void)headerRereshing
{
    
    // 1.添加数据
    [self updateTx];

}

- (void)footerRereshing
{
    
    //添加数据
    [self history];
    
//    // 2.0秒后刷新表格UI
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        // 刷新表格
//        [self.tableView reloadData];
//        
//        // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
//        [self.tableView footerEndRefreshing];
//    });
}


#pragma mark - FSDropDown datasource & delegate

- (NSInteger)menu:(FSDropDownMenu *)menu tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == menu.rightTableView) {
        return cataArr.count;
    }else{
        return currentAreaArr.count;
    }
}
- (NSString *)menu:(FSDropDownMenu *)menu tableView:(UITableView*)tableView titleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == menu.rightTableView) {
        return cataArr[indexPath.row];
    }else{
        return currentAreaArr[indexPath.row];
    }
}


- (void)menu:(FSDropDownMenu *)menu tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView == menu.rightTableView){
        indexNum=indexPath.row;
        self.currentAreaArr = self.paymentArr[indexPath.row];
        [menu.leftTableView reloadData];
    }else{
        
        if (indexNum == 0)
        {
//            NSLog(@"%@",self.currentAreaArr[indexPath.row]);
            NSString *title = currentAreaArr[indexPath.row];
            [self updateSelectTx:title andSqlite:@"historytype"];
        }
        else if (indexNum == 1)
        {
            NSString *title = [NSString  string];
            if ([currentAreaArr[indexPath.row] isEqualToString:@"发送"])
            {
                title=@"0000";
            }
            else if ([currentAreaArr[indexPath.row] isEqualToString:@"接收"])
            {
                title=@"1111";
            }
            [self updateSelectTx:title andSqlite:@"historykey"];
        }
        
    }
    
}


#pragma mark - UITableViewDataSource delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor whiteColor]];
    [cell setSelectedBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell70.png"]]];
}


//段标题
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *tmpStr=[[sectionArr objectAtIndex:section] substringWithRange:NSMakeRange(4, 2)];
    NSString *sectionStr=[NSString stringWithFormat:@"%@月",tmpStr];
    return sectionStr;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [sectionArr count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[historyAllDict objectForKey:[sectionArr objectAtIndex:section]] count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *list = [historyAllDict objectForKey:[sectionArr objectAtIndex:indexPath.section]];
    hashTmp=[list[indexPath.row] objectForKey:@"hash"];
    [self performSegueWithIdentifier:@"detail" sender:nil];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"historyCell";
    HistoryTableViewCell *cell = (HistoryTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSArray *list = [historyAllDict objectForKey:[sectionArr objectAtIndex:indexPath.section]];
    if ([[list[indexPath.row] objectForKey:@"type"] isEqualToString:@"send"] || [[list[indexPath.row] objectForKey:@"type"] isEqualToString:@"shopsend"])
    {
        cell.mPriceLabel.textColor=RGBA(54, 189, 237, 1);
    }
    else if ([[list[indexPath.row] objectForKey:@"type"] isEqualToString:@"receive"] || [[list[indexPath.row] objectForKey:@"type"] isEqualToString:@"shopreceive"] || [[list[indexPath.row] objectForKey:@"type"] isEqualToString:@"shopbuy"])
    {
        cell.mPriceLabel.textColor=RGBA(240, 79, 117, 1);
    }
    cell.mImageView.image=[UIImage imageNamed:[list[indexPath.row] objectForKey:@"image"]];
    cell.mDetailLabel.text=[list[indexPath.row] objectForKey:@"message"];
    cell.mTimeLabel.text=[list[indexPath.row] objectForKey:@"time"];
    cell.mPriceLabel.text=[list[indexPath.row] objectForKey:@"price"];
    cell.mPaymentLabel.text=[list[indexPath.row] objectForKey:@"result"];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


#pragma mark -- notifition

//删除自身的观察者身份
- (void)notificationUserLoggedOut:(NSNotification *) notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateHistoryTx:(NSNotification *) notification
{
    NSString *result=(NSString *)[notification object];
    if ([result isEqualToString:@"0"])
    {
        self.tableView.footerRefreshingText = @"没有更多数据了!";
        [self.tableView headerEndRefreshing];
        [self.tableView footerEndRefreshing];
    }
    else if ([result isEqualToString:@"1"])
    {
        [self updateTx];
    }

}

- (void)notificationHistoryChange:(NSNotification *) notification
{
    [self updateTx];
}

- (void)history
{

    [[JingtumJSManager shared] wrapperMoreAccountTx];
}



- (IBAction)allBtn:(id)sender
{
    self.allButton.backgroundColor=RGBA(102, 153, 255, 1);
    [self.allButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.selectButton.backgroundColor=[UIColor whiteColor];
    [self.selectButton setTitleColor:RGBA(102, 153, 255, 1) forState:UIControlStateNormal];
    
    FSDropDownMenu *menu = (FSDropDownMenu*)[self.view viewWithTag:1001];
    [menu removeMenu];
    
    [self updateTx];
}

- (IBAction)selectBtn:(id)sender
{
    self.selectButton.backgroundColor=RGBA(102, 153, 255, 1);
    [self.selectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.allButton.backgroundColor=[UIColor whiteColor];
    [self.allButton setTitleColor:RGBA(102, 153, 255, 1) forState:UIControlStateNormal];
    
    FSDropDownMenu *menu = (FSDropDownMenu*)[self.view viewWithTag:1001];
    [UIView animateWithDuration:0.2 animations:^{
        
    } completion:^(BOOL finished) {
        [menu menuTapped];
    }];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"detail"])
    {
        HistoryDetailViewController * view = [segue destinationViewController];
        view.hidesBottomBarWhenPushed=YES;
        view.hashStr=hashTmp;
        
    }
}



@end
