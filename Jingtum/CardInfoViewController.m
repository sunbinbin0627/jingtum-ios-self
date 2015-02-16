//
//  CardInfoViewController.m
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "CardInfoViewController.h"
#import "ZBarSDK.h"
#import "QRCodeGenerator.h"
#import "SCLAlertView.h"
#import "JingtumJSManager.h"
#import "AppDelegate.h"
#import "JingtumJSManager+SendTransaction.h"
#import "JingtumJSManager+PaySecret.h"
#import "JingtumJSManager+NetworkStatus.h"
#import "SVProgressHUD.h"
#import "CardDetailViewController.h"
#import "CardSuerViewController.h"

@interface CardInfoViewController ()
{
    UIView *_navView;
    UIPageControl *pageController;
    ZBarReaderViewController *myReader;//相机扫描二维码
    ZBarReaderController *cameraReader;//相册获取二维码
    UIAlertView *alertCamera;//扫描相册二维码无效时弹出框
    UIImageView* line;//二维码扫描线
    NSTimer* lineTimer;//二维码扫描线计时器。
    UITextField *textFiled;
    NSString *addressStr;
    NSString *selfNotifitionStr;
    NSString *oppositeNotifitionStr;
    BOOL isCamera;//判断是相机的扫描界面还是相册的扫描界面
    NSDateFormatter *formatter;//时间戳
    NSString *tempshopDetail,*tempshopSure;
    
    UIAlertView *verifyAlert;
    UIAlertView *verifyFailAlert;
    UITextField *verifyFiled;
    
}
@end

@implementation CardInfoViewController

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
    
    isCamera=NO;
    
    //时间戳转时间的方法
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    
    
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
    [shopButton setTitle:@"我的钱包" forState:UIControlStateNormal];
    [shopButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [shopButton setTintColor:[UIColor whiteColor]];
    [shopButton setBackgroundColor:[UIColor clearColor]];
    shopButton.titleLabel.font=[UIFont systemFontOfSize:13];
    [shopButton addTarget:self action:@selector(backtoGround) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:shopButton];
    
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(11, (_navView.frame.size.height - 20)/2+5, 7, 10)];
    imageView.image=[UIImage imageNamed:@"title-left.png"];
    [_navView addSubview:imageView];
   
    [self showShopInfo];
}


- (void)showShopInfo
{
    [SVProgressHUD showWithStatus:@"加载中..." maskType:SVProgressHUDMaskTypeGradient];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/getDetailBonds?type=100&ID=%@",JINGTUM_SHOP,self.tempCurrencyTypeName];
    NSString *url = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    [[JingtumJSManager shared] operationManagerGET:url parameters:nil withBlock:^(NSString *error, id responseData) {
        if ([error isEqualToString:@"0"])
        {
            NSArray *dataarray=[responseData objectForKey:@"data"];
            if (![dataarray isEqual:@"<null>"] && dataarray.count>0)
            {
                for (NSDictionary *tmpDict in dataarray)
                {
                    NSString *nameStr=[NSString stringWithFormat:@"%@",[tmpDict objectForKey:@"name"]];
                    NSString *shopNameStr=[NSString stringWithFormat:@"%@",[tmpDict objectForKey:@"guaranteeCompanycontext"]];
                    NSString *priceStr=[NSString stringWithFormat:@"%@",[tmpDict objectForKey:@"value"]];
                    NSString *numStr=[NSString stringWithFormat:@"%@",[tmpDict objectForKey:@"amount"]];
                    NSString *infoStr=[NSString stringWithFormat:@"%@",[tmpDict objectForKey:@"info"]];
                    NSString *addressstr=[NSString stringWithFormat:@"%@",[tmpDict objectForKey:@"guaranteeCompany"]];
                    tempshopDetail=[NSString stringWithFormat:@"%@",[tmpDict objectForKey:@"subjectInfo"]];
                    tempshopSure=[NSString stringWithFormat:@"%@",[tmpDict objectForKey:@"subjectAnalyze"]];
                    
                    self.mNameLabel.text=nameStr;
                    self.mNameLabel2.text=shopNameStr;
                    self.mPriceLabel.text=priceStr;
                    self.mNumLabel.text=numStr;
                    self.mShopInfoLabel.text=infoStr;
                    self.mAddressLabel.text=addressstr;
                    self.tempPhoneNum=[NSString stringWithFormat:@"%@",[tmpDict objectForKey:@"guarantee"]];
                    self.tempCurrencyTypeName=[NSString stringWithFormat:@"%@",[tmpDict objectForKey:@"ID"]];
                    
                    NSMutableArray *imageArr=[[NSMutableArray alloc] init];
                    if ([tmpDict objectForKey:@"photo"] && ![tmpDict[@"photo"] isEqual:@"<null>"] && ![tmpDict[@"photo"] isEqual:[NSNull null]] && ![tmpDict[@"photo"] isEqual:@"[]"])
                    {
                        NSData *data=[[tmpDict objectForKey:@"photo"] dataUsingEncoding:NSUTF8StringEncoding];
                        NSArray *jsonArr=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                        
                        for (NSDictionary *dictTmp in jsonArr)
                        {
                            NSString *imageStr=[NSString stringWithFormat:@"%@/%@r",JINGTUM_SHOP_PHOTO,dictTmp[@"name"]];
                            [imageArr addObject:imageStr];
                        }
                    }
                    else
                    {
                        NSString *imageStr=[NSString stringWithFormat:@"null"];
                        [imageArr addObject:imageStr];
                        
                    }
                    self.tempImageArr=imageArr;
                    
                    NSInteger timeNum=[[tmpDict objectForKey:@"projectPeriod"] integerValue];
                    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timeNum];
                    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
                    self.mDataLabel.text=confromTimespStr;
                    
                }
                
                //设置scrollview
                NSInteger num=self.tempImageArr.count;
                self.mScrollView.contentSize=CGSizeMake1(320*num, 196);
                [self.mScrollView setBounces:NO];
                [self.mScrollView setShowsHorizontalScrollIndicator:NO];
                [self.mScrollView setPagingEnabled:YES];
                
                for (int i=0; i<num; i++)
                {
                    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake1(320*i, 0, 320, 196)];
                    NSURL *imgUrl=[NSURL URLWithString:self.tempImageArr[i]];
                    NSData *imgData=[NSData dataWithContentsOfURL:imgUrl];
                    imageView.image=[UIImage imageWithData:imgData];
                    [self.mScrollView addSubview:imageView];
                }
                
                //添加pageControl
                pageController=[[UIPageControl alloc] initWithFrame:CGRectMake(80, self.mScrollView.bounds.size.height+30, self.view.bounds.size.width-160, 20)];
                [pageController setBackgroundColor:[UIColor clearColor]];
                pageController.currentPage=0;
                pageController.numberOfPages=num;
                [self.view addSubview:pageController];
                
                [SVProgressHUD dismiss];
                
            }
            else
            {
                [SVProgressHUD dismiss];
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"服务器错误,请稍后重试!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }

        }
        else
        {
            [SVProgressHUD dismiss];
            NSLog(@"获取卡包页面请求失败");
        }
        
    }];
    
}

