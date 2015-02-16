//
//  AllViewController.m
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "AllViewController.h"
#import "JingtumJSManager.h"
#import "JingtumJSManager+SendTransaction.h"
#import "JingtumJSManager+PaySecret.h"
#import "JingtumJSManager+NetworkStatus.h"
#import "ZBarSDK.h"
#import "QRCodeGenerator.h"
#import "SCLAlertView.h"
#import "AppDelegate.h"
#import "CredTableViewCell.h"
#import "FirstTableViewCell.h"
#import "SecondTableViewCell.h"
#import "SVProgressHUD.h"
#import "ReceiveViewController.h"
#import "HistoryViewController.h"
#import "CardInfoViewController.h"
#import "UIImageView+WebCache.h"
#import <sqlite3.h>
#import "UserDB.h"
#import "RPWallet.h"
#import "RPShop.h"
#import "RPShopcard.h"

@interface AllViewController ()
{
    UITextField *textFiled1;
    UITextField *textFiled2;
    NSString *addressStr;
    
    ZBarReaderController *cameraReader;//相册获取二维码
    ZBarReaderViewController *myReader;//相机扫描二维码
    UIAlertView *alertCamera;//扫描相册二维码无效时弹出框
    UIImageView* line;//二维码扫描线
    NSTimer* lineTimer;//二维码扫描线计时器。
    BOOL segement;//选择是法币还是卡包
    BOOL camera;//判断actionsheet是在当前那个页面显示
    
    UIView *_navView;//自定义导航栏
    
    NSMutableArray *contractArr;
    
    //用户通
    NSString *tmpCurrency;
    NSArray *tmpImage,*tmpPhotoImage;
    NSMutableArray *nameList;
    NSMutableArray *dateList;
    NSMutableArray *cardNumList;
    NSMutableArray *otherimgList;
    NSMutableArray *currencyList;
    
    NSMutableArray *filterNames;//搜索的结果
    NSDateFormatter *formatter;//时间
    
    sqlite3 *db;//sqlite 数据库对象
    
    NSMutableArray *allPayment;//所有余额
    NSMutableDictionary *colortestDict;//所有偏红颜色数值
    
    NSDictionary *yearDate;//所有月份对应的天数
    NSArray *cataArr;//币的种类
    NSMutableDictionary *allTesttxDict;//所有下拉菜单
    
    UIAlertView *verifyAlert;//支付密码
    UIAlertView *verifyFailAlert;
    UITextField *verifyFiled;
    
}

@end

@implementation AllViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [AppDelegate  storyBoradAutoLay:self.view];
    
    
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
    
    cataArr=@[@"SWT",@"CNY",@"USD"];
    
    allTesttxDict=[[NSMutableDictionary alloc] init];
    
    colortestDict=[[NSMutableDictionary alloc] init];
    
    nameList=[[NSMutableArray alloc] init];
    dateList=[[NSMutableArray alloc] init];
    otherimgList=[[NSMutableArray alloc] init];
    cardNumList=[[NSMutableArray alloc] init];
    currencyList=[[NSMutableArray alloc] init];
    
    //判断最后一次修改密码的时间是否超过一个月，如果是则提醒用户修改密码
    [self returnUploadTime];
    
    //判断用户是否是第一次登陆，如果是则提醒用户去实名认证激活账户
    AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appdelegate.firstLogin==1)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"请到设置页面去完善你的资料,激活您的账号" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil ];
        [alert show];
    }
    else if (appdelegate.firstLogin==0)
    {
        [SVProgressHUD showWithStatus:@"加载中..." maskType:SVProgressHUDMaskTypeGradient];
    }
    
    
    //设置tabbar的颜色背景
    [self.tabBarController.tabBar setSelectedImageTintColor:RGBA(54, 189, 237, 1)];
    [self.tabBarController.tabBar setBackgroundColor:[UIColor whiteColor]];
    
    //设置tabbar的图片的选中图片
#ifdef IOS7_SDK_AVAILABLE
    _wallettabitem.image = [[UIImage imageNamed:@"walletOff.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _wallettabitem.selectedImage  = [[UIImage imageNamed:@"walleton.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
#else
//    _wallettabitem.image = [[UIImage imageNamed:@"walletOff.png"] imageWithRenderingMode:UIImageResizingModeStretch];
//    _wallettabitem.selectedImage  = [[UIImage imageNamed:@"walleton.png"] imageWithRenderingMode:UIImageResizingModeStretch];
#endif
    
    //设置tableView的分割线
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.sectionFooterHeight=0;
    self.tableView.sectionHeaderHeight=0;
    self.tableView.tableFooterView=[[UIView alloc] init];
    
    self.mSegementView.backgroundColor=[UIColor whiteColor];
    
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
    
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(_navView.frame.size.width-54, (_navView.frame.size.height - 20)/2, 16, 19)];
    imageView.image=[UIImage imageNamed:@"history.png"];
    [_navView addSubview:imageView];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(_navView.frame.size.width-41, 2+NavViewHeigth/2, 40, 40)];
    [button setTitle:@"账单" forState:UIControlStateNormal];
    [button setTintColor:[UIColor whiteColor]];
    [button setBackgroundColor:[UIColor clearColor]];
    button.titleLabel.font=[UIFont systemFontOfSize:13];
    [button addTarget:self action:@selector(pushToHistory) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:button];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((_navView.frame.size.width - 200)/2, (_navView.frame.size.height - 40)/2, 200, 40)];
    [titleLabel setText:@"我的钱包"];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [_navView addSubview:titleLabel];
    
    
    self.isopen=NO;
    segement=NO;
    camera=NO;
    
    //时间戳转时间的方法
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    
    //subscribe
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationChange:) name:kNotificationAccountChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCardChange:) name:kNotificationCardInfoChange object:nil];
    
    //添加通知观察者
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBalances) name:kNotificationUpdatedBalance object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateShopCard:) name:kNotificationUpdatedShopCard object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateXialaList) name:kNotificationUpdatedBalanceList object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationUserLoggedOut:) name:kNotificationUserLoggedOut object:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      
        [SVProgressHUD dismiss];
    });
}

