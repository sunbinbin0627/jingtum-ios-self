//
//  WebViewBridgeManager.h
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WebViewJavascriptBridge.h"
#import "NSObject+KJSerializer.h"
#import "RPContact.h"
#import "RPBlobData.h"
#import "RPWallet.h"
#import "RPHistory.h"
#import "RPNewTransaction.h"
#import "RPAmount.h"
#import "RPTrsut.h"
#import "RPCreatorder.h"
#import "RPShopcard.h"
#import "AFNetworking.h"
#import <sqlite3.h>
#import "AppDelegate.h"
#import "UserDB.h"
#import "Reachability.h"
#import "SVProgressHUD.h"

@class WebViewJavascriptBridge, RPBlobData,RPAccountData;

@interface JingtumJSManager : NSObject {
    UIWebView               * _webView;
    WebViewJavascriptBridge * _bridge;
    
    BOOL _isConnected;
    BOOL _isLoggedIn;
    
    RPBlobData       * _blobData;
    NSMutableArray   * _contacts;
    
    AFHTTPRequestOperationManager * _operationManager;
    sqlite3 *db;//sqlite 数据库对象
    NSDateFormatter *formatter;//时间
    
    BOOL isExistenceNetwork;
    
    NSNumber *loginNum;


}

+(JingtumJSManager*)shared;

- (void)isConnectionAvailable;

-(BOOL)isConnected;
-(NSString*)jingtumWalletAddress;
-(NSString*)jingtumWalletSecrt;
-(NSArray*)jingtumContacts;
-(NSString *)jingtumUserName;
-(NSString *)jingtumUserNameDecrypt;
-(NSDictionary*)jingtumSession;
@end
