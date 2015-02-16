//
//  ShopViewController.m
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "ShopViewController.h"
#import "shopDetailViewController.h"
#import "ShoperTableViewCell.h"
#import "MJRefresh.h"
#import "JingtumJSManager.h"
#import "JingtumJSManager+SendTransaction.h"
#import "JingtumJSManager+NetworkStatus.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"

@interface ShopViewController ()
{
    NSString *tmpName,*tmpDetail,*tmpPrice,*tmpSend,*tmpData,*tmpInfo,*tmpAddress,*tmpPhone,*tmpCurrency,*tmpNiufuCurrencyName,*tmpUsersure,*tmpShopName;
    NSArray *tmpImage;
    NSMutableArray *shopNameList;
    NSMutableArray *nameList;
    NSMutableArray *dateList;
    NSMutableArray *shopInfoList;
    NSMutableArray *shopDetailList;
    NSMutableArray *shopUseDetailList;
    NSMutableArray *priceList;
    NSMutableArray *numList;
    NSMutableArray *imageList;
    NSMutableArray *otherImageList;
    NSMutableArray *addressList;
    NSMutableArray *phoneList;
    NSMutableArray *currencyList;
    NSMutableArray *niufuCurrencyNameList;
    UIView *_navView;//自定义navgation
    UISearchDisplayController *searchController;//搜索的控制器
    NSMutableArray *filterNames;//搜索的结果
    NSDateFormatter* formatter;//时间
}
@end

static int pageNum;
@implementation ShopViewController

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
    
    
//    [self.navigationController setToolbarHidden:YES];
//    [self.navigationController setNavigationBarHidden:YES];
    
    //tabbar图标
#ifdef IOS7_SDK_AVAILABLE
    _walletItem.image = [[UIImage imageNamed:@"ticketOff.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _walletItem.selectedImage  = [[UIImage imageNamed:@"ticketon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
#endif
    
    [self setupRefresh];
    //时间戳转时间的方法
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];

    
    //设置自定义navgation
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
    [titleLabel setText:@"用户通"];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [_navView addSubview:titleLabel];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(_navView.frame.size.width-41, (_navView.frame.size.height - 20)/2, 40, 20)];
    [button setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateNormal];
    [button setTintColor:[UIColor whiteColor]];
    [button setBackgroundColor:[UIColor clearColor]];
    button.titleLabel.font=[UIFont systemFontOfSize:13];
//    [button addTarget:self action:@selector(searchButton) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:button];
     
     
    //去除tableview的分割线
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    pageNum=1;
    
}