- (void)pushToHistory
{
    [self performSegueWithIdentifier:@"history" sender:nil];
}

- (void)cellContract
{
    contractArr=[NSMutableArray arrayWithArray:[[UserDB shareInstance] findContracts]];
}

//更新卡包里内容,只在登陆时调用，之后便走subscribe更新卡包余额
- (void)updateShopCard:(NSNotification *) notification
{
    NSArray *cardarray=(NSArray *)[notification object];
    NSLog(@"cardarray-->%@",cardarray);
    
    nameList=[[NSMutableArray alloc] init];
    dateList=[[NSMutableArray alloc] init];
    otherimgList=[[NSMutableArray alloc] init];
    cardNumList=[[NSMutableArray alloc] init];
    currencyList=[[NSMutableArray alloc] init];
    
    for (RPShopcard *rp in cardarray)
    {
//        NSLog(@"shopNum->%@",rp.shopNum);
        if (![rp.shopNum isEqualToString:@"0"])
        {
            [nameList addObject:rp.shopName];
            [dateList addObject:rp.shopDate];
            [otherimgList addObject:rp.shopPhoto];
            [cardNumList addObject:rp.shopNum];
            [currencyList addObject:rp.shopId];
        }
       
    }
    [self.tableView reloadData];
    
}

//更新下拉菜单,只在登陆时调用，之后便走subscribe更新
- (void)updateXialaList
{
    //获取下拉账单
    allTesttxDict=[NSMutableDictionary dictionaryWithDictionary:[USERDEFAULTS objectForKey:USERDEFAULTS_JINGTUM_XIALA]];
    
    [self.tableView reloadData];
}


//更新钱包各币种的余额
- (void)updateBalances
{
    allPayment=[[NSMutableArray alloc] init];
    NSArray *walletArr=[[UserDB shareInstance] findAllWallet];
    for (RPWallet *tmp in walletArr)
    {
        NSMutableDictionary *tmpDict=[[NSMutableDictionary alloc] init];
        [tmpDict setObject:tmp.type forKey:@"type"];
        [tmpDict setObject:tmp.num forKey:@"price"];
        [tmpDict setObject:tmp.image forKey:@"image"];
        [tmpDict setObject:tmp.title forKey:@"title"];
        [allPayment addObject:tmpDict];
    }
    [self.tableView reloadData];
    [SVProgressHUD dismiss];
    NSLog(@"allPaymentArr---》%@",allPayment);
}

#pragma mark - AlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == alertCamera)
    {
        if (buttonIndex == 0)
        {
             [cameraReader dismissViewControllerAnimated:YES completion:nil];
        }
       
    }
    else if (alertView == verifyAlert)
    {
        if (buttonIndex == 0)
        {
            [[JingtumJSManager shared] VerifyPaySecret:verifyFiled.text withBlock:^(id responseData) {
                
                NSLog(@"verify responseData%@",responseData);
                
                if ([responseData objectForKey:@"data"] && ![[responseData objectForKey:@"data"] isEqual:[NSNull null]] && [[responseData objectForKey:@"data"] isEqualToString:@"SUCCESS"])
                {
                    [self sendData];
                    
                }
                else
                {
                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"密码错误,请重新输入" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    verifyFailAlert=alert;
                    [alert show];
                    
                }
                
            }];
            
        }
        
    }
    else if (alertView == verifyFailAlert)
    {
        if (buttonIndex == 0)
        {
            verifyFiled.text=@"";
            [verifyAlert show];
        }
    }
    else
    {
        if (buttonIndex == 0)
        {
            self.tabBarController.selectedIndex=3;
        }
    }
}


#pragma mark - TextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:textFiled2])
    {
        [textFiled1 resignFirstResponder];
        UIActionSheet *actionsheet=[[UIActionSheet alloc] initWithTitle:@"选择币种" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"SWT" otherButtonTitles:@"CNY",@"USD", nil];
        if (camera == NO)
        {
            [actionsheet showInView:myReader.view];
        }
        else if (camera == YES)
        {
            [actionsheet showInView:cameraReader.view];
        }
        
    }
    return YES;
}

