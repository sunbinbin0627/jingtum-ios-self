//
//  shopDetailViewController.m
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "shopDetailViewController.h"
#import "ShopSendViewController.h"
#import "UIImageView+WebCache.h"
#import "JingtumJSManager+SendTransaction.h"
#import "SVProgressHUD.h"
#import "ShopInfoViewController.h"
#import "ShopUseSureViewController.h"
#import "AppDelegate.h"

@interface shopDetailViewController ()
{
    UIView *_navView;
    UIPageControl *pageController;
}
@end

@implementation shopDetailViewController

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
    
//    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 , 100, 44)];
//    titleLabel.backgroundColor = [UIColor clearColor];  //设置Label背景透明
//    titleLabel.font = [UIFont boldSystemFontOfSize:17];  //设置文本字体与大小
//    titleLabel.textColor = [UIColor whiteColor]; //设置文本颜色
//    titleLabel.textAlignment = NSTextAlignmentCenter;
//    titleLabel.text = @"商品详情";  //设置标题
//    
//    self.navigationItem.titleView=titleLabel;
//    [self.navigationController setNavigationBarHidden:NO];
    
    
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
    [titleLabel setText:@"商品详情"];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [_navView addSubview:titleLabel];
    
    UIButton *shopButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 2+NavViewHeigth/2, 70, 40)];
    [shopButton setTitle:@"用户通" forState:UIControlStateNormal];
    [shopButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [shopButton setTintColor:[UIColor whiteColor]];
    [shopButton setBackgroundColor:[UIColor clearColor]];
    shopButton.titleLabel.font=[UIFont systemFontOfSize:13];
    [shopButton addTarget:self action:@selector(backtoGround) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:shopButton];
    
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(11, (_navView.frame.size.height - 20)/2+5, 7, 10)];
    imageView.image=[UIImage imageNamed:@"title-left.png"];
    [_navView addSubview:imageView];
    
    UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(_navView.frame.size.width-41, (_navView.frame.size.height - 20)/2, 40, 20)];
    [searchButton setImage:[UIImage imageNamed:@"share.png"] forState:UIControlStateNormal];
    [searchButton setTintColor:[UIColor whiteColor]];
    [searchButton setBackgroundColor:[UIColor clearColor]];
    searchButton.titleLabel.font=[UIFont systemFontOfSize:13];
//    [searchButton addTarget:self action:@selector(shareButton) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:searchButton];
     
    //设置scrollview
    NSInteger num=self.imageName.count;
    self.mScrollView.contentSize=CGSizeMake1(320*num, 196);
    [self.mScrollView setBounces:NO];
    [self.mScrollView setShowsHorizontalScrollIndicator:NO];
    [self.mScrollView setPagingEnabled:YES];

    for (int i=0; i<num; i++)
    {
        UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake1(320*i, 0, 320, 196)];
        [imageView setImageWithURL:[NSURL URLWithString:self.imageName[i]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        [self.mScrollView addSubview:imageView];
    }
    
    //添加pageControl
    pageController=[[UIPageControl alloc] initWithFrame:CGRectMake(80, self.mScrollView.bounds.size.height+30, self.view.bounds.size.width-160, 20)];
    [pageController setBackgroundColor:[UIColor clearColor]];
    pageController.currentPage=0;
    pageController.numberOfPages=num;
    [self.view addSubview:pageController];
    
    
    self.mNameLabel.text=self.tempName;
    self.infoLabel.text=self.infoName;
    self.priceLabel.text=self.priceName;
    self.sendLabel.text=self.sendName;
    self.mNameLabel2.text=self.shopName;
    self.mDataLabel.text=self.dataName;
    self.addressLabel.text=self.addressName;
    
//    NSLog(@"currencyTypeName->%@",self.currencyTypeName);
//    NSLog(@"sendname-->%@",self.sendName);
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self book_offers];

}

- (void)book_offers
{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
    [dict setObject:self.currencyTypeName forKey:@"gets"];
    [dict setObject:@"CNY" forKey:@"pays"];
    
    [[JingtumJSManager shared] book_offers:dict withBlock:^(id responseData) {
        NSLog(@"responseData->%@",responseData);
        if ([[responseData objectForKey:@"offers"] count] > 0)
        {
            NSDictionary *offerDict=[[responseData objectForKey:@"offers"] objectAtIndex:0];
            if ([offerDict objectForKey:@"taker_gets_funded"])
            {
                NSString *str=[offerDict objectForKey:@"taker_gets_funded"];
                NSString *numstr=[NSString stringWithFormat:@"%.f",[str floatValue]*0.000001];
                NSString *sendStr=[NSString stringWithFormat:@"%lld",[numstr longLongValue]];
                self.sendLabel.text=sendStr;
            }
            else
            {
                NSDictionary *takeGetDict=[offerDict objectForKey:@"TakerGets"];
                NSString *numStr=[NSString stringWithFormat:@"%lld",[[takeGetDict objectForKey:@"value"] longLongValue]];
                self.sendLabel.text=numStr;
            }
        }
        else
        {
            self.sendLabel.text=@"0";
            [self.mBuyButton setTitle:@"已售罄" forState:UIControlStateNormal];
            [self.mBuyButton setBackgroundColor:[UIColor grayColor]];
            self.mBuyButton.enabled=NO;
        }
        
    }];
    
}


