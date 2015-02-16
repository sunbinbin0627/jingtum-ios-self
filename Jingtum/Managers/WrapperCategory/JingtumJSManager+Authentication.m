//
//  JingtumJSManager+Authentication.m
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "JingtumJSManager+Authentication.h"
#import "NSString+Hashes.h"
//#import "SSKeychain.h"
#import "Base64.h"
#import "SVProgressHUD.h"
#import <sqlite3.h>
#import "Reachability.h"
#import "UserViewController.h"
#import "UserDB.h"
#import "RPContact.h"

@implementation JingtumJSManager (Authentication)

-(NSString*)account_id
{
    return [USERDEFAULTS objectForKey:USERDEFAULTS_JINGTUM_KEY];
}

-(NSString*)username
{
    return [USERDEFAULTS objectForKey:USERDEFAULTS_JINGTUM_USERNAME];
}

-(NSString *)master_seed
{
    return [USERDEFAULTS objectForKey:USERDEFAULTS_JINGTUM_SECRT];
}
-(NSString*)usernamedecrypt
{
    return [USERDEFAULTS objectForKey:USERDEFAULTS_JINGTUM_USERNAMEDECRYPT];
}
-(NSDictionary*)userSession
{
    return [USERDEFAULTS objectForKey:USERDEFAULTS_JINGTUM_USERSESSION];
}

