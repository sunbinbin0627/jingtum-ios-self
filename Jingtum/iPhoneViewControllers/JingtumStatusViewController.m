//
//  JingtumStatusViewController.m
//  Jingtum
//
//  Created by Kevin Johnson on 7/24/13.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "JingtumStatusViewController.h"
#import "JingtumJSManager.h"

@interface JingtumStatusViewController () {
//    UILabel * labelStatus;
    
    BOOL  showingDisconnected;
}

@end

@implementation JingtumStatusViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        
        
    }
    return self;
}


-(void)JingtumJSManagerConnected
{
    showingDisconnected = NO;
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    else
    {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 0.0f;
        self.view.frame = f;
    } completion:^(BOOL finished) {
        
    }];
}
-(void)JingtumJSManagerDisconnected
{
    showingDisconnected = YES;
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    else
    {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 20.0f;
        self.view.frame = f;
    } completion:^(BOOL finished) {
        
    }];
}


// Add this method
- (BOOL)prefersStatusBarHidden {
    if (showingDisconnected) {
        return YES;
    }
    else {
        return NO;
    }
}


-(void)checkNetworkStatus
{
    if ([[JingtumJSManager shared] isConnected]) {
        [self JingtumJSManagerConnected];
    }
    else {
        [self JingtumJSManagerDisconnected];
    }
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (![[JingtumJSManager shared] isConnected]) {
        CGRect f = self.view.frame;
        f.origin.y = 20.0f;
        self.view.frame = f;
        
        showingDisconnected = YES;
    }
    else {
        showingDisconnected = NO;
    }
    
}

@end
