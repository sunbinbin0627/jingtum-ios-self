//
//  UserBankViewController.m
//  Jingtum
//
//  Created by sunbinbin on 15-1-22.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "UserBankViewController.h"
#import "UserAddBankViewController.h"
#import "AppDelegate.h"

@interface UserBankViewController ()
{
    UIView *_navView;
    NSArray *bankNameList;
    NSArray *bankCodeList;
    UISearchDisplayController *searchController;//搜索的控制器
    NSMutableArray *filterNames;//搜索的结果
}
@end

@implementation UserBankViewController

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
    [titleLabel setText:@"选择银行"];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [_navView addSubview:titleLabel];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 2+NavViewHeigth/2, 70, 40)];
    [backButton setTitle:@"取 消" forState:UIControlStateNormal];
    [backButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [backButton setTintColor:[UIColor whiteColor]];
    [backButton setBackgroundColor:[UIColor clearColor]];
    backButton.titleLabel.font=[UIFont systemFontOfSize:13];
    [backButton addTarget:self action:@selector(backtoGround) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:backButton];
    
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(11, (_navView.frame.size.height - 20)/2+5, 7, 10)];
    imageView.image=[UIImage imageNamed:@"title-left.png"];
    [_navView addSubview:imageView];
    
    bankNameList=@[@"工商银行",@"光大银行",@"江苏银行",@"建设银行",@"交通银行",@"农业银行",@"中国银行",@"上海浦发展银行"];
    bankCodeList=@[@"ICBC",@"CEB",@"JSBCHINA",@"CCB",@"BOCO",@"ABC",@"BOC",@"SPDB"];
    
    self.tableView.tableFooterView=[[UIView alloc] init];
    
    
    //searchController 包含了TableView
    searchController=[[UISearchDisplayController alloc] initWithSearchBar:self.mSearchBarView contentsController:self];
    searchController.delegate=self;
    searchController.searchResultsDelegate=self;
    searchController.searchResultsDataSource=self;
    
    filterNames=[[NSMutableArray alloc] init];
}

- (void)backtoGround
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 1)
    {
        return bankNameList.count;
    }
    else
        return filterNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.textColor=RGBA(109, 109, 109, 1);
    cell.textLabel.font=[UIFont fontWithName:@"Helvetica" size:14.0];
    if (tableView.tag == 1)
    {
        cell.textLabel.text=bankNameList[indexPath.row];
    }
    else
    {
        cell.textLabel.text=filterNames[indexPath.row];
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 1)
    {
        self.addVC.bankName=bankNameList[indexPath.row];
        self.addVC.bankCode=bankCodeList[indexPath.row];
//        NSLog(@"bankName->%@",self.addVC.bankName);
    }
    else
    {
        self.addVC.bankName=filterNames[indexPath.row];
//        self.addVC.bankCode=bankCodeList[indexPath.row];
    }
   
    [self.navigationController popViewControllerAnimated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - 搜索 delegate
- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
}


//一旦searchBar输入内容有变化，则执行这个方法，并询问是否要重新load搜索结果的TableView
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    //将搜索框里的内容清空
    [filterNames removeAllObjects];
    if (searchString.length>0)
    {
        //定义谓词
        NSPredicate *pre=[NSPredicate predicateWithFormat:@"SELF CONTAINS %@",searchString];
        
        //用谓词过滤
        NSArray *matches=[bankNameList filteredArrayUsingPredicate:pre];
        [filterNames addObjectsFromArray:matches];
        
    }
    return YES;
}




@end