-(void)login:(NSString*)username andPassword:(NSString*)password withBlock:(void(^)(NSError* error))block
{
    
    [SVProgressHUD showWithStatus:@"登录中..." maskType:SVProgressHUDMaskTypeGradient];
    
    NSLog(@"%@: Atempting to log in as: %@", self, username);
    
    // Normalize
    username = [username lowercaseString];
    
    NSString *beforeHash = [NSString stringWithFormat:@"%@",username];
    NSString *afterHash = [beforeHash sha256];
    NSLog(@"账号加密串：%@",afterHash);
    
    [USERDEFAULTS setObject:username forKey:USERDEFAULTS_JINGTUM_USERNAME];
    [USERDEFAULTS setObject:afterHash forKey:USERDEFAULTS_JINGTUM_USERNAMEDECRYPT];
    
    NSString *path = [NSString stringWithFormat:@"%@/login",GLOBAL_BLOB_VAULT];
    NSLog(@"登录url-->%@",path);
    NSString *tokenStr=[USERDEFAULTS objectForKey:JINGTUM_SAVETOKEN];
    NSDictionary *dict11=@{@"key":afterHash};//,@"token":tokenStr,@"userType":@"1"};
//    NSLog(@"dict11-->%@",dict11);
    
    [_operationManager.operationQueue cancelAllOperations];
    
    [_operationManager POST:path parameters:dict11 success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"responseObject->%@",responseObject);
        
        if ( [[responseObject objectForKey:@"data"] isKindOfClass:[NSDictionary class]] && [[[responseObject objectForKey:@"data"] objectForKey:@"message"] isEqualToString:@"您的账号已经在另一个手机上登录!"])
        {
            [SVProgressHUD dismiss];
            NSString *contentStr=[NSString stringWithFormat:@"您的账号在另一个手机上登陆,如非本人操作,请尽快修改密码"];
            NSString *address=[[responseObject objectForKey:@"data"] objectForKey:@"address"];
            NSDictionary *playLoad=@{@"type":@"errorLogin",@"selfAddress":address};
            [self afnetWorkAddress:address andContent:contentStr andPlayLoad:playLoad];
            NSString *phoneStr=[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"data"] objectForKey:@"mobilephone"]];
            [USERDEFAULTS setObject:phoneStr forKey:@"jingtumLoginPhone"];
            NSError * error = [NSError errorWithDomain:@"login" code:1 userInfo:@{NSLocalizedDescriptionKey: @"异地登陆"}];
            block(error);
        }
        else
        {
           NSDictionary *jsonDict=responseObject;
            
            //获取到登陆返回的信息，保存一些数据。
            if (![jsonDict[@"data"] isEqual:[NSNull null]] && jsonDict[@"data"] && ![jsonDict[@"data"] isEqualToString:@"[]"])
            {
//                    NSLog(@"123-->%@",jsonDict[@"data"]);
                NSDictionary *tempDict=[[NSDictionary alloc] init];
                NSData *data=[jsonDict[@"data"] dataUsingEncoding:NSUTF8StringEncoding];
                NSArray *arr=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                tempDict=arr[0];
                NSDictionary *userSessionDict=arr[1];
//                    NSLog(@"userSessionDict-->%@",userSessionDict);
                NSLog(@"tempDict->%@",tempDict);
                
                //保存支付密码的设置状态
                NSString *passwordFlag=[NSString stringWithFormat:@"%@",[tempDict objectForKey:@"transactionPasswordFlag"]];
                [USERDEFAULTS setObject:passwordFlag forKey:USERDEFAULTS_JINGTUM_PAYSECRET];
                
                //判断是否已经实名认证，若是则保存实名信息到本地
                NSString *loginname=[[NSString alloc]initWithFormat:@"%@",tempDict[@"name"]];
//                    NSLog(@"loginname-->%@",loginname);
                
                AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
                if ([loginname isEqualToString:@"<null>"])
                {
                    appdelegate.firstLogin=1;
                    
                }
                else
                {
                    if ([tempDict[@"type"] isEqual:@2])
                    {
                        NSMutableDictionary *userSure=[[NSMutableDictionary alloc] init];
                        NSString *nameStr=[NSString stringWithFormat:@"%@",tempDict[@"name"]];
                        NSString *sexStr=[NSString stringWithFormat:@"%@",tempDict[@"sex"]];
                        NSString *idStr=[NSString stringWithFormat:@"%@",tempDict[@"id"]];
                        NSString *nationStr=[NSString stringWithFormat:@"%@",tempDict[@"nation"]];
                        NSString *addressStr=[NSString stringWithFormat:@"%@",tempDict[@"address"]];
                        
                        [userSure setObject:nameStr forKey:@"name"];
                        [userSure setObject:sexStr forKey:@"sex"];
                        [userSure setObject:idStr forKey:@"id"];
                        [userSure setObject:nationStr forKey:@"nation"];
                        [userSure setObject:addressStr forKey:@"address"];
                        [USERDEFAULTS setObject:userSure forKey:USERDEFAULTS_JINGTUM_USERSURE];
                        
                    }
                }
                
                if (tempDict)
                {
                    //保存手机号
                    NSString *phoneStr=[NSString stringWithFormat:@"%@",[tempDict objectForKey:@"mobilephone"]];
                    [USERDEFAULTS setObject:phoneStr forKey:USERDEFAULTS_JINGTUM_PHONE];
                    
                    //保存最后一次登录时间
                    NSString *lastTime=[NSString stringWithFormat:@"%@",[tempDict objectForKey:@"lastregistertime"]];
//                        NSLog(@"lastTime->%@",lastTime);
                    NSInteger timeNum=[lastTime integerValue];
                    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timeNum];
                    [USERDEFAULTS setObject:confromTimesp forKey:USERDEFAULTS_JINGTUM_LASTLOGIN];
                    
                    
                    NSString * key = [NSString stringWithFormat:@"%lu|%@%@",(unsigned long)username.length,username,password];
//                        NSLog(@"%@: key: %@", self.class.description, key);
                    NSString *decryptStr=[tempDict objectForKey:@"secret"];
//                        NSLog(@"decryptStr-->%@",decryptStr);
                    
                
                    loginNum = [tempDict objectForKey:@"trylogintimes"];
                    
                    // 解密
                    [_bridge callHandler:@"sjcl_decrypt" data:@{@"key": key,@"decrypt": [decryptStr base64DecodedString]} responseCallback:^(id responseData) {
                        if (responseData && ![responseData isKindOfClass:[NSNull class]]) {
                            // 解密成功
                            
                            
                            [self testloginTime:afterHash andLoginTime:@1];
                            NSLog(@"New Blob: %@", responseData);
                            
                            //保存公钥和私钥
                            RPBlobData * blob = [RPBlobData new];
                            [blob setDictionary:responseData];
                            _blobData = blob;
                            NSString * wallet = _blobData.account_id;
                            NSString * seed = _blobData.master_seed;
                            
                            //获取联系人
                            NSString *urlStr=[NSString stringWithFormat:@"%@/contact?key=%@",GLOBAL_BLOB_VAULT,afterHash];
                            NSLog(@"联系人url--->%@",urlStr);
                            
                            [_operationManager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                
                                NSLog(@"获取联系人-->%@",responseObject);
                                NSString *tempStr=[NSString stringWithFormat:@"%@",responseObject[@"data"]];
                                NSData *data=[tempStr dataUsingEncoding:NSUTF8StringEncoding];
                                NSDictionary *jsonData=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                                NSLog(@"获取联系人成功--->%@",jsonData);
                                
                                //保存联系人到数据库中
                                NSArray * contacts = [jsonData objectForKey:@"friendlist"];
                                
                                for (NSDictionary * contactDic in contacts)
                                {
                                    RPContact * contact = [RPContact new];
                                    contact.fname=[contactDic objectForKey:@"fname"];
                                    contact.fid=[contactDic objectForKey:@"fid"];
                                    if ([[UserDB shareInstance] addContract:contact])
                                    {
                                        NSLog(@"插入成功");
                                        
                                    }
                                }
                                
                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"请求联系人失败");
                            }];
                            
                            [SVProgressHUD dismiss];
                            
                            //测试apple
//                            [self testApple];
                            
                            
                            // 保存公钥，私钥，用户名、用户名的加密串和session到本地存储
                            [USERDEFAULTS setObject:wallet forKey:USERDEFAULTS_JINGTUM_KEY];
                            [USERDEFAULTS setObject:seed forKey:USERDEFAULTS_JINGTUM_SECRT];
                            [USERDEFAULTS setObject:userSessionDict forKey:USERDEFAULTS_JINGTUM_USERSESSION];
                            [USERDEFAULTS synchronize];
                            
                            _isLoggedIn = YES;
                            block(nil);
                            if (appdelegate.firstLogin == 0)
                            {
                                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUserLoggedIn object:nil];
                            }
                           
                        }
                        else
                        {
                            // 解密失败
                            NSLog(@"解密失败: %@", responseData);
                            [SVProgressHUD dismiss];
                            NSString *errorStr=[NSString stringWithFormat:@"你今天还有%d次机会",5-[loginNum intValue]];
                            NSError * error = [NSError errorWithDomain:@"login" code:1 userInfo:@{NSLocalizedDescriptionKey: errorStr}];
                            [self logout];
                            block(error);
                            

                            NSInteger num=[loginNum integerValue];
                            num += 1;
                            NSNumber *loginnum=[NSNumber numberWithInteger:num];
//                                NSLog(@"loginnum->%@",loginnum);
                            [self testloginTime:afterHash andLoginTime:loginnum];
                            
                        }
                    }];
                }
                else
                {
                    [SVProgressHUD dismiss];
                    NSError * error = [NSError errorWithDomain:@"login" code:1 userInfo:@{NSLocalizedDescriptionKey: @"无效的用户名或密码"}];
                    [self logout];
                    block(error);
                }
                
            }
            else if ([jsonDict[@"error"] isKindOfClass:[NSDictionary class]] && [[jsonDict[@"error"] objectForKey:@"message"] isEqualToString:@"登录失败超过5次，用户被锁定"])
            {
                [SVProgressHUD dismiss];
                NSError * error = [NSError errorWithDomain:@"login" code:1 userInfo:@{NSLocalizedDescriptionKey:@"你已经输入密码错误5次，请明天再登陆."}];
                [self logout];
                block(error);

            }
            else
            {
                [SVProgressHUD dismiss];
                NSError * error = [NSError errorWithDomain:@"login" code:1 userInfo:@{NSLocalizedDescriptionKey: @"无效的用户名或密码"}];
                [self logout];
                block(error);
                
            }
            
        }

    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"登陆失败");
        [SVProgressHUD dismiss];
        [self isConnectionAvailable];
        [self logout];
    }];
    
}


