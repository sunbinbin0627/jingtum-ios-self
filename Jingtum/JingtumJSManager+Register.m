//
//  JingtumJSManager+Register.m
//  Jingtum
//
//  Created by sunbinbin on 14-12-30.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "JingtumJSManager+Register.h"

@implementation JingtumJSManager (Register)

- (void)RegisterForAccountId:(id)tmpData withBlock:(void(^)(id responseData))block
{
     [_bridge callHandler:@"wallet_accountid" data:tmpData responseCallback:^(id responseData) {
//         NSLog(@"wallet_accountid:%@",responseData);
         block(responseData);
     }];

}

- (void)RegisterForMassterId:(NSString *)tmpData withBlock:(void(^)(id responseData))block
{
    [_bridge callHandler:@"wallet_master" data:tmpData responseCallback:^(id responseData) {
//        NSLog(@"wallet_master:%@",responseData);
        block(responseData);
    }];
}

- (void)RegisterEncrypt:(NSDictionary *)tmpDict withBlock:(void (^)(id responseData))block
{
    [_bridge callHandler:@"sjcl_encrypt" data:tmpDict responseCallback:^(id responseData) {
//        NSLog(@"sjcl_encrypt:%@",responseData);
        block(responseData);
    }];
}



@end
