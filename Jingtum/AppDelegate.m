//
//  AppDelegate.m
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "AppDelegate.h"
#import "RPGlobals.h"
#import "JingtumJSManager.h"
#import "SMS_SDK/SMS_SDK.h"
#import <ShareSDK/ShareSDK.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WXApi.h"
#import "WeiboSDK.h"
#import <RennSDK/RennSDK.h>
#import <sqlite3.h>
#import "UserDB.h"
#import "RPContact.h"
#import "GestureSureViewController.h"
#import "KeychainItemWrapper.h"
#import "JingtumJSManager+TransactionCallback.h"

#define appKey @"3ffe9eb76e6b"
#define appSecret @"9c8a02823d3a4e547a188fe4b3dfb7bd"

@implementation AppDelegate
@synthesize firstLogin;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    AppDelegate *myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(SCREEN_HEIGHT > 480){
        myDelegate.autoSizeScaleX = SCREEN_WIDTH/320;
        myDelegate.autoSizeScaleY = SCREEN_HEIGHT/568;
    }else{
        myDelegate.autoSizeScaleX = 1.0;
        myDelegate.autoSizeScaleY = 1.0;
    }
    
    [SMS_SDK registerApp:appKey withSecret:appSecret];
    
    
    //微信分享
    [ShareSDK registerApp:@"3ffe9eb76e6b"];
    [ShareSDK connectWeChatWithAppId:@"wx08a1fc67c77c35cd"        //此参数为申请的微信AppID
                           wechatCls:[WXApi class]];
    
    //新浪微博分享
//    [ShareSDK connectSinaWeiboWithAppKey:@"880149143"
//                               appSecret:@"56db8abe2e16b291e9904c176d35632b"
//                             redirectUri:@"http://www.sharesdk.cn"];
    
    //人人分享
//    [ShareSDK connectRenRenWithAppId:@"273018"
//                              appKey:@"38feb7b1929645118eeba45d81894e62"
//                           appSecret:@"b58ea6d0284f4684ada9dbb674802131"
//                   renrenClientClass:[RennClient class]];
    
    //网易分享（2天后才可注册审核，周四）
    //    Consumer Key：MmxhrlDjEC5Yvf4J
    
    //连接短信分享
    [ShareSDK connectSMS];
    
    
    //设置statusbar字体颜色
    if (isIos7) { // 判断是否是IOS7
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
         [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    }
    
    //判断是不是第一次启动
    if (![USERDEFAULTS boolForKey:@"firstLaunch"])
    {
        [USERDEFAULTS setBool:YES forKey:@"firstLaunch"];
        NSLog(@"第一次启动");
    }
    
    [USERDEFAULTS setBool:NO forKey:@"paySecret"];
    
    if (SCREEN_HEIGHT == ISIPHONE4)
    {
        UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];//Storyboard_iphone@3.5
        self.window.rootViewController=[storyboard instantiateInitialViewController];
    }
    else if (SCREEN_HEIGHT >= ISIPHONE5)
    {
        UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];//MainStoryboard_iPhone
        self.window.rootViewController=[storyboard instantiateInitialViewController];
    }
    
    //注册通知
#ifdef IOS8_SDK_AVAILABLE
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:
                                                UIUserNotificationTypeBadge|
                                                UIUserNotificationTypeSound|
                                                UIUserNotificationTypeAlert
                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
        UIRemoteNotificationType myTypes =(UIRemoteNotificationTypeBadge |
                                           UIRemoteNotificationTypeAlert |
                                           UIRemoteNotificationTypeSound);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
#else
    UIRemoteNotificationType types = (UIRemoteNotificationTypeBadge |
                                      UIRemoteNotificationTypeSound |
                                      UIRemoteNotificationTypeAlert);
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
#endif
    
    
    //建联系人表
    if ([[UserDB shareInstance] deleteContract])
    {
        NSLog(@"删除联系人页表成功");
    }
    [[UserDB shareInstance] createContractTable];
    
    //建钱包页表
    if ([[UserDB shareInstance] deleteWallet])
    {
        NSLog(@"删除钱包页表成功");
    }
    [[UserDB shareInstance] createWalletTable];
    
    //创建历史账单表
    if ([[UserDB shareInstance] deleteHistory])
    {
        NSLog(@"删除账单页表成功");
    }
    [[UserDB shareInstance] createHistoryAccount];
    
    [self removeUserDefaut];
    
    NSLog(@"launchOptions==%@",launchOptions);
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    //    // Clear application badge when app launches
    application.applicationIconBadgeNumber = 0;
    firstLogin=0;
    self.lastLogin=NO;
    self.isLoginSecret=NO;
    self.isWithdraw=NO;
    self.timer=0;
    
    //判断用户是否设置过手势密码
    KeychainItemWrapper * keychin = [[KeychainItemWrapper alloc]initWithIdentifier:@"Gesture" accessGroup:nil];
    NSString *password = [keychin objectForKey:(__bridge id)kSecValueData];
    if ([password isEqualToString:@""]) {
        
        self.isGesture=NO;
    }
    else {
        self.isGesture=YES;
    }

    return YES;
}

//storyBoard view自动适配
+ (void)storyBoradAutoLay:(UIView *)allView
{
    for (UIView *temp in allView.subviews) {
        temp.frame = CGRectMake1(temp.frame.origin.x, temp.frame.origin.y, temp.frame.size.width, temp.frame.size.height);
        for (UIView *temp1 in temp.subviews) {
            temp1.frame = CGRectMake1(temp1.frame.origin.x, temp1.frame.origin.y, temp1.frame.size.width, temp1.frame.size.height);
        }
    }
}

