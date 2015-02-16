//
//  UserQrcodeViewController.m
//  Jingtum
//
//  Created by sunbinbin on 14-12-2.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "UserQrcodeViewController.h"
#import "ZBarSDK.h"
#import "QRCodeGenerator.h"
#import "JingtumJSManager.h"
#import "AppDelegate.h"

@interface UserQrcodeViewController ()
{
    UIView *_navView;
    UIView *myView;
}
@end

@implementation UserQrcodeViewController

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
    [titleLabel setText:@"我的二维码"];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [_navView addSubview:titleLabel];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 2+NavViewHeigth/2, 70, 40)];
    [backButton setTitle:@"账户设置" forState:UIControlStateNormal];
    [backButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [backButton setTintColor:[UIColor whiteColor]];
    [backButton setBackgroundColor:[UIColor clearColor]];
    backButton.titleLabel.font=[UIFont systemFontOfSize:13];
    [backButton addTarget:self action:@selector(backtoGround) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:backButton];
    
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(11, (_navView.frame.size.height - 20)/2+5, 7, 10)];
    imageView.image=[UIImage imageNamed:@"title-left.png"];
    [_navView addSubview:imageView];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(_navView.frame.size.width-41, 2, 40, 40)];
    [button setImage:[UIImage imageNamed:@"share.png"] forState:UIControlStateNormal];
    [button setTintColor:[UIColor whiteColor]];
    [button setBackgroundColor:[UIColor clearColor]];
    [button addTarget:self action:@selector(savePhoto) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:button];
    
//    self.mAddressLabel.text=[[JingtumJSManager shared] jingtumWalletAddress];
    self.mAddressLabel.text=[USERDEFAULTS objectForKey:JINGTUM_SAVETOKEN];
    
    NSString *str=[NSString stringWithFormat:@"http://www.jingtum.com/addcontract?to=%@",[[JingtumJSManager shared] jingtumWalletAddress]];
     [self.mQrcodeButton setImage:[QRCodeGenerator qrImageForString:str imageSize:200] forState:UIControlStateNormal];
    
}

- (void)savePhoto
{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"确定保存图片到本地？" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self saveView];
        [self savepicture];
    }
}

- (void)saveView
{
    myView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    
    UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(45, 70, 200, 15)];
    titleLabel.text=@"扫一扫二维码添加我哦！！";
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [myView addSubview:titleLabel];
    
    UIImageView *tmpImage=[[UIImageView alloc] initWithFrame:CGRectMake(45, 87, 230, 230)];
    tmpImage.image=self.mQrcodeButton.imageView.image;
    [myView addSubview:tmpImage];
    
    
}

//保存图片到相册和沙盒
- (void)savepicture
{
    //由视图创建UIImage
    UIGraphicsBeginImageContext(myView.bounds.size);
#ifdef IOS7_SDK_AVAILABLE
    [myView.layer renderInContext:UIGraphicsGetCurrentContext()];
#else
#endif
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

    }
    else
    {
        NSLog(@"保存失败");
        UIAlertView *alert1=[[UIAlertView alloc] initWithTitle:@"提示" message:@"保存失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        [alert1 show];
        
    }
}

- (void)backtoGround
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)copyBtn:(id)sender
{
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:self.mAddressLabel.text];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"复制到剪切板上"
                                                    message:self.mAddressLabel.text
                                                   delegate:Nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
@end