- (void)backtoGround
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSArray *)getContract
{
    return [NSMutableArray arrayWithArray:[[UserDB shareInstance] findContracts]];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
{
    if ([scrollView isMemberOfClass:[UIScrollView class]])
    {
        int index= scrollView.contentOffset.x/320;
        [pageController setCurrentPage:index];
        
    }
    
}


- (IBAction)useBtn:(id)sender
{
    isCamera=NO;
    myReader=[ZBarReaderViewController  new];
    myReader.readerDelegate=self;
//    myReader.wantsFullScreenLayout=NO;
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
    lineTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(moveLine) userInfo:nil repeats:YES];
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
    [titleLabel setText:@"用户通"];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [_navView addSubview:titleLabel];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(14, 2, 70, 40)];
    [backButton setTitle:@"商品详情" forState:UIControlStateNormal];
    [backButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [backButton setTintColor:[UIColor whiteColor]];
    [backButton setBackgroundColor:[UIColor clearColor]];
    backButton.titleLabel.font=[UIFont systemFontOfSize:13];
    [backButton addTarget:self action:@selector(backtoGround2) forControlEvents:UIControlEventTouchUpInside];
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
    
    
    //上方的view
    UIView * upView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height/2-164)];
    upView.alpha = 0.3;
    upView.backgroundColor = [UIColor blackColor];
    [reader.view addSubview:upView];
    
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
    
    //扫描边框
    UIImageView *borderImage=[[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2-100, self.view.bounds.size.height/2-100, 200, 200)];
    borderImage.image=[UIImage imageNamed:@"QRborder.png"];
    [borderImage setBackgroundColor:[UIColor clearColor]];
    [reader.view addSubview:borderImage];
    
    
}

-(void)getPhoto:(id)sender
{
    //相册获取二维码
    isCamera=YES;
    cameraReader=[ZBarReaderController new];
    cameraReader.readerDelegate=self;
    cameraReader.showsHelpOnFail=NO;
    cameraReader.allowsEditing=YES;
    cameraReader.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    [myReader presentViewController:cameraReader animated:YES completion:^{
        NSLog(@"跳转成功---");
    }];
}


- (void)backtoGround2
{
    [lineTimer invalidate];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)moveLine
{
    
    CGRect lineFrame = line.frame;
    CGFloat y = lineFrame.origin.y;
    y=y-200.0;
    lineFrame.origin.y = y;
    [UIView animateWithDuration:2 animations:^{
        
        line.frame = lineFrame;
        
    }];
    y=y+200.0;
    lineFrame.origin.y=y;
    [UIView animateWithDuration:2 animations:^{
        
        line.frame = lineFrame;
        
    }];
}