- (void)backtoGround
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
{
    if ([scrollView isMemberOfClass:[UIScrollView class]])
    {
        int index= scrollView.contentOffset.x/320;
        [pageController setCurrentPage:index];
        
    }
    
}

- (IBAction)mBuyBtn:(id)sender
{
    NSDictionary *tmpdict=[USERDEFAULTS objectForKey:USERDEFAULTS_JINGTUM_SHOPCARD];
    NSArray *keys=[tmpdict allKeys];
    BOOL isexit=NO;
    for (NSString *key in keys)
    {
        if ([key isEqualToString:self.currencyTypeName])
        {
            isexit=YES;
            [self performSegueWithIdentifier:@"Next" sender:nil];
            
        }
    }
    if (!isexit)
    {
        [SVProgressHUD showWithStatus:@"加载中..." maskType:SVProgressHUDMaskTypeGradient];
        [self setTrust:self.currencyTypeName];
    }
    
}

- (IBAction)mAddressBtn:(id)sender
{
    
}

- (IBAction)mPhoneBtn:(id)sender
{
    
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:self.phoneName delegate:self cancelButtonTitle:@"呼叫" otherButtonTitles:@"取消", nil];
    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        //跳转到拨打电话
        NSString *phoneStr=[NSString stringWithFormat:@"tel://%@",self.phoneName];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneStr]];
    }
}

- (IBAction)mUsersureBtn:(id)sender
{
    [self performSegueWithIdentifier:@"detail" sender:nil];
}

- (IBAction)mInfoBtn:(id)sender
{
    [self performSegueWithIdentifier:@"info" sender:nil];
}

- (void)setTrust:(NSString *)currency
{
    NSString *amountStr=[NSString stringWithFormat:@"%lld",[self.sendName longLongValue]+1];
    RPTrsut *rpTrust=[RPTrsut new];
    rpTrust.currency=currency;
    rpTrust.amount=amountStr;
    rpTrust.allowrippling=@0;
    
    [[JingtumJSManager shared] setTrust:rpTrust withBlock:^(NSError *error) {
        if (!error)
        {
            [SVProgressHUD dismiss];
            NSDictionary *dict=[USERDEFAULTS objectForKey:USERDEFAULTS_JINGTUM_SHOPCARD];
            NSMutableDictionary *tmpdict1=[NSMutableDictionary dictionaryWithDictionary:dict];
            [tmpdict1 setObject:@"0" forKey:self.currencyTypeName];
            [USERDEFAULTS setObject:tmpdict1 forKey:USERDEFAULTS_JINGTUM_SHOPCARD];
            NSLog(@"信任成功");
            [self performSegueWithIdentifier:@"Next" sender:nil];
        }
        else
        {
            [SVProgressHUD dismiss];
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"加载失败,请重试。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            NSLog(@"信任失败");
        }
    }];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Next"]) {
        ShopSendViewController * view = [segue destinationViewController];
        view.hidesBottomBarWhenPushed=YES;
        view.tempTitle=self.infoLabel.text;
        view.tempPrice=self.priceLabel.text;
        view.tempCurrency=self.currencyTypeName;
        view.tempNiufuCurrency=self.niufuCurrencyName;
        view.tempName=self.mNameLabel.text;
    }
    else if ([segue.identifier isEqualToString:@"info"])
    {
        ShopInfoViewController *view = [segue destinationViewController];
         view.hidesBottomBarWhenPushed=YES;
        view.tmpInfo=self.detalieName;
        
    }
    else if ([segue.identifier isEqualToString:@"detail"])
    {
        ShopUseSureViewController *view = [segue destinationViewController];
        view.hidesBottomBarWhenPushed=YES;
        view.tmpUsersure=self.useSureName;
    }
    
}

CG_INLINE CGRect//注意：这里的代码要放在.m文件最下面的位置
CGRectMake1(CGFloat x, CGFloat y, CGFloat width, CGFloat height)
{
    AppDelegate *myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CGRect rect;
    rect.origin.x = x * myDelegate.autoSizeScaleX; rect.origin.y = y * myDelegate.autoSizeScaleY;
    rect.size.width = width * myDelegate.autoSizeScaleX; rect.size.height = height * myDelegate.autoSizeScaleY;
    return rect;
}


CG_INLINE CGSize//注意：这里的代码要放在.m文件最下面的位置
CGSizeMake1(CGFloat width, CGFloat height)
{
    AppDelegate *myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CGSize rect;
    rect.width = width * myDelegate.autoSizeScaleX; rect.height = height * myDelegate.autoSizeScaleY;
    return rect;
}


@end
