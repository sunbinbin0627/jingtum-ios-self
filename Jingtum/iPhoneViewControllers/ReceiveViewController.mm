//
//  ReceiveViewController.m
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "ReceiveViewController.h"
#import "JingtumJSManager.h"
#import "ZBarSDK.h"
#import "QRCodeGenerator.h"
#import <QuartzCore/QuartzCore.h>
#import <ShareSDK/ISSContent.h>
#import <ShareSDK/ShareSDK.h>
#import "AppDelegate.h"

#define QRCODE_SIZE 200

@interface ReceiveViewController ()
{
    UITextField *textFiled1;
    UITextField *textFiled2;
    UIView *myView;
    BOOL select;
    UIView *_navView;
    int isFirstClick;
}
@end

@implementation ReceiveViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [AppDelegate  storyBoradAutoLay:self.view];
    
    isFirstClick=0;
    
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
    [titleLabel setText:@"二维码"];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [_navView addSubview:titleLabel];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(14, 2+NavViewHeigth/2, 70, 40)];
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
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(_navView.frame.size.width-41, (_navView.frame.size.height - 20)/2, 40, 20)];
    [button setImage:[UIImage imageNamed:@"share.png"] forState:UIControlStateNormal];
    [button setTintColor:[UIColor whiteColor]];
    [button setBackgroundColor:[UIColor clearColor]];
    button.titleLabel.font=[UIFont systemFontOfSize:13];
    [button addTarget:self action:@selector(shareBtn) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:button];
    
    
    self.priceLabel.text=@"";
    self.cataLabel.text=@"";
    
    textFiled1.delegate=self;
    textFiled2.delegate=self;
    [textFiled1 setPlaceholder:@"请输入金额"];
    [textFiled2 setPlaceholder:@"请输入币种"];
    
    UILongPressGestureRecognizer *longPressGR =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(longPress:)];
    longPressGR.minimumPressDuration = 2.0;
    [self.btnImage addGestureRecognizer:longPressGR];
    

//    UIImage *testImage=[UIImage imageNamed:@"58X58.png"];
//    [self.btnImage setImage:[QRCodeGenerator qrImageForString:str imageSize:QRCODE_SIZE Topimg:testImage] forState:UIControlStateNormal];
    
    NSString *str=[NSString stringWithFormat:@"http://www.jingtum.com?to=%@",[[JingtumJSManager shared] jingtumWalletAddress]];
    [self.btnImage setImage:[QRCodeGenerator qrImageForString:str imageSize:QRCODE_SIZE] forState:UIControlStateNormal];//jingtum

    self.userLabel.text=[[JingtumJSManager shared] jingtumUserName];
}

- (void)backtoGround
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shareBtn
{
    UIImage *shareImage;
    //由视图创建UIImage
    [self saveView];
    UIGraphicsBeginImageContext(myView.bounds.size);
    [myView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //2 保存到沙盒
    NSString *path=[[NSHomeDirectory() stringByAppendingFormat:@"/tmp"] stringByAppendingString:@"/image.jpg"] ;
    
    if([UIImageJPEGRepresentation(img, 1)  writeToFile:path atomically:YES])
    {
        NSLog(@"保存成功");
        NSLog(@"%@",path);
        //        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"保存成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        //        [alert show];
        NSData *data=[NSData dataWithContentsOfFile:path];
        shareImage=[[UIImage alloc] initWithData:data];
        
    }
    else
    {
        NSLog(@"保存失败");
        
    }
    
    id<ISSContainer> container = [ShareSDK container];
    [container setIPhoneContainerWithViewController:self];
    
    NSArray *shareList = [ShareSDK getShareListWithType:
                          ShareTypeWeixiSession,
                          nil];
    
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:nil
                                       defaultContent:nil
                                                image:[ShareSDK pngImageWithImage:shareImage]
                                                title:nil
                                                  url:nil
                                          description:nil
                                            mediaType:SSPublishContentMediaTypeImage];
    
    
    [ShareSDK showShareActionSheet:container
                         shareList:shareList
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions:nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                
                                NSString *name = nil;
                                switch (type)
                                {
                                    case ShareTypeWeixiSession:
                                        name = @"微信朋友圈";
                                        break;
                                    default:
                                        name = @"某个平台";
                                        break;
                                }
                                
                                NSString *notice = nil;
                                if (state == SSResponseStateSuccess)
                                {
                                    notice = [NSString stringWithFormat:@"分享到%@成功！", name];
                                    NSLog(@"%@",notice);
                                    UIAlertView *view =
                                    [[UIAlertView alloc] initWithTitle:@"提示"
                                                               message:notice
                                                              delegate:nil
                                                     cancelButtonTitle:@"知道了"
                                                     otherButtonTitles: nil];
                                    [view show];
                                    
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    notice = [NSString stringWithFormat:@"分享失败,错误码:%ld,错误描述:%@", (long)[error errorCode], [error errorDescription]];
                                    NSLog(@"%@",notice);
                                    
                                    UIAlertView *view =
                                    [[UIAlertView alloc] initWithTitle:@"提示"
                                                               message:notice
                                                              delegate:nil
                                                     cancelButtonTitle:@"知道了"
                                                     otherButtonTitles: nil];
                                    [view show];
                                    
                                }
                            }];
    

}