- (void)dismissOverlayView:(id)sender
{
    [lineTimer invalidate];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

//二维码扫描
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    id<NSFastEnumeration> results=[info objectForKey:ZBarReaderControllerResults];
    ZBarSymbol *symbol=nil;
    for (symbol in results)
        break;

     NSArray *contacts=[self getContract];
    if ([[symbol.data substringWithRange:NSMakeRange(11, 7)] isEqualToString:@"jingtum"])
    {
        [myReader.readerView stop];
        [lineTimer invalidate];
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        
        NSArray *jsonarray=[symbol.data componentsSeparatedByString:@"="];
        addressStr=[jsonarray objectAtIndex:1];
        textFiled=[alert addTextField:@"请输入数量"];
        textFiled.delegate=self;
        [textFiled setKeyboardType:UIKeyboardTypeNumberPad];
        
        [alert addButton:@"确定" actionBlock:^{
            if (![textFiled.text isEqualToString:@""] && ![textFiled.text isEqualToString:@"0"])
            {
                [self paySecret];
            }
            if (isCamera==YES)
            {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else
            {
                [picker dismissViewControllerAnimated:YES completion:nil];
            }
            
        }];
        NSString *str;
        if ([addressStr isEqualToString:[[JingtumJSManager shared] jingtumWalletAddress]])
        {
            [textFiled removeFromSuperview];
            str=[NSString stringWithFormat:@"你不能向自己发送"];
        }
        else
        {
            NSString *oppoAddress=[NSString stringWithFormat:@"%@",addressStr];
            for (RPContact *rp in contacts)
            {
                if ([rp.fid isEqualToString:addressStr])
                {
                    oppoAddress=[NSString stringWithFormat:@"%@",rp.fname];
                }
            }
            str=[NSString stringWithFormat:@"你将向%@发送%@%@",oppoAddress,textFiled.text,self.mNameLabel.text];
        }
        
        [alert showEdit:picker title:@"账单信息" subTitle:str closeButtonTitle:nil duration:0.0f];
        
    }
    
    else
    {
        [myReader.readerView stop];
        [lineTimer invalidate];
        NSData *data=[symbol.data dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary  *jsonDict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@",jsonDict);
        
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        
        addressStr=jsonDict[@"address"];
        textFiled=[alert addTextField:@"请输入数量"];
        textFiled.delegate=self;
        [textFiled setKeyboardType:UIKeyboardTypeNumberPad];
        if (![jsonDict[@"price"]  isEqual:@""])
        {
            [textFiled removeFromSuperview];
            textFiled.text=jsonDict[@"price"];
        }
        [alert addButton:@"确定" actionBlock:^{
            [self paySecret];
            if (isCamera==YES)
            {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else
            {
                [picker dismissViewControllerAnimated:YES completion:nil];
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
            for (RPContact *rp in contacts)
            {
                if ([rp.fid isEqualToString:addressStr])
                {
                    oppoAddress=[NSString stringWithFormat:@"%@",rp.fname];
                }
            }
            str=[NSString stringWithFormat:@"你将向%@发送%@%@",oppoAddress,jsonDict[@"price"],self.mNameLabel.text];
        }
        
        [alert showEdit:picker title:@"账单信息" subTitle:str closeButtonTitle:nil duration:0.0f];
        
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


- (IBAction)addressBtn:(id)sender {
}

- (IBAction)phoneBtn:(id)sender
{
    
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:self.tempPhoneNum delegate:self cancelButtonTitle:@"呼叫" otherButtonTitles:@"取消", nil];
    [alert show];
   
}

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
            //跳转到拨打电话
            NSString *phoneStr=[NSString stringWithFormat:@"tel://%@",self.tempPhoneNum];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneStr]];
        }
    }
   
}

- (IBAction)sureBtn:(id)sender
{
    [self performSegueWithIdentifier:@"sure" sender:nil];
}

- (IBAction)detailBtn:(id)sender
{
    [self performSegueWithIdentifier:@"detail" sender:nil];
}

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
    NSDecimalNumber *amount=[NSDecimalNumber decimalNumberWithString:textFiled.text];
    RPNewTransaction *transaction=[RPNewTransaction new];
    transaction.to_address=addressStr;
    transaction.to_currency=self.tempCurrencyTypeName;
    transaction.to_amount=amount;
    transaction.from_currency=self.tempCurrencyTypeName;
    transaction.to_issuer=JINGTUM_ISSURE;
    
    [[JingtumJSManager shared] wrapperSendShop:transaction withBlock:^(NSError *error) {
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"detail"]) {
        CardDetailViewController *view = [segue destinationViewController];
        view.tmpInfo=tempshopDetail;
        view.hidesBottomBarWhenPushed=YES;
    }
    else if ([segue.identifier isEqualToString:@"sure"])
    {
        CardSuerViewController *view = [segue destinationViewController];
        view.tmpSure=tempshopSure;
        view.hidesBottomBarWhenPushed=YES;
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
