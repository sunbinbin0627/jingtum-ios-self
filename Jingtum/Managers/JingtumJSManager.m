//
//  WebViewBridgeManager.m
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "JingtumJSManager.h"
#import "JingtumJSManager+Initializer.h"
#import "JingtumJSManager+Authentication.h"
#import "JingtumJSManager+NetworkStatus.h"
#import "JingtumJSManager+AccountInfo.h"
#import "JingtumJSManager+AccountLines.h"
#import "JingtumJSManager+AccountTx.h"
#import "JingtumJSManager+TransactionCallback.h"

@interface JingtumJSManager ()

@end

@implementation JingtumJSManager

-(NSString*)jingtumWalletAddress
{
    return [self account_id];
}
-(NSString *)jingtumWalletSecrt
{
    return [self master_seed];
}
-(NSString *)jingtumUserName
{
    return [self username];
}

-(NSString *)jingtumUserNameDecrypt
{
    return [self usernamedecrypt];
}

-(NSArray*)jingtumContacts
{
    return _contacts;
}

-(NSDictionary*)jingtumSession
{
    return [self userSession];
}

-(BOOL)isConnected
{
    return _isConnected;
}

-(void)connect
{
    
    [_bridge callHandler:@"connect" data:@"" responseCallback:^(id responseData){
    }];
}

-(void)disconnect
{
    // Disconnect from Jingtum server
    [_bridge callHandler:@"disconnect" data:@"" responseCallback:^(id responseData) {
    }];
}

-(void)updateAccountInformation
{
    if (_isLoggedIn) {
        [self wrapperSubscribeTransactions];
        [self wrapperAccountInfo];            // Get SWT balance
        [self wrapperAccountLines];           // Get USD CNY balances
        [self wrapperAccountTx];              // Get Last transactions
        
    }
}

- (void)userLoggedIn
{
    [self updateAccountInformation];
}

- (void)userLoggedOut:(NSNotification *) notification
{
//    NSString *str=[notification userInfo];
//    NSLog(@"str--->%@",str);
}


#pragma mark - 判断有没有网络

- (void)isConnectionAvailable
{
    BOOL isNetWork=NO;
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
        {
            isNetWork=YES;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络状态" message:@"没有网络，请检查网路" delegate:nil cancelButtonTitle:@"返回" otherButtonTitles:nil];
            [alert show];
            break;
        }
        case ReachableViaWiFi:
            break;
        case ReachableViaWWAN:
            break;
            
    }
    if (!isNetWork)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"服务器错误,请稍后再试" delegate:nil cancelButtonTitle:@"返回" otherButtonTitles:nil];
        [alert show];
    }
    
}

+(JingtumJSManager*)shared
{
    static JingtumJSManager * shared;
    if (!shared) {
        shared = [JingtumJSManager new];
    }
    return shared;
}

- (id)init
{
    self = [super init];
    if (self) {
        _isConnected = NO;
        _isLoggedIn = NO;
        isExistenceNetwork=NO;
        
        //时间戳转时间的方法
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setTimeZone:[NSTimeZone systemTimeZone]];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jingtumNetworkConnected) name:kNotificationJingtumConnected object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jingtumNetworkDisconnected) name:kNotificationJingtumDisconnected object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoggedIn) name:kNotificationUserLoggedIn object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoggedOut:) name:kNotificationUserLoggedOut object:nil];
//
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAccountInformation) name:kNotificationAccountRefresh object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTx) name:kNotificationRefreshTx object:nil];
        
        [self wrapperInitialize];
        [self wrapperRegisterBridgeHandlersNetworkStatus];
        [self wrapperRegisterHandlerTransactionCallback];
 
        
        _operationManager = [AFHTTPRequestOperationManager manager];
        _operationManager.responseSerializer=[AFJSONResponseSerializer serializer];
        _operationManager.requestSerializer=[AFJSONRequestSerializer serializer];
        
        
        [self connect];
//        [self getAllocationInfomation];
        
        
        // Check if loggedin
//        [self checkForLogin];

//#warning Testing purposes
//        NSDictionary * params = [[NSUserDefaults standardUserDefaults] objectForKey:@"transaction"];
//        [_bridge callHandler:@"test_transaction" data:params responseCallback:^(id responseData) {
//            NSLog(@"test_transaction response: %@", responseData);
//            
//        }];
    }
    return self;
}




@end