- (void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
//        NSLog(@"begin111");
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
//        NSLog(@"change222");
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
//        NSLog(@"ended333");
        UIAlertView *alert2=[[UIAlertView alloc] initWithTitle:@"保存图片" message:@"确定要保存二维码图片么" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        select=NO;
        [alert2 show];

    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:textFiled2])
    {
        [textFiled1 resignFirstResponder];
        UIActionSheet *sheet=[[UIActionSheet alloc] initWithTitle:@"选择币种"
                                                        delegate:self
                                               cancelButtonTitle:@"取消"
                                          destructiveButtonTitle:@"CNY"
                                                otherButtonTitles:@"SWT",@"USD",nil];
        [sheet showInView:self.view];
        
    }
    return YES;
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    NSLog(@"%@",[actionSheet buttonTitleAtIndex:3]);
    if (buttonIndex !=3)
    {
        textFiled2.text=[actionSheet buttonTitleAtIndex:buttonIndex];
    }
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (select==YES)
    {
        if (buttonIndex==0)
        {
            
            self.priceLabel.text=textFiled1.text;
            self.cataLabel.text=textFiled2.text;
            self.priceLabel.hidden=NO;
            self.cataLabel.hidden=NO;
            
            NSDictionary *dict=@{@"address":[[JingtumJSManager shared] jingtumWalletAddress],
                                 @"catagory":self.cataLabel.text,
                                 @"price":self.priceLabel.text};
            NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [self.btnImage setImage:[QRCodeGenerator qrImageForString:str imageSize:QRCODE_SIZE] forState:UIControlStateNormal];
            
            [self saveView];
            
        }
    }
    else if (select==NO)
    {
        if (buttonIndex == 0)
        {
            [self saveView];
            [self savepicture];
            
        }
    }
  
}

- (IBAction)Btn:(id)sender
{
    isFirstClick += 1;
    
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"设置金额" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消",nil];
    select=YES;
    alert.alertViewStyle=UIAlertViewStyleLoginAndPasswordInput;
    textFiled1=[alert textFieldAtIndex:0];
    textFiled2=[alert textFieldAtIndex:1];
    textFiled1.delegate=self;
    textFiled2.delegate=self;
    [textFiled1 setKeyboardType:UIKeyboardTypeDecimalPad];
    textFiled2.secureTextEntry=NO;
    [textFiled1 setPlaceholder:@"请输入金额"];
    [textFiled2 setPlaceholder:@"请输入币种"];
    if (isFirstClick != 1)
    {
        textFiled1.text=self.priceLabel.text;
        textFiled2.text=self.cataLabel.text;
    }
    [alert show];
}

- (void)saveView
{
    myView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    
    UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(45, 70, 200, 15)];
    titleLabel.text=@"扫一扫二维码进行付款";
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [myView addSubview:titleLabel];
    
    UIImageView *tmpImage=[[UIImageView alloc] initWithFrame:CGRectMake(45, 87, 230, 230)];
    tmpImage.image=self.btnImage.imageView.image;
    [myView addSubview:tmpImage];
    
    UILabel *toLabel=[[UILabel alloc] initWithFrame:CGRectMake(53, 319, 50, 22)];
    toLabel.text=@"  向:";
    [toLabel setTextAlignment:NSTextAlignmentCenter];
    [myView addSubview:toLabel];
    
    UILabel *usersLabel=[[UILabel alloc] initWithFrame:CGRectMake(104, 319, 90, 22)];
    usersLabel.text=self.userLabel.text;
    [usersLabel setTextAlignment:NSTextAlignmentCenter];
    [myView addSubview:usersLabel];
    
    UILabel *payLabel=[[UILabel alloc] initWithFrame:CGRectMake(53, 342, 50, 22)];
    payLabel.text=@"付款:";
    [payLabel setTextAlignment:NSTextAlignmentCenter];
    [myView addSubview:payLabel];
    
    UILabel *numLabel=[[UILabel alloc] initWithFrame:CGRectMake(89, 342, 40, 22)];
    numLabel.text=self.priceLabel.text;
    [numLabel setTextAlignment:NSTextAlignmentCenter];
    [myView addSubview:numLabel];
    
    UILabel *catagoryLabel=[[UILabel alloc] initWithFrame:CGRectMake(130, 342, 40, 22)];
    catagoryLabel.text=self.cataLabel.text;
    [catagoryLabel setTextAlignment:NSTextAlignmentCenter];
    [myView addSubview:catagoryLabel];
    
    
}

//保存图片到相册和沙盒
- (void)savepicture
{
    //由视图创建UIImage
    UIGraphicsBeginImageContext(myView.bounds.size);
    [myView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //1 保存到相册
    UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
    
    //2 保存到沙盒
    NSString *path=[[NSHomeDirectory() stringByAppendingFormat:@"/tmp"] stringByAppendingString:@"/image.jpg"] ;
    
    if([UIImageJPEGRepresentation(img, 1)  writeToFile:path atomically:YES])
    {
        NSLog(@"保存成功");
        NSLog(@"%@",path);
        UIAlertView *alert1=[[UIAlertView alloc] initWithTitle:@"提示" message:@"保存成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        [alert1 show];
    }
    else
    {
        NSLog(@"保存失败");
        
    }
}



@end