#pragma mark - actionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 3)
    {
         textFiled2.text=[actionSheet buttonTitleAtIndex:buttonIndex];
    }
}


//https://skywell.com//contract?to=jaP3onnUFeBVemhF3vKnHdeVkXjusxLHNb
#pragma  mark - zbar delegate
- (IBAction)sendBtn:(id)sender
{
    camera=NO;
    myReader=[ZBarReaderViewController  new];
    myReader.readerDelegate=self;
    myReader.wantsFullScreenLayout=NO;
    myReader.showsZBarControls=NO;
    [self setOverlayPickerView:myReader];
    myReader.supportedOrientationsMask=ZBarOrientationMaskAll;
    ZBarImageScanner *scanner=myReader.scanner;
    [scanner setSymbology:ZBAR_I25
                   config:ZBAR_CFG_ENABLE
                       to:0];
    
    [self presentViewController:myReader animated:YES completion:nil];
}

- (void)setOverlayPickerView:(ZBarReaderViewController *)reader

{
    
    //清除原有控件
    
    for (UIView *temp in [reader.view subviews]) {
        
        for (UIButton *button in [temp subviews]) {
            
            if ([button isKindOfClass:[UIButton class]]) {
                
                [button removeFromSuperview];
                
            }
            
        }
        
        for (UIToolbar *toolbar in [temp subviews]) {
            
            if ([toolbar isKindOfClass:[UIToolbar class]]) {
                
                [toolbar setHidden:YES];
                
                [toolbar removeFromSuperview];
                
            }
            
        }
        
    }
    
    //画中间的基准线
    line = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2-100, self.view.bounds.size.height/2+100, 199, 14)];
    line.image=[UIImage imageNamed:@"ORline(1).png"];
    [reader.view addSubview:line];
    
    //加上扫描线动画
    lineTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(moveLineWallet) userInfo:nil repeats:YES];
    [lineTimer fire];
    
    //navgation
    UIView *statusBarView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, 0.f)];
    if (isIos7 >= 7 && __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1)
    {
        statusBarView.frame = CGRectMake(statusBarView.frame.origin.x, statusBarView.frame.origin.y, statusBarView.frame.size.width, 20.f);
        statusBarView.backgroundColor = [UIColor clearColor];
        ((UIImageView *)statusBarView).backgroundColor = RGBA(62,130,248,1);
        [reader.view addSubview:statusBarView];
    }
    
    _navView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, StatusbarSize, self.view.frame.size.width, 44.f)];
    ((UIImageView *)_navView).backgroundColor = RGBA(62,130,248,1);
    [reader.view insertSubview:_navView belowSubview:statusBarView];
    _navView.userInteractionEnabled = YES;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((_navView.frame.size.width - 200)/2, (_navView.frame.size.height - 40)/2, 200, 40)];
    [titleLabel setText:@"扫一扫"];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [_navView addSubview:titleLabel];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(14, 2, 70, 40)];
    [backButton setTitle:@"我的钱包" forState:UIControlStateNormal];
    [backButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [backButton setTintColor:[UIColor whiteColor]];
    [backButton setBackgroundColor:[UIColor clearColor]];
    backButton.titleLabel.font=[UIFont systemFontOfSize:13];
    [backButton addTarget:self action:@selector(backtoGround) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:backButton];
    
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(11, (_navView.frame.size.height - 20)/2+5, 7, 10)];
    imageView.image=[UIImage imageNamed:@"title-left.png"];
    [_navView addSubview:imageView];
    
    UIButton *photoButton = [[UIButton alloc] initWithFrame:CGRectMake(_navView.frame.size.width-41, 2, 40, 40)];
    [photoButton setTitle:@"相册" forState:UIControlStateNormal];
    [photoButton setTintColor:[UIColor whiteColor]];
    [photoButton setBackgroundColor:[UIColor clearColor]];
    photoButton.titleLabel.font=[UIFont systemFontOfSize:13];
    [photoButton addTarget:self action:@selector(getPhoto:) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:photoButton];
    
    //用于说明的label
//    UILabel * labIntroudction= [[UILabel alloc] init];
//    labIntroudction.backgroundColor = [UIColor clearColor];
//    labIntroudction.frame=CGRectMake(15, 20, 290, 50);
//    labIntroudction.numberOfLines=2;
//    labIntroudction.textColor=[UIColor whiteColor];
//    labIntroudction.text=@"将二维码图像置于矩形方框内，离手机摄像头10CM左右，系统会自动识别。";
//    [upView addSubview:labIntroudction];

    
    //上方的view
    UIView * upView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height/2-164)];
    upView.alpha = 0.3;
    upView.backgroundColor = [UIColor blackColor];
    [reader.view addSubview:upView];
    
    //扫描边框
    UIImageView *borderImage=[[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2-100, self.view.bounds.size.height/2-100, 200, 200)];
    borderImage.image=[UIImage imageNamed:@"QRborder.png"];
    [borderImage setBackgroundColor:[UIColor clearColor]];
    [reader.view addSubview:borderImage];
    
    //左侧的view
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height/2-100, self.view.bounds.size.width/2-100, 200)];
    leftView.alpha = 0.3;
    leftView.backgroundColor = [UIColor blackColor];
    [reader.view addSubview:leftView];

    
    //右侧的view
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2+100, self.view.bounds.size.height/2-100, self.view.bounds.size.width/2-100, 200)];
    rightView.alpha = 0.3;
    rightView.backgroundColor = [UIColor blackColor];
    [reader.view addSubview:rightView];
    
    //底部view
    UIView * downView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height/2+100, self.view.bounds.size.width,self.view.bounds.size.height/2-100)];
    downView.alpha = 0.3;
    downView.backgroundColor = [UIColor blackColor];
    [reader.view addSubview:downView];
    
    
}