- (void)searchButton
{
    //创建搜索框
    UISearchBar *searchBar=[[UISearchBar alloc] initWithFrame:CGRectMake(0, 64, 320, 44)];
    [self.view addSubview:searchBar];
    
    //searchController 包含了TableView
    searchController=[[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchController.delegate=self;
    searchController.searchResultsDelegate=self;
    searchController.searchResultsDataSource=self;
    
    filterNames=[NSMutableArray array];

}

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
       shopNameList=[[NSMutableArray alloc] init];
       nameList=[[NSMutableArray alloc] init];
       dateList=[[NSMutableArray alloc] init];
       shopInfoList=[[NSMutableArray alloc] init];
       shopDetailList=[[NSMutableArray alloc] init];
       shopUseDetailList=[[NSMutableArray alloc] init];
       priceList=[[NSMutableArray alloc] init];
       numList=[[NSMutableArray alloc] init];
       imageList=[[NSMutableArray alloc] init];
       otherImageList=[[NSMutableArray alloc] init];
       addressList=[[NSMutableArray alloc] init];
       phoneList=[[NSMutableArray alloc] init];
       currencyList=[[NSMutableArray alloc] init];
       niufuCurrencyNameList=[[NSMutableArray alloc] init];

       NSString *urlStr=[NSString stringWithFormat:@"%@/getBonds?type=100&currentPage=1&totalItems=10",JINGTUM_SHOP];
       NSLog(@"urlStr-->%@",urlStr);
       [self afnetWork:urlStr];
    
}


- (void)afnetWork:(NSString *)urlTemp
{
    
    [[JingtumJSManager shared] operationManagerGET:urlTemp parameters:nil withBlock:^(NSString *error, id responseData) {
        if ([error isEqualToString:@"0"])
        {
            NSLog(@"获取用户通返回数据->%@",responseData);
            if ( [[responseData objectForKey:@"data"] count]>0 && ![[responseData[@"data"] objectForKey:@"data"] isEqual:[NSNull null]])
            {
                for (NSDictionary *dict in [responseData[@"data"] objectForKey:@"data"])
                {
                    
                    //保存date时间
                    NSString *confromTimespStr;
                    if (dict[@"projectPeriod"] && ![dict[@"projectPeriod"] isEqual:@"<null>"] && ![dict[@"projectPeriod"] isEqual:[NSNull null]])
                    {
                        NSInteger timeNum=[dict[@"projectPeriod"] integerValue];
                        NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timeNum];
                        confromTimespStr = [formatter stringFromDate:confromTimesp];
                        //                NSLog(@"时间--》%@",confromTimespStr);
                    }
                    else
                    {
                        confromTimespStr=@"空";
                    }
                    
                    [shopNameList addObject:dict[@"guaranteeCompanycontext"]];
                    [nameList addObject:dict[@"name"]];
                    [dateList addObject:confromTimespStr];
                    [shopInfoList addObject:dict[@"info"]];
                    [shopDetailList addObject:dict[@"subjectAnalyze"]];
                    [shopUseDetailList addObject:dict[@"subjectInfo"]];
                    
                    //保存价格
                    if (dict[@"value"] && ![dict[@"value"] isEqual:@"<null>"] && ![dict[@"value"] isEqual:[NSNull null]]  )
                    {
                        [priceList addObject:[dict[@"value"] stringValue]];
                    }
                    else
                    {
                        [priceList addObject:@"空"];
                    }
                    
                    //保存数量
                    if (dict[@"amount"] && ![dict[@"amount"] isEqual:@"<null>"] && ![dict[@"amount"] isEqual:[NSNull null]]  )
                    {
                        [numList addObject:[dict[@"amount"] stringValue]];
                    }
                    else
                    {
                        [numList addObject:@"空"];
                    }
                    [addressList addObject:dict[@"guaranteeCompany"]];
                    [phoneList addObject:dict[@"guarantee"]];
                    [currencyList addObject:dict[@"ID"]];
                    [niufuCurrencyNameList addObject:dict[@"currency"]];
                    
                    //保存照片
                    //            NSLog(@"photo->%@",dict[@"photo"]);
                    if (dict[@"photo"] && ![dict[@"photo"] isEqual:@"<null>"] && ![dict[@"photo"] isEqual:[NSNull null]] && ![dict[@"photo"] isEqual:@"[]"])
                    {
                        NSData *data=[dict[@"photo"] dataUsingEncoding:NSUTF8StringEncoding];
                        NSArray *jsonArr=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                        NSMutableArray *imageArr=[[NSMutableArray alloc] init];
                        for (NSDictionary *dictTmp in jsonArr)
                        {
                            NSString *imageStr=[NSString stringWithFormat:@"%@/%@r",JINGTUM_SHOP_PHOTO,dictTmp[@"name"]];
                            [imageArr addObject:imageStr];
                        }
                        [imageList addObject:imageArr];
                    }else
                    {
                        NSMutableArray *imageArr=[[NSMutableArray alloc] init];
                        NSString *imageStr=[NSString stringWithFormat:@"null"];
                        [imageArr addObject:imageStr];
                        [imageList addObject:imageArr];
                    }
                    
                    //保存login图片
                    if (dict[@"other"] && ![dict[@"other"] isEqual:@"<null>"] && ![dict[@"other"] isEqual:[NSNull null]] && ![dict[@"other"] isEqual:@"[]"])
                    {
                        NSData *data=[dict[@"other"] dataUsingEncoding:NSUTF8StringEncoding];
                        NSArray *jsonArr=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                        NSMutableArray *imageArr=[[NSMutableArray alloc] init];
                        for (NSDictionary *dictTmp in jsonArr)
                        {
                            NSString *imageStr=[NSString stringWithFormat:@"%@/%@r",JINGTUM_SHOP_OTHERPHOTO,dictTmp[@"name"]];
                            [imageArr addObject:imageStr];
                        }
                        [otherImageList addObject:imageArr];
                    }else
                    {
                        NSMutableArray *imageArr=[[NSMutableArray alloc] init];
                        NSString *imageStr=[NSString stringWithFormat:@"null"];
                        [imageArr addObject:imageStr];
                        [otherImageList addObject:imageArr];
                    }
                    
                    
                }
                //        NSLog(@"imageList->%@ otherImageList->%@",imageList,otherImageList);
                [self.tableView reloadData];
                [self.tableView headerEndRefreshing];
                [self.tableView footerEndRefreshing];
            }
            else
            {
                self.tableView.footerRefreshingText = @"没有更多数据了,亲!";
                [self.tableView reloadData];
                [self.tableView headerEndRefreshing];
                [self.tableView footerEndRefreshing];
            }

        }
        else
        {
            NSLog(@"获取用户通请求失败");
            [self.tableView headerEndRefreshing];
            [self.tableView footerEndRefreshing];
        }
        
    }];
}

