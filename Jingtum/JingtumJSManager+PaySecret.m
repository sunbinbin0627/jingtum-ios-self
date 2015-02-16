//
//  JingtumJSManager+PaySecret.m
//  Jingtum
//
//  Created by sunbinbin on 15-2-5.
//  Copyright (c) 2015年 OpenCoin Inc. All rights reserved.
//

#import "JingtumJSManager+PaySecret.h"
#import "NSString+Hashes.h"

@implementation JingtumJSManager (PaySecret)

//设置支付密码
-(void)setPaySecret:(NSDictionary *)secretDict withBlock:(void(^)(id responseData))block
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/setTransactionPassword",GLOBAL_BLOB_VAULT];
    NSString *url = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSString *secretStr=[NSString stringWithFormat:@"%@",[[secretDict objectForKey:@"secret"] sha256]];
    NSDictionary *dict=@{@"account":[[JingtumJSManager shared] jingtumUserNameDecrypt],@"transactionPassword":secretStr,@"transactionPasswordFlag":[secretDict objectForKey:@"flag"]};
    
    [_operationManager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        block(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self isConnectionAvailable];
    }];

}


//确认支付密码
-(void)VerifyPaySecret:(NSString *)secret withBlock:(void(^)(id responseData))block
{
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/checkTransactionPassword",GLOBAL_BLOB_VAULT];
    NSString *url = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSString *secretStr=[NSString stringWithFormat:@"%@",[secret sha256]];
    NSDictionary *dict=@{@"account":[[JingtumJSManager shared] jingtumUserNameDecrypt],@"transactionPassword":secretStr};
    
    [_operationManager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        block(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self isConnectionAvailable];
    }];
    
}



@end