- (void)backtoGround
{
    [lineTimer invalidate];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)getPhoto:(id)sender
{
    //相册获取二维码
    camera=YES;
    cameraReader=[ZBarReaderController new];
    cameraReader.readerDelegate=self;
    cameraReader.showsHelpOnFail=NO;
    cameraReader.allowsEditing=YES;
    cameraReader.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    [myReader presentViewController:cameraReader animated:YES completion:^{
        NSLog(@"跳转成功---");
    }];
}


-(void)moveLineWallet
{
    
    CGRect lineFrame = line.frame;
    CGFloat y = lineFrame.origin.y;
    y=y-200.0;
    lineFrame.origin.y = y;
    [UIView animateWithDuration:2 animations:^{
//        NSLog(@"y=%f",y);
        line.frame = lineFrame;
        
    }];
    y=y+200.0;
    lineFrame.origin.y=y;
    [UIView animateWithDuration:2 animations:^{
//        NSLog(@"y=%f",y);
        line.frame = lineFrame;
        
    }];
}

- (void)dismissOverlayView:(id)sender
{
    [lineTimer invalidate];

    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)receiveBtn:(id)sender
{
    [self performSegueWithIdentifier:@"receive" sender:nil];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"receive"]) {
         ReceiveViewController *view = [segue destinationViewController];
        view.hidesBottomBarWhenPushed=YES;
    }
    else if ([segue.identifier isEqualToString:@"history"])
    {
        HistoryViewController *vc=[segue destinationViewController];
        vc.hidesBottomBarWhenPushed=YES;
    }
    
    else if ([segue.identifier isEqualToString:@"shopinfo"])
    {
        CardInfoViewController *vc=[segue destinationViewController];
        vc.tempCurrencyTypeName=tmpCurrency;
        vc.hidesBottomBarWhenPushed=YES;
    }
    
}

- (IBAction)mSegementedChange:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0)
    {
        segement = NO;
        [self.tableView reloadData];
    }
    else if (sender.selectedSegmentIndex == 1)
    {
        segement = YES;
        [self.tableView reloadData];
    }
}


