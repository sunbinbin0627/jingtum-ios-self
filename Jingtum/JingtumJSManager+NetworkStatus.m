//
//  JingtumJSManager+NetworkStatus.m
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "JingtumJSManager+NetworkStatus.h"

@implementation JingtumJSManager (NetworkStatus)

-(void)wrapperRegisterBridgeHandlersNetworkStatus
{
    // Connected to Jingtum network
    [_bridge registerHandler:@"connected" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"connected called: %@", data);
        _isConnected = YES;
        
    }];
    
    // Disconnected from Jingtum network
    [_bridge registerHandler:@"disconnected" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"disconnected called: %@", data);
        [self isConnectionAvailable];
        [SVProgressHUD dismiss];
        _isConnected = NO;
    }];
}


//获得配置信息
- (void)getAllocationInfomation
{
    
    NSString * urlStr = [NSString stringWithFormat:@"%@/api/index",JINGTUM_URL];
    [_operationManager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //            NSLog(@"获取配置信息->%@",responseObject);
        if ([[responseObject objectForKey:@"ack"] isEqual:@1])
        {
            NSString *gatewayStr=[responseObject objectForKey:@"GatewayAddress"];
            NSString *middleAccount=[responseObject objectForKey:@"MiddleAddress"];
            NSString *middleSecret=[responseObject objectForKey:@"MiddleSecret"];
            
            [[NSUserDefaults standardUserDefaults] setObject:gatewayStr forKey:USERDEFAULTS_JINGTUM_ISSURE];
            [[NSUserDefaults standardUserDefaults] setObject:middleAccount forKey:USERDEFAULTS_JINGTUM_MIDDLEADDRESS];
            [[NSUserDefaults standardUserDefaults] setObject:middleSecret forKey:USERDEFAULTS_JINGTUM_MIDDLESECRET];
        }
        else
        {
            NSLog(@"获取配置信息失败");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"获取配置信息请求失败");
    }];
    
}

//发送get请求
-(void)operationManagerGET:(NSString *)url parameters:(id )params withBlock:(void(^)(NSString *error, id responseData))block
{
    [_operationManager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        block(@"0", responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(@"1",@"failed");
        [self isConnectionAvailable];
//        NSLog(@"get请求失败");
    }];
}


//发送post请求
-(void)operationManagerPOST:(NSString *)url parameters:(id )params withBlock:(void(^)(NSString *error, id responseData))block
{
    
//    _operationManager.responseSerializer=[AFHTTPResponseSerializer serializer];
//    [_operationManager.requestSerializer setValue:[USERDEFAULTS objectForKey:JINGTUM_COOKIE] forHTTPHeaderField:@"Cookie"];
    [_operationManager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
//        NSString *str=[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"postResponse->%@",str);
        block(@"0",responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        block(@"1",@"failed");
        [self isConnectionAvailable];
//        NSLog(@"post请求失败");
    }];
    /*
    
    NSError *error;
    NSMutableURLRequest *request = [_operationManager.requestSerializer requestWithMethod:@"POST" URLString:url parameters:params error:&error];
    
    NSArray *availCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage]cookiesForURL:[NSURL URLWithString:[NSString stringWithFormat:JINGTUM_URL]]];
    NSLog(@"avail cookie-->%@", availCookies);
    NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:availCookies];
    
    [request setAllHTTPHeaderFields:headers];
    AFHTTPRequestOperation *operation = [_operationManager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *responseStr=[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"postResponse->%@",responseStr);
        NSDictionary *postDict=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        block(@"0",postDict);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(@"1",@"failed");
//        NSLog(@"post请求失败");
        
    }];
    
    [_operationManager.operationQueue addOperation:operation];
     */
}



@end