- (void)testloginTime:(NSString *)username andLoginTime:(NSNumber *)loginTime
{
    
    NSString * urlStr = [NSString stringWithFormat:@"%@/setLoginAttempt",GLOBAL_BLOB_VAULT];
    NSDictionary *dict=@{@"key":username,@"trylogintimes":loginTime};
    
    [_operationManager POST:urlStr parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
//        NSDictionary *loginJson=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"失败登陆请求返回数据==>%@",responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
         NSLog(@"失败登陆请求失败");
    }];
    
}

- (void)afnetWorkAddress:(NSString *)address andContent:(NSString *)content andPlayLoad:(NSDictionary *)PlayLoad
{
    
    NSString * url = [NSString stringWithFormat:JINGTUM_TIPS_SEVER];
    NSLog(@"tips请求url-->%@",url);
    
    NSDictionary *dic = @{@"address":address,@"content":content,@"payload":PlayLoad};
    NSLog(@"dic-->%@",dic);
    [_operationManager POST:url parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSLog(@"tips请求返回数据==>%@",responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"tips请求失败");
    }];
}

- (void)testApple
{
    
    NSString * url = [NSString stringWithFormat:@"%@/test",GLOBAL_BLOB_VAULT];
    NSLog(@"测试审核保存token url-->%@",url);
    
    [_operationManager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"测试审核保存token返回数据==>%@",responseObject);
        if ([[responseObject objectForKey:@"data"] isEqual:@1])
        {
            [self savetoken];
        }
        else
        {
            NSLog(@"不需绑定");
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"测试审核保存token请求失败");
    }];
    
}