//二维码扫描
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    id<NSFastEnumeration> results=[info objectForKey:ZBarReaderControllerResults];
    ZBarSymbol *symbol=nil;
    for (symbol in results)
        break;
    NSLog(@"symbol->%@",symbol.data);
    
    if ([[symbol.data substringWithRange:NSMakeRange(11, 7)] isEqualToString:@"jingtum"])
    {
        
        [lineTimer invalidate];
        SCLAlertView *alert = [[SCLAlertView alloc] init];
    
        NSArray *jsonarray=[symbol.data componentsSeparatedByString:@"="];
        addressStr=[jsonarray objectAtIndex:1];
        textFiled1=[alert addTextField:@"请输入金额"];
        textFiled2=[alert addTextField:@"请输入币种"];
        textFiled1.delegate=self;
        textFiled2.delegate=self;
        [textFiled1 setKeyboardType:UIKeyboardTypeDecimalPad];
        
        [alert addButton:@"确定" actionBlock:^{
            if ([textFiled1.text isEqualToString:@""] || [textFiled2.text isEqualToString:@""] || [textFiled1.text isEqualToString:@"0"])
            {
                if (camera == YES)
                {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                else
                {
                    [picker dismissViewControllerAnimated:YES completion:nil];

                }
                    
            }
            else
            {
                if (camera == YES)
                {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                else
                {
                    [picker dismissViewControllerAnimated:YES completion:nil];
                    
                }
                
                [self paySecret];
            }
            
        }];
        NSString *str;
        if ([addressStr isEqualToString:[[JingtumJSManager shared] jingtumWalletAddress]])
        {
            [textFiled1 removeFromSuperview];
            [textFiled2 removeFromSuperview];
            str=[NSString stringWithFormat:@"你不能向自己发送"];
        }
        else
        {
            NSString *oppoAddress=[NSString stringWithFormat:@"%@",addressStr];
            for (RPContact *rp in contractArr)
            {
                if ([rp.fid isEqualToString:addressStr])
                {
                    oppoAddress=[NSString stringWithFormat:@"%@",rp.fname];
                }
            }
            str=[NSString stringWithFormat:@"你将向%@发送%@%@",oppoAddress,textFiled1.text,textFiled2.text];
        }
        
        [alert showEdit:self title:@"账单信息" subTitle:str closeButtonTitle:nil duration:0.0f];
        [myReader.readerView stop];

    }
    
    else
    {
        
        [lineTimer invalidate];
        NSData *data=[symbol.data dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary  *jsonDict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@",jsonDict);
        SCLAlertView *sclAlert = [[SCLAlertView alloc] init];
        
        addressStr=jsonDict[@"address"];
        textFiled1=[sclAlert addTextField:@"请输入金额"];
        textFiled2=[sclAlert addTextField:@"请输入币种"];
        textFiled1.delegate=self;
        textFiled2.delegate=self;
        [textFiled1 setKeyboardType:UIKeyboardTypeNumberPad];
        if (![jsonDict[@"price"]  isEqual:@""])
        {
            [textFiled1 removeFromSuperview];
            textFiled1.text=jsonDict[@"price"];
        }
        if (![jsonDict[@"catagory"]  isEqual:@""])
        {
            [textFiled2 removeFromSuperview];
            textFiled2.text=jsonDict[@"catagory"];
        }
        [sclAlert addButton:@"确定" actionBlock:^{
            if ([textFiled1.text isEqualToString:@""] || [textFiled2.text isEqualToString:@""] || [textFiled1.text isEqualToString:@"0"])
            {
                
                if (camera == YES)
                {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                else
                {
                    [picker dismissViewControllerAnimated:YES completion:nil];
                    
                }
            }
            else
            {
                
                if (camera == YES)
                {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                else
                {
                    [picker dismissViewControllerAnimated:YES completion:nil];
                    
                }
                [self paySecret];
            }
           
        }];
        NSString *str;
        if ([addressStr isEqualToString:[[JingtumJSManager shared] jingtumWalletAddress]])
        {
            str=[NSString stringWithFormat:@"你不能向自己发送"];
        }
        else
        {
            NSString *oppoAddress=[NSString stringWithFormat:@"%@",addressStr];
            for (RPContact *rp in contractArr)
            {
                if ([rp.fid isEqualToString:addressStr])
                {
                    oppoAddress=[NSString stringWithFormat:@"%@",rp.fname];
                }
            }
            str=[NSString stringWithFormat:@"你将向%@发送%@%@",oppoAddress,textFiled1.text,textFiled2.text];
        }
       
        [sclAlert showEdit:picker title:@"账单信息" subTitle:str closeButtonTitle:nil duration:0.0f];
        [myReader.readerView stop];
    }
    
}

- (void) readerControllerDidFailToRead: (ZBarReaderController*) reader
                             withRetry: (BOOL) retry
{
    if (retry)
    {
        NSLog(@"获取二维码失败");
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"获取二维码失败,请重新选取." delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        
        alertCamera=alert;
        [alert show];
        
        
    }
}

#pragma  mark - tabview datasouce delegate

//返回几个表头
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (segement == NO )
    {
        return allPayment.count;
    }
    return 1;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (segement==NO)
    {
        if (indexPath.row == 0)
        {
            return 60;
        }
        else
        {
            return 25;
        }
       
    }
    return 70;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (segement == NO)
    {
        if (self.isopen) {
            if (self.selectIndex.section == section) {
                NSArray *countArr=[allTesttxDict objectForKey:[[allPayment objectAtIndex:self.selectIndex.section] objectForKey:@"type"]];
                if (countArr.count>5)
                {
                    return 6;
                }
                return countArr.count+1;
            }
        }
        return 1;
    }
    else
    
        return nameList.count;
   
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellWithCredIdentifier = @"CredCell";
    if (segement == NO)
    {
        
        if (self.isopen&&self.selectIndex.section == indexPath.section&&indexPath.row!=0) {
            static NSString *CellIdentifier = @"SecondTableViewCell";
             SecondTableViewCell *cell = (SecondTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"secondCell"];
            
            if (!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] objectAtIndex:0];
            }
            NSArray *list = [allTesttxDict objectForKey:[[allPayment objectAtIndex:self.selectIndex.section] objectForKey:@"type"]];
            cell.mContractLabel.text=[list[indexPath.row-1] objectForKey:@"contract"];
            cell.mPriceLabel.text=[list[indexPath.row-1] objectForKey:@"price"];
            return cell;
        }else
        {
            static NSString *CellIdentifier = @"FirstTableViewCell";
            FirstTableViewCell *cell = (FirstTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"firstCell"];
            if (!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] objectAtIndex:0];
            }
            [cell.mColorButton setUserInteractionEnabled:NO];
            cell.mImageView1.image=[UIImage imageNamed:[[allPayment objectAtIndex:indexPath.section] objectForKey:@"image"]];
            cell.mPriceLabel.text=[[allPayment objectAtIndex:indexPath.section] objectForKey:@"price"];
            cell.mCataLabel.text=[[allPayment objectAtIndex:indexPath.section] objectForKey:@"title"];
            if ([[allPayment objectAtIndex:indexPath.section] objectForKey:@"price"]==NULL)
            {
                cell.mPriceLabel.text=@"0.00";
            }
            [cell changeArrowWithUp:([self.selectIndex isEqual:indexPath]?YES:NO)];

            if ([colortestDict objectForKey:[[allPayment objectAtIndex:indexPath.section] objectForKey:@"type"]]!=NULL && ![[colortestDict objectForKey:[[allPayment objectAtIndex:indexPath.section] objectForKey:@"type"]] isEqualToString:@""])
            {
                NSString *tempStr=[NSString stringWithFormat:@"%@",[colortestDict objectForKey:[[allPayment objectAtIndex:indexPath.section] objectForKey:@"type"]]];
                [cell.mColorButton setBackgroundImage:[UIImage imageNamed:@"tip-red"] forState:UIControlStateNormal];
                [cell.mColorButton setTitle:tempStr forState:UIControlStateNormal];
            }
            return cell;
        }
    }
    else
    {
        CredTableViewCell *cell2=[tableView dequeueReusableCellWithIdentifier:CellWithCredIdentifier];
        
        cell2.mImageView.layer.masksToBounds=YES;
        cell2.mImageView.layer.cornerRadius=20.0f;
        cell2.mCredLabel.text=nameList[indexPath.row];
        [cell2.mImageView setImageWithURL:[NSURL URLWithString:otherimgList[indexPath.row][0]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        cell2.mDateLabel.text=dateList[indexPath.row];
        cell2.mNumLabel.text=cardNumList[indexPath.row];
        return cell2;

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
    if (segement == NO)
    {
        //当点击第一层tableview时触发
        if (indexPath.row == 0)
        {
            [colortestDict setObject:@"" forKey:[[allPayment objectAtIndex:indexPath.section] objectForKey:@"type"]];
            //当收起时触发
            if ([indexPath isEqual:self.selectIndex]) {
                self.isopen = NO;
                [self didSelectCellRowFirstDo:NO nextDo:NO];
                self.selectIndex = nil;
            }
            //当按下时触发
            else
            {
                if (!self.selectIndex) {
                    self.selectIndex = indexPath;
                    self.isopen=YES;
                    [self didSelectCellRowFirstDo:YES nextDo:NO];
                }else
                {
                    self.isopen=NO;
                    [self didSelectCellRowFirstDo:NO nextDo:YES];
                   
                }
            }
            
        }

    }
    else if (segement == YES)
    {
        tmpCurrency=currencyList[indexPath.row];
        [self performSegueWithIdentifier:@"shopinfo" sender:nil];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)didSelectCellRowFirstDo:(BOOL)firstDoInsert nextDo:(BOOL)nextDoInsert
{
    FirstTableViewCell *cell = (FirstTableViewCell *)[self.tableView cellForRowAtIndexPath:self.selectIndex];
    [cell changeArrowWithUp:firstDoInsert];
    
    [self.tableView beginUpdates];
    
    NSInteger section = self.selectIndex.section;
    NSArray *countArr=[allTesttxDict objectForKey:[[allPayment objectAtIndex:section] objectForKey:@"type"]];
    NSInteger contentCount = countArr.count;
    if (contentCount > 5)
    {
        contentCount=5;
    }
	NSMutableArray* rowToInsert = [[NSMutableArray alloc] init];
	for (NSUInteger i = 1; i < contentCount + 1; i++) {
		NSIndexPath* indexPathToInsert = [NSIndexPath indexPathForRow:i inSection:section];
		[rowToInsert addObject:indexPathToInsert];
	}
	
	if (firstDoInsert)
    {   [self.tableView insertRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationTop];
    }
	else
    {
        [self.tableView deleteRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationTop];
    }
    
	
	[self.tableView endUpdates];
   
    if (nextDoInsert) {
        self.isopen = YES;
        self.selectIndex = [self.tableView indexPathForSelectedRow];
        [self didSelectCellRowFirstDo:YES nextDo:NO];
    }
    if (self.isopen)
    {
        [self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
        
    }
    
}

#pragma mark - NSNotficition delegate

//删除自身的观察者身份
- (void)notificationUserLoggedOut:(NSNotification *) notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)notificationChange:(NSNotification *) notification
{
    NSDictionary *jsonDict=(NSDictionary *)[notification object];
//    NSLog(@"accountjson-->%@",jsonDict);
    //修改飘红的数值
    if ([jsonDict[@"type"] isEqualToString:@"receive"])
    {
        if (colortestDict[jsonDict[@"currency"]] !=NULL)
        {
            NSString *numStr=[NSString stringWithFormat:@"%@",colortestDict[jsonDict[@"currency"]]];
            NSString *afterStr=[NSString stringWithFormat:@"+%.2f",[numStr floatValue]+[jsonDict[@"value"] floatValue]];
            [colortestDict setObject:afterStr forKey:jsonDict[@"currency"]];
        }
        else
        {
            NSString *afterStr=[NSString stringWithFormat:@"+%.2f",[jsonDict[@"value"] floatValue]];
            [colortestDict setObject:afterStr forKey:jsonDict[@"currency"]];
        }
    }
    
    //添加相应币种的下拉账单
    //    NSLog(@"before-->%@",allTesttxDict);
    NSMutableDictionary *accountDict=[[NSMutableDictionary alloc] init];
    NSString *address,*price;
    if ([jsonDict[@"type"] isEqualToString:@"receive"])
    {
        price=[NSString stringWithFormat:@"+%.2f",[jsonDict[@"value"] floatValue]];
    }
    else
    {
        price=[NSString stringWithFormat:@"-%.2f",[jsonDict[@"value"] floatValue]];
    }
    address=[NSString stringWithFormat:@"%@",[[jsonDict[@"address"] substringWithRange:NSMakeRange(0,6)] stringByAppendingString:JINGTUM_HISTORY_STAR]];
    NSArray *contacts=[[UserDB shareInstance] findContracts];
    for (RPContact *tmp in contacts)
    {
        if ([jsonDict[@"address"] isEqualToString:tmp.fid])
        {
            address=[NSString stringWithFormat:@"%@",tmp.fname];
        }
    }
    [accountDict setObject:address forKey:@"contract"];
    [accountDict setObject:price forKey:@"price"];
    
    BOOL isCurrencyExist=NO;
    NSArray *keys=[allTesttxDict allKeys];
    for (NSString *key in keys)
    {
        if ([key isEqualToString:jsonDict[@"currency"]])
        {
            isCurrencyExist=YES;
            NSMutableArray *tmpArr=[NSMutableArray arrayWithArray:[allTesttxDict objectForKey:key]];
            [tmpArr insertObject:accountDict atIndex:0];
            [allTesttxDict setObject:tmpArr forKey:jsonDict[@"currency"]];
        }
    }
    if (isCurrencyExist == NO)
    {
        NSMutableArray *tmpArr=[[NSMutableArray alloc] init];
        [tmpArr addObject:accountDict];
        [allTesttxDict setObject:tmpArr forKey:jsonDict[@"currency"]];
    }
    [self updateBalances];
}

- (void)notificationCardChange:(NSNotification *) notification
{
    NSDictionary *jsonDict=(NSDictionary *)[notification object];
//    NSLog(@"cardjson-->%@",jsonDict);
    //改变卡包对应的用户通数量
    if (jsonDict)
    {
        if ([[jsonDict objectForKey:@"type"] isEqualToString:@"shopbuy"])
        {
            BOOL isexit=NO;
            
            for (int i=0; i<currencyList.count; i++)
            {
                if ([currencyList[i] isEqualToString:[jsonDict objectForKey:@"currency"]])
                {
                    isexit=YES;
                    NSString *balaceStr=[NSString stringWithFormat:@"%d",[[cardNumList objectAtIndex:i] intValue]+[[jsonDict objectForKey:@"value"] intValue]];
                    [cardNumList replaceObjectAtIndex:i withObject:balaceStr];
                }
            }
            if (!isexit)
            {
//                NSDictionary *dicttmp=[USERDEFAULTS objectForKey:USERDEFAULTS_JINGTUM_SHOPSURE];
//                NSMutableDictionary *tmpshopDict=[NSMutableDictionary dictionaryWithDictionary:dicttmp];
//                [tmpshopDict setObject:[jsonDict objectForKey:@"shopname"] forKey:[jsonDict objectForKey:@"currency"]];
//                [USERDEFAULTS setObject:tmpshopDict forKey:USERDEFAULTS_JINGTUM_SHOPSURE];
                
                NSString *balaceStr=[NSString stringWithFormat:@"%d",[[jsonDict objectForKey:@"value"] intValue]];
                [self getNewCard:[jsonDict objectForKey:@"currency"] andNum:balaceStr];
            }
            
        }
        else if ([[jsonDict objectForKey:@"type"] isEqualToString:@"shopsend"])
        {
            for (int i=0; i<currencyList.count; i++)
            {
                if ([currencyList[i] isEqualToString:[jsonDict objectForKey:@"currency"]])
                {
                    NSString *balaceStr=[NSString stringWithFormat:@"%d",[[cardNumList objectAtIndex:i] intValue]-[[jsonDict objectForKey:@"value"] intValue]];
                    //如果余额是0，则删除这一卡包，不让其显示
                    if ([balaceStr isEqualToString:@"0"])
                    {
                        [nameList removeObjectAtIndex:i];
                        [dateList removeObjectAtIndex:i];
                        [otherimgList removeObjectAtIndex:i];
                        [currencyList removeObjectAtIndex:i];
                        [cardNumList removeObjectAtIndex:i];
                    }
                    else
                    {
                        [cardNumList replaceObjectAtIndex:i withObject:balaceStr];
                    }
                    
                }
            }
            
        }
        else if ([[jsonDict objectForKey:@"type"] isEqualToString:@"shopreceive"])
        {
            BOOL isexit=NO;
            for (int i=0; i<currencyList.count; i++)
            {
                if ([currencyList[i] isEqualToString:[jsonDict objectForKey:@"currency"]])
                {
                    isexit=YES;
                    NSString *balaceStr=[NSString stringWithFormat:@"%d",[[cardNumList objectAtIndex:i] intValue]+[[jsonDict objectForKey:@"value"] intValue]];
                    [cardNumList replaceObjectAtIndex:i withObject:balaceStr];
                }
            }
            if (!isexit)
            {
                NSString *balaceStr=[NSString stringWithFormat:@"%d",[[jsonDict objectForKey:@"value"] intValue]];
                [self getNewCard:[jsonDict objectForKey:@"currency"] andNum:balaceStr];
            }
        }
        
    }
    [self updateBalances];
}



- (void)getNewCard:(NSString *)cardId andNum:(NSString *)cardNum
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/getSelectArrayCurrency",JINGTUM_SHOP];
    NSString *url= [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

     NSDictionary *dict=@{@"type":@"100",@"array":@[cardId]};
    
    [[JingtumJSManager shared] operationManagerPOST:url parameters:dict withBlock:^(NSString *error, id responseData) {
        if ([error isEqualToString:@"0"])
        {
            NSArray *dataarray=[responseData objectForKey:@"data"];
            if (![dataarray isEqual:@"<null>"] && dataarray.count>0)
            {
                for (NSDictionary *tmpDict in dataarray)
                {
                    [currencyList addObject:[tmpDict objectForKey:@"ID"]];
                    [nameList addObject:[tmpDict objectForKey:@"name"]];
                    
                    NSData *data=[[tmpDict objectForKey:@"other"] dataUsingEncoding:NSUTF8StringEncoding];
                    NSArray *jsonArr=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                    NSMutableArray *imageArr=[[NSMutableArray alloc] init];
                    for (NSDictionary *dictTmp in jsonArr)
                    {
                        NSString *imageStr=[NSString stringWithFormat:@"%@/%@r",JINGTUM_SHOP_OTHERPHOTO,dictTmp[@"name"]];
                        [imageArr addObject:imageStr];
                    }
                    [otherimgList addObject:imageArr];
                    
                    NSInteger timeNum=[[tmpDict objectForKey:@"projectPeriod"] integerValue];
                    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timeNum];
                    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
                    [dateList addObject:confromTimespStr];
                    [cardNumList addObject:cardNum];
                    
                }
                [self.tableView reloadData];
                
            }

        }
        
    }];
    
}


#pragma mark - send json recommand


- (void)paySecret
{
    NSString *flag=[USERDEFAULTS objectForKey:USERDEFAULTS_JINGTUM_PAYSECRET];
    if ([flag isEqualToString:@"0"])
    {
        [self sendData];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入6位支付密码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        alert.alertViewStyle=UIAlertViewStyleSecureTextInput;
        verifyFiled=[alert textFieldAtIndex:0];
        verifyFiled.delegate=self;
        verifyFiled.placeholder=@"请输入密码";
        [verifyFiled setKeyboardType:UIKeyboardTypeNumberPad];
        verifyFiled.secureTextEntry=YES;
        
        verifyAlert=alert;
        [alert show];
    }
    
}

- (void)sendData
{
    
    NSDecimalNumber *amount=[NSDecimalNumber decimalNumberWithString:textFiled1.text];
    RPNewTransaction *transaction=[RPNewTransaction new];
    transaction.to_address=addressStr;
    transaction.to_currency=textFiled2.text;
    transaction.to_amount=amount;
    transaction.from_currency=textFiled2.text;
    transaction.to_issuer=JINGTUM_ISSURE;
    
    [[JingtumJSManager shared] wrapperSendSubmit:transaction withBlock:^(NSError *error) {
        if (!error)
        {
            NSLog(@"交易成功");
        }
        else
        {
            NSString *message=[NSString stringWithFormat:@"错误:%@",error.localizedDescription];
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }];
    
}

#pragma mark - 最后一次修改密码的时间与现在的时间差

- (void)returnUploadTime
{
    
    NSDate *lastTime=[USERDEFAULTS objectForKey:USERDEFAULTS_JINGTUM_LASTLOGIN];
    
    NSTimeInterval late=[lastTime timeIntervalSince1970]*1;
    
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    
    NSTimeInterval cha=now-late;
    
    if (cha/3600<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/60];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@分钟前", timeString];
        
    }
    if (cha/3600>1&&cha/86400<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/3600];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@小时前", timeString];
//        NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
//        [dateformatter setDateFormat:@"HH:mm"];
//        timeString = [NSString stringWithFormat:@"今天 %@",[dateformatter stringFromDate:time]];
    }
    if (cha/86400>1)
    {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@天前", timeString];
//        NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
//        [dateformatter setDateFormat:@"YY-MM-dd HH:mm"];
//        timeString = [NSString stringWithFormat:@"%@",[dateformatter stringFromDate:time]];
        if ([timeString integerValue] >= 30)
        {
            AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
            appdelegate.lastLogin=YES;
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"您已经一个月没有修改密码了,建议您尽快修改密码已保证账户安全!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil ];
            [alert show];
        }
        
    }
    NSLog(@"timeString->%@",timeString);
}

@end
