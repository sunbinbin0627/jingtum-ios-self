//
//  JingtumJSManager+AccountLines.m
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "JingtumJSManager+AccountLines.h"

@implementation JingtumJSManager (AccountLines)

-(void)wrapperAccountLines
{
    NSDictionary * params = @{@"account": _blobData.account_id,
                              @"secret": _blobData.master_seed};
    
    [_bridge callHandler:@"account_lines" data:params responseCallback:^(id responseData) {
//        NSLog(@"accountLines response: %@", responseData);
        if ([responseData isKindOfClass:[NSDictionary class]] && ![responseData objectForKey:@"error"])
        {
            
            NSMutableDictionary *shopcardDict=[[NSMutableDictionary alloc] init];
            NSMutableArray *shopArr=[[NSMutableArray alloc] init];
            for (NSDictionary *dict in [responseData objectForKey:@"lines"])
            {
                NSString *str=[NSString stringWithFormat:@"%.2f",[dict[@"balance"] floatValue]];
                if ([dict[@"currency"] isEqualToString:@"CNY"])
                {
                    str=[NSString stringWithFormat:@"%.2f",[dict[@"balance"] floatValue]];
                    
                    RPWallet *rpwall=[RPWallet new];
                    rpwall.type=@"CNY";
                    rpwall.num=str;
                    rpwall.key=@"111111";
                    rpwall.image=@"wallet_CNY.png";
                    rpwall.title=@"CNY(人民币)";
                    if ([[UserDB shareInstance] addWallet:rpwall])
                    {
                        NSLog(@"添加CNY余额到数据库成功");
                    }
                    else
                    {
                        NSLog(@"添加CNY余额到数据库失败");
                    }
                    [USERDEFAULTS setObject:str forKey:USERDEFAULTS_JINGTUM_CNY];
                    
                }
                else if ([dict[@"currency"] isEqualToString:@"USD"])
                {
                    
                    str=[NSString stringWithFormat:@"%.2f",[dict[@"balance"] floatValue]];
                    
                    RPWallet *rpwall=[RPWallet new];
                    rpwall.type=@"USD";
                    rpwall.num=str;
                    rpwall.key=@"222222";
                    rpwall.image=@"wallet_USD.png";
                    rpwall.title=@"USD(美元)";
                    if ([[UserDB shareInstance] addWallet:rpwall])
                    {
                        NSLog(@"添加USD余额到数据库成功");
                    }
                    else
                    {
                        NSLog(@"添加USD余额到数据库失败");
                    }
                    
                }
                else
                {
                    [shopArr addObject:dict[@"currency"]];
                    [shopcardDict setObject:dict[@"balance"] forKey:dict[@"currency"]];

                }
            }
            [USERDEFAULTS setObject:shopcardDict  forKey:USERDEFAULTS_JINGTUM_SHOPCARD];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdatedBalance object:nil userInfo:nil];
            [self getShopCard:shopArr andBalance:shopcardDict];
            
            
        }
        else
        {
            NSString *message=[NSString stringWithFormat:@"错误:%@",[responseData objectForKey:@"error"]];
            if (![[responseData objectForKey:@"error"] isEqualToString:@"remoteError"])
            {
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
            
        }
        
    }];
}

- (void)getShopCard:(NSArray *)shopArray andBalance:(NSDictionary *)shopBalanceDict
{
    NSString * urlStr = [NSString stringWithFormat:@"%@/getSelectArrayCurrency",JINGTUM_SHOP];
    NSDictionary *dict=@{@"type":@"100",@"array":shopArray};
    [_operationManager POST:urlStr parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"获取卡包余额response->%@",responseObject);
        if ([[responseObject objectForKey:@"data"] isKindOfClass:[NSArray class]] && ![[responseObject objectForKey:@"data"] isEqual:@"<null>"] && [[responseObject objectForKey:@"data"] count]>0)
        {
            NSArray *dataarray=[responseObject objectForKey:@"data"];
            NSMutableArray *cardArr=[[NSMutableArray alloc] init];
            NSMutableDictionary *cardNameWithId=[[NSMutableDictionary alloc] init];
            for (NSDictionary *tmpDict in dataarray)
            {
                RPShopcard *rp=[RPShopcard new];
                rp.shopId=[tmpDict objectForKey:@"ID"];
                rp.shopName=[tmpDict objectForKey:@"name"];
                
                NSMutableArray *imageArr=[[NSMutableArray alloc] init];
                if ([tmpDict objectForKey:@"other"] && ![tmpDict[@"other"] isEqual:@"<null>"] && ![tmpDict[@"other"] isEqual:[NSNull null]] && ![tmpDict[@"other"] isEqual:@"[]"])
                {
                    NSData *data=[[tmpDict objectForKey:@"other"] dataUsingEncoding:NSUTF8StringEncoding];
                    NSArray *jsonArr=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                    for (NSDictionary *dictTmp in jsonArr)
                    {
                        NSString *imageStr=[NSString stringWithFormat:@"%@/%@r",JINGTUM_SHOP_OTHERPHOTO,dictTmp[@"name"]];
                        [imageArr addObject:imageStr];
                    }
                    
                }
                else
                {
                    NSString *imageStr=[NSString stringWithFormat:@"null"];
                    [imageArr addObject:imageStr];
                }
                
                rp.shopPhoto=imageArr;
                
                NSInteger timeNum=[[tmpDict objectForKey:@"projectPeriod"] integerValue];
                NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timeNum];
                NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
                rp.shopDate=confromTimespStr;
                
                NSArray *keys=[shopBalanceDict allKeys];
                for (NSString *key in keys)
                {
                    if ([key isEqualToString:[tmpDict objectForKey:@"ID"]])
                    {
                        rp.shopNum=[shopBalanceDict objectForKey:key];
                    }
                }
                
                [cardArr addObject:rp];
                [cardNameWithId setObject:[tmpDict objectForKey:@"name"] forKey:[tmpDict objectForKey:@"ID"]];
            }
            NSLog(@"cardNameWithId-->%@",cardNameWithId);
            [[NSUserDefaults standardUserDefaults] setObject:cardNameWithId forKey:USERDEFAULTS_JINGTUM_SHOPSURE];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdatedShopCard object:cardArr];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"获取卡包余额请求失败");
        [self isConnectionAvailable];
    }];
    
}

@end
