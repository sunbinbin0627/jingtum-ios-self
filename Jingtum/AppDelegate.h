//
//  AppDelegate.h
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate>
{
    sqlite3 *db;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,assign) NSInteger firstLogin;
@property (nonatomic,assign) BOOL isGesture;
@property (nonatomic,assign) BOOL lastLogin;
@property (nonatomic,assign) BOOL isLoginSecret;
@property (nonatomic,assign) BOOL isWithdraw;

@property (nonatomic,strong) NSTimer *myTimer;
@property (nonatomic,assign) NSInteger timer;

@property float autoSizeScaleX;
@property float autoSizeScaleY;

+(void)storyBoradAutoLay:(UIView *)allView;
-(void)setmainview;

@end
    