- (void)footerRereshing
{
    pageNum+=1;
    //创建一个异步线程加载数据
    dispatch_async(dispatch_get_global_queue(0, 0),
                   ^{
                       
                       NSString *urlStr=[NSString stringWithFormat:@"%@/getBonds?type=100&currentPage=%d&totalItems=10",JINGTUM_SHOP,pageNum];
                       NSLog(@"urlStr-->%@",urlStr);
                       [self afnetWork:urlStr];
                       
                   });

}


#pragma mark - TableViewDataSource Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView.tag == 1)
    {
        return nameList.count;
    }
    
    return  1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 1)
    {
        return 1;
    }
    
    return filterNames.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (tableView.tag == 1)
    {
        static NSString *CellWithIdentifier = @"ShoperCell";
        ShoperTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
        if ([otherImageList[indexPath.section] count]==1 && [otherImageList[indexPath.section][0] isEqual:@"null"])
        {
            cell.imageView.image=[UIImage imageNamed:@"58X58(2).png"];
        }
        else
        {
            [cell.imgView setImageWithURL:[NSURL URLWithString:otherImageList[indexPath.section][0]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        }
        cell.detailLabel.text=nameList[indexPath.section];
        cell.priceLabel.text=priceList[indexPath.section];
        cell.sendLabel.text=numList[indexPath.section];
        cell.mNameLabel.text=shopNameList[indexPath.section];
        cell.mDataLabel.text=dateList[indexPath.section];
        
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor whiteColor]];
    [cell setSelectedBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell70.png"]]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    tmpName=nameList[indexPath.section];
    tmpShopName=shopNameList[indexPath.section];
    tmpInfo=shopInfoList[indexPath.section];
    tmpDetail=shopDetailList[indexPath.section];
    tmpUsersure=shopUseDetailList[indexPath.section];
    tmpPrice=priceList[indexPath.section];
    tmpSend=numList[indexPath.section];
    tmpData=dateList[indexPath.section];
    tmpAddress=addressList[indexPath.section];
    tmpImage=imageList[indexPath.section];
    tmpPhone=phoneList[indexPath.section];
    tmpCurrency=currencyList[indexPath.section];
    tmpNiufuCurrencyName=niufuCurrencyNameList[indexPath.section];
    
    [self performSegueWithIdentifier:@"detail" sender:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

#pragma mark - UISearchDisplayDelegate
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
        NSArray *matches=[nameList filteredArrayUsingPredicate:pre];
        [filterNames addObjectsFromArray:matches];
        
    }
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"detail"]) {
        shopDetailViewController * view = [segue destinationViewController];
        
        view.hidesBottomBarWhenPushed=YES;
        view.infoName=tmpInfo;
        view.tempName=tmpName;
        view.shopName=tmpShopName;
        view.detalieName=tmpDetail;
        view.useSureName=tmpUsersure;
        view.priceName=tmpPrice;
        view.sendName=tmpSend;
        view.dataName=tmpData;
        view.addressName=tmpAddress;
        view.imageName=tmpImage;
        view.phoneName=tmpPhone;
        view.currencyTypeName=tmpCurrency;
        view.niufuCurrencyName=tmpNiufuCurrencyName;
    }
}


@end
