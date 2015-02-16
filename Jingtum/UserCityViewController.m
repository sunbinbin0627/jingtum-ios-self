//
//  UserCityViewController.m
//  Jingtum
//
//  Created by sunbinbin on 15-1-23.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "UserCityViewController.h"
#import "UserAddBankViewController.h"
#import "AppDelegate.h"

@interface UserCityViewController ()
{
    UIView *_navView;
    UISearchDisplayController *searchController;//搜索的控制器
    NSMutableArray *filterNames;//搜索的结果
    NSDictionary *cityCodeDict;
}
@end

@implementation UserCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [AppDelegate  storyBoradAutoLay:self.view];
    
    self.arrayHotCity = [NSMutableArray arrayWithObjects:@"广州市  440000-440100",@"北京  110000-110000",@"天津市  120000-120000",@"西安市  610000-610100",@"沈阳市  210000-210100",@"青岛市  370000-370200",@"济南市  370000-370100",@"深圳市  440000-440300",@"无锡市  320000-320200", nil];
    self.keys = [NSMutableArray array];
    self.arrayCitys = [NSMutableArray array];

    [self getCityData];
    
    
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
    [titleLabel setText:@"选择城市"];
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

#pragma mark - 获取城市数据
-(void)getCityData
{
    NSString *path=[[NSBundle mainBundle] pathForResource:@"city"
                                                   ofType:@"plist"];
    self.cities = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    
    [self.keys addObjectsFromArray:[[self.cities allKeys] sortedArrayUsingSelector:@selector(compare:)]];
    
    //添加热门城市
    NSString *strHot = @"热";
    [self.keys insertObject:strHot atIndex:0];
    [self.cities setObject:_arrayHotCity forKey:strHot];
}

#pragma mark - tableView


//段标题
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == 1)
    {
        NSString *key = [_keys objectAtIndex:section];
        if ([key rangeOfString:@"热"].location != NSNotFound) {
            return  @"热门城市";
        }
        else
            return key;
    }
    else
        return nil;
   
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView.tag == 1)
    {
        return _keys;
    }
    else
        return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (tableView.tag == 1)
    {
        return [_keys count];
    }
    else
        return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView.tag == 1)
    {
        NSString *key = [_keys objectAtIndex:section];
        NSArray *citySection = [_cities objectForKey:key];
        return [citySection count];
    }
    else
        return filterNames.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    NSString *key = [_keys objectAtIndex:indexPath.section];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textLabel.textColor=RGBA(109, 109, 109, 1);
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }
    cell.textLabel.textColor=RGBA(109, 109, 109, 1);
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    if (tableView.tag == 1)
    {
        NSArray *array=[[[_cities objectForKey:key] objectAtIndex:indexPath.row] componentsSeparatedByString:@"  "];
        cell.textLabel.text = [array objectAtIndex:0];
    }
    else
    {
         NSArray *array=[filterNames[indexPath.row] componentsSeparatedByString:@"  "];
        cell.textLabel.text=[array objectAtIndex:0];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 1)
    {
        NSString *key = [_keys objectAtIndex:indexPath.section];
        
        NSArray *array=[[[_cities objectForKey:key] objectAtIndex:indexPath.row] componentsSeparatedByString:@"  "];
        NSArray *cityArray=[[array objectAtIndex:1] componentsSeparatedByString:@"-"];
        
        self.addVC.cityName=[array objectAtIndex:0];
        self.addVC.provinceCode=[cityArray objectAtIndex:0];
        self.addVC.cityCode=[cityArray objectAtIndex:1];
    }
    else
    {
        NSArray *array=[filterNames[indexPath.row] componentsSeparatedByString:@"  "];
        NSArray *cityArray=[[array objectAtIndex:1] componentsSeparatedByString:@"-"];
        
        self.addVC.cityName=[array objectAtIndex:0];
        self.addVC.provinceCode=[cityArray objectAtIndex:0];
        self.addVC.cityCode=[cityArray objectAtIndex:1];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - 搜索 delegate
- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cityCell"];
    
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
        
        NSMutableArray *cityArr=[[NSMutableArray alloc] init];
        NSArray *keys=[self.cities allKeys];
        for (NSString *key in keys)
        {
            for (NSString *tmp in [self.cities objectForKey:key])
            {
                [cityArr addObject:tmp];
            }
        }
        //用谓词过滤
        NSArray *matches=[cityArr filteredArrayUsingPredicate:pre];
        [filterNames addObjectsFromArray:matches];
        
    }
    return YES;
}



@end