- (void)removeUserDefaut
{
    [USERDEFAULTS removeObjectForKey:USERDEFAULTS_JINGTUM_KEY];
    [USERDEFAULTS removeObjectForKey:USERDEFAULTS_JINGTUM_SECRT];
    [USERDEFAULTS removeObjectForKey:USERDEFAULTS_JINGTUM_USERNAMEDECRYPT];
    [USERDEFAULTS removeObjectForKey:USERDEFAULTS_JINGTUM_USERSESSION];
    [USERDEFAULTS removeObjectForKey:USERDEFAULTS_JINGTUM_SHOPSURE];
    [USERDEFAULTS removeObjectForKey:USERDEFAULTS_JINGTUM_SHOPCARD];
    [USERDEFAULTS removeObjectForKey:USERDEFAULTS_JINGTUM_MARKER];
    [USERDEFAULTS removeObjectForKey:USERDEFAULTS_JINGTUM_USERSURE];
    [USERDEFAULTS synchronize];

}

-(void)setmainview
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    if (SCREEN_HEIGHT == 480)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard_iphone@3.5" bundle:nil];
        UIViewController *targetVC = [storyboard instantiateInitialViewController];
        self.window.rootViewController = targetVC;
    }
    else if (SCREEN_HEIGHT >= 568)
    {
        UIStoryboard *storyboard_4 = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        UIViewController *targetVC = [storyboard_4 instantiateInitialViewController];
        self.window.rootViewController = targetVC;
    }
    
}


- (BOOL)application:(UIApplication *)application  handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url
                        wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:self];
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"applicationDidEnterBackground");
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    self.myTimer = [NSTimer  timerWithTimeInterval:5.0 target:self selector:@selector(addTime)userInfo:nil repeats:YES];
    [[NSRunLoop  currentRunLoop] addTimer:self.myTimer forMode:NSDefaultRunLoopMode];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"%@ will resign active", self);
    
}

- (void)addTime
{
    self.timer+=5;
    NSLog(@"应用进入后台->%ld",(long)self.timer);
}

-(void)refreshwalletview
{
    //建钱包页表
    if ([[UserDB shareInstance] deleteWallet])
    {
        NSLog(@"删除钱包页表成功");
    }
    [[UserDB shareInstance] createWalletTable];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAccountRefresh object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self.myTimer invalidate];
    NSLog(@"应用进入前台了");
    if (self.timer >= 300)
    {
        if (self.isGesture)
        {
            GestureSureViewController *gesVC=[[GestureSureViewController alloc] init];
            [self.window.rootViewController presentViewController:gesVC animated:YES completion:nil];
        }
    }
    [[JingtumJSManager shared] wrapperRegisterHandlerTransactionCallback];
    [self refreshwalletview];
    // Clear application badge when app launches
    application.applicationIconBadgeNumber = 0;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"通知" message:notification.alertBody delegate:nil cancelButtonTitle:@"好的" otherButtonTitles: nil];
    [alert show];
    application.applicationIconBadgeNumber = 0;
}


- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    
    NSString *pushToken = [[[[deviceToken description]
                             
                             stringByReplacingOccurrencesOfString:@"<" withString:@""]
                            
                            stringByReplacingOccurrencesOfString:@">" withString:@""]
                           
                           stringByReplacingOccurrencesOfString:@" " withString:@""] ;
    
    NSLog(@"deviceToken:%@",pushToken);
    
    [USERDEFAULTS setObject:pushToken forKey:JINGTUM_SAVETOKEN];

    
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

/**
 * Remote Notification Received while application was open.
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    NSLog(@"userInfo====%@",userInfo);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    NSLog(@"userInfo--->%@",userInfo);
    
    if (application.applicationState == UIApplicationStateActive)
    {
        if ([[userInfo objectForKey:@"type"] isEqualToString:@"errorLogin"])
        {
                NSString *messageStr=[NSString stringWithFormat:@"%@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]];
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:messageStr delegate:self cancelButtonTitle:@"重新登陆" otherButtonTitles:@"确定", nil];
                [alert show];
        }
        else
        {
            // 转换成一个本地通知，显示到通知栏，你也可以直接显示出一个alertView，只是那样稍显aggressive：）
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.userInfo = userInfo;
            localNotification.soundName = UILocalNotificationDefaultSoundName;
            localNotification.alertBody = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
            localNotification.fireDate = [NSDate date];
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        }
        
    }
    //    NSLog(@"badge==%@",[NSString stringWithFormat:@"%@",[[userInfo objectForKey:@"aps"]objectForKey:@"badge"]]);
    completionHandler(UIBackgroundFetchResultNewData);
}

#ifdef IOS8_SDK_AVAILABLE

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings

{
    [application registerForRemoteNotifications];
}

#endif

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0 || buttonIndex == 1)
    {
        [self setmainview];
    }
}

- (NSArray *)getcontract
{
    return [[UserDB shareInstance] findContracts];
}

//修改CGRectMake
CG_INLINE CGRect
CGRectMake1(CGFloat x, CGFloat y, CGFloat width, CGFloat height)
{
    AppDelegate *myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CGRect rect;
    rect.origin.x = x * myDelegate.autoSizeScaleX; rect.origin.y = y * myDelegate.autoSizeScaleY;
    rect.size.width = width * myDelegate.autoSizeScaleX; rect.size.height = height * myDelegate.autoSizeScaleY;
    return rect;
}

@end
