//
//  JingtumJSManager+Authentication.h
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "JingtumJSManager.h"

@interface JingtumJSManager (Authentication)

-(void)login:(NSString*)username andPassword:(NSString*)password withBlock:(void(^)(NSError* error))block;
-(void)logout;

//-(BOOL)isLoggedIn;
//-(void)checkForLogin;

-(NSString*)account_id;
-(NSString*)master_seed;
-(NSString*)username;
-(NSString*)usernamedecrypt;
-(NSDictionary*)userSession;
@end