- (void)savetoken
{
    
    NSString *tokenStr=[USERDEFAULTS objectForKey:JINGTUM_SAVETOKEN];
    NSString * url = [NSString stringWithFormat:@"%@/saveUserToken",GLOBAL_BLOB_VAULT];
    NSLog(@"保存token url-->%@",url);
    
    NSDictionary *dict=@{@"userType":@"1",@"address":_blobData.account_id,@"token":tokenStr};
    NSLog(@"dict-->%@",dict);
    
    [_operationManager GET:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSLog(@"保存token返回数据==>%@",responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"保存token请求失败");

    }];
}


-(NSString*)returnUsername:(NSArray*)array
{
    for (NSDictionary* dic in array) {
        NSString * username = [dic objectForKey:@"acct"];
        if (username && [username isKindOfClass:[NSString class]]) {
            return username;
        }
    }
    return nil;
}

//-(void)checkForLogin
//{
//    NSArray * accounts = [SSKeychain allAccounts];
//    NSString * username = [self returnUsername:accounts];
//    if (username) {
//        NSString * password = [SSKeychain passwordForService:SSKEYCHAIN_SERVICE account:username];
//        if (username && password && username.length > 0 && password.length > 0) {
//            
//            [self login:username andPassword:password withBlock:^(NSError *error) {
//                
//            }];
//        }
//    }
//}
//
//-(BOOL)isLoggedIn
//{
//    NSArray * accounts = [SSKeychain allAccounts];
//    NSString * username = [self returnUsername:accounts];
//    if (username) {
//        return YES;
//    }
//    return NO;
//}

-(void)logout
{
    _isLoggedIn = NO;
    _blobData = nil;
    
    [_operationManager.operationQueue cancelAllOperations];
    
    AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    appdelegate.firstLogin=0;
    
//    NSArray * accounts = [SSKeychain allAccounts];
//    for (NSDictionary * dic in accounts) {
//        NSString * username = [dic objectForKey:@"acct"];
//        NSError * error;
//        [SSKeychain deletePasswordForService:SSKEYCHAIN_SERVICE account:username error:&error];
//        //NSLog(@"%@", error.localizedDescription);
//        
//    }
    
    //清空数据库中表里的内容
    if ([[UserDB shareInstance] deleteWallet])
    {
        NSLog(@"删除钱包页表成功");
    }
    if ([[UserDB shareInstance] deleteContract])
    {
        NSLog(@"删除联系人页表成功");
    }
    if ([[UserDB shareInstance] deleteHistory])
    {
        NSLog(@"删除账单页表成功");
    }
    
    //退出登录时删除本地存储的内容
    [USERDEFAULTS removeObjectForKey:USERDEFAULTS_JINGTUM_KEY];
//    [USERDEFAULTS removeObjectForKey:USERDEFAULTS_JINGTUM_USERNAME];
    [USERDEFAULTS removeObjectForKey:USERDEFAULTS_JINGTUM_SECRT];
    [USERDEFAULTS removeObjectForKey:USERDEFAULTS_JINGTUM_USERNAMEDECRYPT];
    [USERDEFAULTS removeObjectForKey:USERDEFAULTS_JINGTUM_USERSESSION];
    [USERDEFAULTS removeObjectForKey:USERDEFAULTS_JINGTUM_SHOPSURE];
    [USERDEFAULTS removeObjectForKey:USERDEFAULTS_JINGTUM_SHOPCARD];
    [USERDEFAULTS removeObjectForKey:USERDEFAULTS_JINGTUM_MARKER];
    [USERDEFAULTS removeObjectForKey:USERDEFAULTS_JINGTUM_USERSURE];
    [USERDEFAULTS synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUserLoggedOut object:nil];
    
}


@end
