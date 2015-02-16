//
//  JingtumJSManager+AccountTx.m
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "JingtumJSManager+AccountTx.h"

@implementation JingtumJSManager (AccountTx)


-(void)wrapperAccountTx_transation:(NSString *)hash withBlock:(void(^)(id responseData))block
{
    //测试获取某一笔账单详情
    NSDictionary * params = @{@"account": _blobData.account_id,
                               @"secret": _blobData.master_seed,
                               
                               @"hash":hash
                               };
    
    [_bridge callHandler:@"tx_transation" data:params responseCallback:^(id responseData) {
//        NSLog(@"tx_transation-->%@",responseData);
            block(responseData);
    }];
}


// Last transactions
-(void)wrapperAccountTx
{
    
    NSDictionary * params = @{@"account": _blobData.account_id,
                              @"secret": _blobData.master_seed,
    
                              // accountTx
                              @"params": @{@"account": _blobData.account_id,
                                           @"ledger_index_min": [NSNumber numberWithInt:-1],
                                           @"limit": [NSNumber numberWithInt:MAX_TRANSACTIONS],
                                           @"marker":@""
                                           }
                              };

    [_bridge callHandler:@"account_tx" data:params responseCallback:^(id responseData) {
//        NSLog(@"account_tx response: %@", responseData);
       
        //创建历史账单表
        if ([[UserDB shareInstance] deleteHistory])
        {
            NSLog(@"删除账单页表成功");
        }
        [[UserDB shareInstance] createHistoryAccount];
        
        //获取当前时间
        NSDate * startDate = [[NSDate alloc] init];
        NSCalendar * chineseCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSUInteger unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit |
        NSSecondCalendarUnit | NSDayCalendarUnit  |
        NSMonthCalendarUnit | NSYearCalendarUnit;
        
        NSDateComponents * cps = [chineseCalendar components:unitFlags fromDate:startDate];
        NSUInteger month = [cps month];
        NSUInteger year = [cps year];
        NSString *yearNow=[NSString stringWithFormat:@"%lu",(unsigned long)year];
//        NSLog(@"month=%lu, year=%lu yearNow=%@",(unsigned long)month, (unsigned long)year,yearNow);
        
        NSArray *cataArr=@[@"SWT",@"CNY",@"USD"];
        NSMutableDictionary *allTesttxDict=[[NSMutableDictionary alloc] init];
        NSArray *contractArr=[self cellContract];
        
        if ([responseData isKindOfClass:[NSDictionary class]] && ![responseData objectForKey:@"error"])
        {
            //如果存在marker，说明还有更多历史账单，若没有marker字段说明账单已经全部拉取了。
            if ([responseData objectForKey:@"marker"])
            {
                NSDictionary *dict=[NSDictionary dictionaryWithDictionary:[responseData objectForKey:@"marker"]];
                [USERDEFAULTS setObject:dict forKey:USERDEFAULTS_JINGTUM_MARKER];
                
            }
            else
            {
                [USERDEFAULTS setObject:nil forKey:USERDEFAULTS_JINGTUM_MARKER];
            }

        
            if ([[responseData objectForKey:@"transactions"] count] != 0)
            {
                NSDictionary *shopDict=[USERDEFAULTS objectForKey:USERDEFAULTS_JINGTUM_SHOPSURE];
                //钱包页下拉账单总和
                NSMutableArray *testArr=[[NSMutableArray alloc] init];
                
                for (NSDictionary *dict in [responseData objectForKey:@"transactions"])
                {
                    
                    //钱包页下拉账单
                    NSMutableDictionary *testAllpaymentDict=[[NSMutableDictionary alloc] init];
                    NSMutableDictionary *testDict=[[NSMutableDictionary alloc] init];
                    
                    NSString *historyTypeStr,*historyAccounttypeStr,*historyAccountresultStr,*historyImageStr,*historyMessageStr,*historyPriceStr,*historyKeyStr,*historyDetailtimeStr,*historyMonthtimeStr,*historyMonthdayStr,*historyAddressStr,*historyHashStr;
                    
                    NSDictionary *tx=[dict objectForKey:@"tx"];
                    
                    //保存hash值
                    historyHashStr=[tx objectForKey:@"hash"];
                    
                    //保存date时间
                    NSInteger timeNum=[JINGTUM_TIME integerValue]+[tx[@"date"] integerValue];
                    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timeNum];
                    NSString *tempTimeStr=[formatter stringFromDate:confromTimesp];
                    
                    //1保存月份
                    NSArray *jsonarray=[tempTimeStr componentsSeparatedByString:@" "];
                    NSArray *jsonarray2=[[jsonarray objectAtIndex:0] componentsSeparatedByString:@"-"];
                    NSString *yearStr=[jsonarray2 objectAtIndex:0];
                    NSString *monthStr=[jsonarray2 objectAtIndex:1];
                    historyMonthtimeStr=[NSString stringWithFormat:@"%@",monthStr];
                    
                    //2修改时间加8小时,保存具体时间。
                    NSArray *hourStr=[[jsonarray objectAtIndex:1] componentsSeparatedByString:@":"];
                    NSString *firstStr=[hourStr objectAtIndex:0];
                    NSString *secondStr=[hourStr objectAtIndex:1];
                    NSString *middleStr;
                    middleStr=[NSString stringWithFormat:@"%ld",[firstStr integerValue]+ [JINGTUM_TIMER_ADD integerValue]];
                    if (middleStr.length == 1)
                    {
                        middleStr=[NSString stringWithFormat:@"0%ld",[firstStr integerValue]+ [JINGTUM_TIMER_ADD integerValue]];
                    }
                    NSString *confromTimespStr=[NSString stringWithFormat:@"%@ %@:%@",[jsonarray objectAtIndex:0],middleStr,secondStr];
                    if ([yearStr isEqualToString:yearNow])
                    {
                        historyDetailtimeStr=[confromTimespStr substringFromIndex:5];
                    }
                    else
                    {
                        historyDetailtimeStr=confromTimespStr;
                    }
                    
                    //3保存那一年，那一个月
                    historyMonthdayStr=[NSString stringWithFormat:@"%@%@",[jsonarray2 objectAtIndex:0],[jsonarray2 objectAtIndex:1]];
                    
                    if ([tx[@"Account"] isEqualToString:[[JingtumJSManager shared] jingtumWalletAddress]])
                    {
                        
                        NSDictionary *meta=[dict objectForKey:@"meta"];
                        NSString *TransactionResult=[meta objectForKey:@"TransactionResult"];
                        if ([TransactionResult isEqualToString:@"tesSUCCESS"])
                        {
                            
                            if ([tx[@"TransactionType"] isEqualToString:@"Payment"])
                            {
                                
                                historyAddressStr=[NSString stringWithFormat:@"%@",tx[@"Destination"]];
                                //判断历史账单里的钱包地址是否是已有联系人
                                NSString *historyaddressStr=[[tx[@"Destination"] substringWithRange:NSMakeRange(0,6)] stringByAppendingString:JINGTUM_HISTORY_STAR];
                                for (RPContact *conTmp in contractArr)
                                {
                                    if ([tx[@"Destination"] isEqualToString:conTmp.fid])
                                    {
                                        historyaddressStr=conTmp.fname;
                                    }
                                }
                                
                                if ([[tx objectForKey:@"Amount"] isKindOfClass:[NSString class]])
                                {
                                    NSString *tmpStr=[NSString stringWithFormat:@"%.2f",[tx[@"Amount"] longLongValue]*0.000001];
                                    
                                    //保存账单里的内容到数据库中
                                    historyMessageStr=[NSString stringWithFormat:@"你向%@发送SWT",historyaddressStr];
                                    historyPriceStr=[NSString stringWithFormat:@"-%@",tmpStr];
                                    historyAccounttypeStr=@"send";
                                    historyTypeStr=@"SWT";
                                    historyImageStr=@"wallet_SWT.png";
                                    historyAccountresultStr=@"交易成功";
                                    historyKeyStr=@"0000";
                                    
                                    [testDict setObject:historyaddressStr forKey:@"contract"];
                                    [testDict setObject:historyPriceStr forKey:@"price"];
                                    [testDict setObject:@"send" forKey:@"payment"];
                                    [testAllpaymentDict setObject:testDict forKey:@"SWT"];
                                    [testArr addObject:testAllpaymentDict];
                                    
                                }
                                else
                                {
                                    NSString *tmpStr=[NSString stringWithFormat:@"%@",tx[@"Amount"][@"value"]];
                                    NSString *cataStr=[NSString stringWithFormat:@"%@",tx[@"Amount"][@"currency"]];
                                    historyPriceStr=[NSString stringWithFormat:@"-%.2f",[tmpStr floatValue]];
                                    historyMessageStr=[NSString stringWithFormat:@"你向%@发送%@",historyaddressStr,cataStr];
                                    if ([cataStr isEqualToString:@"CNY"] || [cataStr isEqualToString:@"USD"])
                                    {
                                        historyImageStr=[NSString stringWithFormat:@"wallet_%@.png",cataStr];
                                        
                                        [testDict setObject:historyaddressStr forKey:@"contract"];
                                        [testDict setObject:historyPriceStr forKey:@"price"];
                                        [testDict setObject:@"send" forKey:@"payment"];
                                        [testAllpaymentDict setObject:testDict forKey:cataStr];
                                        [testArr addObject:testAllpaymentDict];
                                    }
                                    else
                                    {
                                        historyImageStr=[NSString stringWithFormat:@"card.png"];
                                    }

                                    //保存账单里的内容到数据库中
                                    NSArray *keys=[shopDict allKeys];
                                    for (NSString *key in keys)
                                    {
                                        if ([cataStr isEqualToString:key])
                                        {
                                            cataStr=[NSString stringWithFormat:@"%@",[shopDict objectForKey:key]];
                                            historyMessageStr=[NSString stringWithFormat:@"你向%@发送%@",historyaddressStr,cataStr];
                                        }
                                    }
                                    historyAccounttypeStr=@"send";
                                    historyAccountresultStr=@"交易成功";
                                    historyKeyStr=@"0000";
                                    historyTypeStr=cataStr;
                                    
                                }
                                
                            }
                            else if ([tx[@"TransactionType"] isEqualToString:@"OfferCreate"])
                            {
                                NSDictionary *getDict=[tx objectForKey:@"TakerPays"];
                                NSString *tmpStr=[NSString stringWithFormat:@"%.2f",[[getDict objectForKey:@"value"] floatValue]];
                                NSString *currrencyStr=[NSString stringWithFormat:@"%@",[getDict objectForKey:@"currency"]];
                                
                                NSArray *keys=[shopDict allKeys];
                                for (NSString *key in keys)
                                {
                                    if ([currrencyStr isEqualToString:key])
                                    {
                                        currrencyStr=[NSString stringWithFormat:@"%@",[shopDict objectForKey:key]];
                                    }
                                }
                                
                                historyAddressStr=[tx objectForKey:@"Account"];
                                historyMessageStr=[NSString stringWithFormat:@"你已成功购买%@",currrencyStr];
                                historyPriceStr=[NSString stringWithFormat:@"+%@",tmpStr];
                                historyAccounttypeStr=@"shopbuy";
                                historyTypeStr=currrencyStr;
                                historyImageStr=@"card.png";
                                historyAccountresultStr=@"交易成功";
                                historyKeyStr=@"1111";
                                
                                NSString *buyShopValue;
                                [testDict setObject:@"janxMd..." forKey:@"contract"];
                                [testDict setObject:@"send" forKey:@"payment"];
                                if ([[tx objectForKey:@"TakerGets"] isKindOfClass:[NSString class]])
                                {
                                    buyShopValue=[NSString stringWithFormat:@"-%.2f",[[tx objectForKey:@"TakerGets"] floatValue]*0.000001];
                                    [testDict setObject:buyShopValue forKey:@"price"];
                                    [testAllpaymentDict setObject:testDict forKey:@"SWT"];
                                }
                                else if ([[tx objectForKey:@"TakerGets"] isKindOfClass:[NSDictionary class]])
                                {
                                    buyShopValue=[NSString stringWithFormat:@"-%.2f",[[[tx objectForKey:@"TakerGets"] objectForKey:@"value"] floatValue]];
                                    [testDict setObject:buyShopValue forKey:@"price"];
                                    [testAllpaymentDict setObject:testDict forKey:[[tx objectForKey:@"TakerGets"] objectForKey:@"currency"]];
                                }
                                [testArr addObject:testAllpaymentDict];
                                
                                
                            }

                        }
                    }
                    
                    
                    else if ([tx[@"Destination"] isEqualToString:[[JingtumJSManager shared] jingtumWalletAddress]])
                    {
                        NSDictionary *meta=[dict objectForKey:@"meta"];
                        NSString *TransactionResult=[meta objectForKey:@"TransactionResult"];
                        if ([TransactionResult isEqualToString:@"tesSUCCESS"])
                        {
                            
                            if ([tx[@"TransactionType"] isEqualToString:@"Payment"])
                            {
                                historyAddressStr=[NSString stringWithFormat:@"%@",tx[@"Account"]];
                                //判断历史账单里的钱包地址是否是已有联系人
                                NSString *historyaddressStr=[[tx[@"Account"] substringWithRange:NSMakeRange(0,6)] stringByAppendingString:JINGTUM_HISTORY_STAR];
                                for (RPContact *conTmp in contractArr)
                                {
                                    if ([tx[@"Account"] isEqualToString:conTmp.fid])
                                    {
                                        historyaddressStr=conTmp.fname;
                                    }
                                }
                                if ([[tx objectForKey:@"Amount"] isKindOfClass:[NSString class]])
                                {
                                    
                                    NSString *tmpStr=[NSString stringWithFormat:@"%.2f",[tx[@"Amount"] longLongValue]*0.000001];
                                    
                                    //保存账单里的内容到数据库中
                                    historyMessageStr=[NSString stringWithFormat:@"%@向你发送SWT",historyaddressStr];
                                    historyPriceStr=[NSString stringWithFormat:@"+%@",tmpStr];
                                    historyAccounttypeStr=@"receive";
                                    historyTypeStr=@"SWT";
                                    historyImageStr=@"wallet_SWT.png";
                                    historyAccountresultStr=@"交易成功";
                                    historyKeyStr=@"1111";
                                    
                                    [testDict setObject:historyaddressStr forKey:@"contract"];
                                    [testDict setObject:historyPriceStr forKey:@"price"];
                                    [testDict setObject:@"receive" forKey:@"payment"];
                                    [testAllpaymentDict setObject:testDict forKey:@"SWT"];
                                    [testArr addObject:testAllpaymentDict];
                                    
                                }
                                else
                                {
                                    
                                    NSString *tmpStr=[NSString stringWithFormat:@"%@",tx[@"Amount"][@"value"]];
                                    NSString *cataStr=[NSString stringWithFormat:@"%@",tx[@"Amount"][@"currency"]];
                                    
                                    //保存账单里的内容到数据库中
                                    historyMessageStr=[NSString stringWithFormat:@"%@向你发送%@",historyaddressStr,cataStr];
                                    historyPriceStr=[NSString stringWithFormat:@"+%.2f",[tmpStr floatValue]];
                                    historyAccounttypeStr=@"receive";
                                    historyTypeStr=cataStr;
                                    if ([cataStr isEqualToString:@"CNY"] || [cataStr isEqualToString:@"USD"])
                                    {
                                        historyImageStr=[NSString stringWithFormat:@"wallet_%@.png",cataStr];
                                    }
                                    else
                                    {
                                        NSArray *keys=[shopDict allKeys];
                                        for (NSString *key in keys)
                                        {
                                            if ([cataStr isEqualToString:key])
                                            {
                                                cataStr=[NSString stringWithFormat:@"%@",[shopDict objectForKey:key]];
                                                historyMessageStr=[NSString stringWithFormat:@"%@向你发送%@",historyaddressStr,cataStr];
                                            }
                                        }
                                        historyImageStr=[NSString stringWithFormat:@"card.png"];
                                    }
                                    historyAccountresultStr=@"交易成功";
                                    historyKeyStr=@"1111";
                                    
                                    [testDict setObject:historyaddressStr forKey:@"contract"];
                                    [testDict setObject:historyPriceStr forKey:@"price"];
                                    [testDict setObject:@"receive" forKey:@"payment"];
                                    [testAllpaymentDict setObject:testDict forKey:historyTypeStr];
                                    [testArr addObject:testAllpaymentDict];
                                }
                            }
                        }
                        
                    }
                    
                    if (historyMessageStr != nil  && historyPriceStr != nil && historyTypeStr != nil)
                    {
                        RPHistory *rpHistory=[RPHistory new];
                        rpHistory.type=historyTypeStr;
                        rpHistory.accountType=historyAccounttypeStr;
                        rpHistory.accountResult=historyAccountresultStr;
                        rpHistory.image=historyImageStr;
                        rpHistory.price=historyPriceStr;
                        rpHistory.message=historyMessageStr;
                        rpHistory.key=historyKeyStr;
                        rpHistory.detailTime=historyDetailtimeStr;
                        rpHistory.mounthTime=historyMonthtimeStr;
                        rpHistory.mounthDay=historyMonthdayStr;
                        rpHistory.address=historyAddressStr;
                        rpHistory.hash=historyHashStr;
                        
//                        NSLog(@"%@ %@ %@ %@ %@ %@ %@ %@ %@ %@ %@ %@",rpHistory.type,rpHistory.accountType,rpHistory.accountResult,rpHistory.image,rpHistory.price,rpHistory.message,rpHistory.key,rpHistory.detailTime,rpHistory.mounthTime,rpHistory.mounthDay,rpHistory.address,rpHistory.hash);
                        if ([[UserDB shareInstance] addHistory:rpHistory])
                        {
                            NSLog(@"插入历史账单成功");
                        }
                        
                    }
                }
                
//                NSLog(@"testArr-->%@",testArr);
                //添加下拉账单并按币种分类
                for (NSString *tmpstr in cataArr)
                {
                    NSMutableArray *tmpArr=[[NSMutableArray alloc] init];
                    for (NSDictionary *dict in testArr)
                    {
                        NSArray *keys=[dict allKeys];
                        NSString *keyStr=[keys objectAtIndex:0];
                        if ([keyStr isEqualToString:tmpstr])
                        {
                            [tmpArr addObject:[dict objectForKey:keyStr]];
                            
                        }
                    }
                    if (tmpArr.count != 0)
                    {
//                        tmpArr = (NSMutableArray *)[[tmpArr reverseObjectEnumerator] allObjects];
                        [allTesttxDict setObject:tmpArr forKey:tmpstr];
                    }
                }
                
//                NSLog(@"allTesttxDict-->%@",allTesttxDict);
                //发出通知，更新钱包页的币种下拉账单
                [USERDEFAULTS setObject:allTesttxDict forKey:USERDEFAULTS_JINGTUM_XIALA];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdatedBalanceList object:nil userInfo:nil];
            }
            //发出通知，更新历史账单
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdatedAccountTx object:@"1"];
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

-(void)wrapperMoreAccountTx
{
    
    
    NSDictionary *markerDict=[USERDEFAULTS objectForKey:USERDEFAULTS_JINGTUM_MARKER];
    if (markerDict)
    {
        NSDictionary * params = @{@"account": _blobData.account_id,
                                  @"secret": _blobData.master_seed,
                                  
                                  // accountTx
                                  @"params": @{@"account": _blobData.account_id,
                                               @"ledger_index_min": [NSNumber numberWithInt:-1],
                                               @"limit": [NSNumber numberWithInt:50],
                                               @"marker":markerDict
                                               }
                                  };
        
        [_bridge callHandler:@"account_tx" data:params responseCallback:^(id responseData) {
//            NSLog(@"account_tx response: %@", responseData);
            
            NSArray *contractArr=[self cellContract];
            
            if ([responseData isKindOfClass:[NSDictionary class]] && ![responseData objectForKey:@"error"])
            {
                //如果存在marker，说明还有更多历史账单，若没有marker字段说明账单已经全部拉取了。
                if ([responseData objectForKey:@"marker"])
                {
                    NSDictionary *dict=[NSDictionary dictionaryWithDictionary:[responseData objectForKey:@"marker"]];
                    [USERDEFAULTS setObject:dict forKey:USERDEFAULTS_JINGTUM_MARKER];
                    
                }
                else
                {
                    [USERDEFAULTS setObject:nil forKey:USERDEFAULTS_JINGTUM_MARKER];
                }

                
                if ([[responseData objectForKey:@"transactions"] count] != 0)
                {
                    //获取当前时间
                    NSDate * startDate = [[NSDate alloc] init];
                    NSCalendar * chineseCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                    NSUInteger unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit |
                    NSSecondCalendarUnit | NSDayCalendarUnit  |
                    NSMonthCalendarUnit | NSYearCalendarUnit;
                    
                    NSDateComponents * cps = [chineseCalendar components:unitFlags fromDate:startDate];
                    NSUInteger month = [cps month];
                    NSUInteger year = [cps year];
                    NSString *yearNow=[NSString stringWithFormat:@"%lu",(unsigned long)year];
//                    NSLog(@"month=%lu, year=%lu yearNow=%@",(unsigned long)month, (unsigned long)year,yearNow);
                    
                    NSDictionary *shopDict=[USERDEFAULTS objectForKey:USERDEFAULTS_JINGTUM_SHOPSURE];
                    
                    for (NSDictionary *dict in [responseData objectForKey:@"transactions"])
                    {
                        
                        NSString *historyTypeStr,*historyAccounttypeStr,*historyAccountresultStr,*historyImageStr,*historyMessageStr,*historyPriceStr,*historyKeyStr,*historyDetailtimeStr,*historyMonthtimeStr,*historyMonthdayStr,*historyAddressStr,*historyHashStr;
                        
                        NSDictionary *tx=[dict objectForKey:@"tx"];
                        
                        //保存hash值
                        historyHashStr=[tx objectForKey:@"hash"];
                        
                        //保存date时间
                        NSInteger timeNum=[JINGTUM_TIME integerValue]+[tx[@"date"] integerValue];
                        NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timeNum];
                        NSString *tempTimeStr=[formatter stringFromDate:confromTimesp];
                        
                        //1保存月份
                        NSArray *jsonarray=[tempTimeStr componentsSeparatedByString:@" "];
                        NSArray *jsonarray2=[[jsonarray objectAtIndex:0] componentsSeparatedByString:@"-"];
                        NSString *yearStr=[jsonarray2 objectAtIndex:0];
                        NSString *monthStr=[jsonarray2 objectAtIndex:1];
                        historyMonthtimeStr=[NSString stringWithFormat:@"%@",monthStr];
                        
                        //2修改时间加8小时,保存具体时间。
                        NSArray *hourStr=[[jsonarray objectAtIndex:1] componentsSeparatedByString:@":"];
                        NSString *firstStr=[hourStr objectAtIndex:0];
                        NSString *secondStr=[hourStr objectAtIndex:1];
                        NSString *middleStr;
                        middleStr=[NSString stringWithFormat:@"%ld",[firstStr integerValue]+ [JINGTUM_TIMER_ADD integerValue]];
                        if (middleStr.length == 1)
                        {
                            middleStr=[NSString stringWithFormat:@"0%ld",[firstStr integerValue]+ [JINGTUM_TIMER_ADD integerValue]];
                        }
                        NSString *confromTimespStr=[NSString stringWithFormat:@"%@ %@:%@",[jsonarray objectAtIndex:0],middleStr,secondStr];
                        if ([yearStr isEqualToString:yearNow])
                        {
                            historyDetailtimeStr=[confromTimespStr substringFromIndex:5];
                        }
                        else
                        {
                            historyDetailtimeStr=confromTimespStr;
                        }
                        
                        //3保存那一年，那一个月
                        historyMonthdayStr=[NSString stringWithFormat:@"%@%@",[jsonarray2 objectAtIndex:0],[jsonarray2 objectAtIndex:1]];
                        
                        if ([tx[@"Account"] isEqualToString:[[JingtumJSManager shared] jingtumWalletAddress]])
                        {
                            
                            NSDictionary *meta=[dict objectForKey:@"meta"];
                            NSString *TransactionResult=[meta objectForKey:@"TransactionResult"];
                            if ([TransactionResult isEqualToString:@"tesSUCCESS"])
                            {
                                
                                if ([tx[@"TransactionType"] isEqualToString:@"Payment"])
                                {
                                    
                                    historyAddressStr=[NSString stringWithFormat:@"%@",tx[@"Destination"]];
                                    //判断历史账单里的钱包地址是否是已有联系人
                                    NSString *historyaddressStr=[[tx[@"Destination"] substringWithRange:NSMakeRange(0,6)] stringByAppendingString:JINGTUM_HISTORY_STAR];
                                    for (RPContact *conTmp in contractArr)
                                    {
                                        if ([tx[@"Destination"] isEqualToString:conTmp.fid])
                                        {
                                            historyaddressStr=conTmp.fname;
                                        }
                                    }
                                    
                                    if ([[tx objectForKey:@"Amount"] isKindOfClass:[NSString class]])
                                    {
                                        NSString *tmpStr=[NSString stringWithFormat:@"%.2f",[tx[@"Amount"] longLongValue]*0.000001];
                                        
                                        //保存账单里的内容到数据库中
                                        historyMessageStr=[NSString stringWithFormat:@"你向%@发送SWT",historyaddressStr];
                                        historyPriceStr=[NSString stringWithFormat:@"-%@",tmpStr];
                                        historyAccounttypeStr=@"send";
                                        historyTypeStr=@"SWT";
                                        historyImageStr=@"wallet_SWT.png";
                                        historyAccountresultStr=@"交易成功";
                                        historyKeyStr=@"0000";
                                        
                                    }
                                    else
                                    {
                                        NSString *tmpStr=[NSString stringWithFormat:@"%@",tx[@"Amount"][@"value"]];
                                        NSString *cataStr=[NSString stringWithFormat:@"%@",tx[@"Amount"][@"currency"]];
                                        //保存账单里的内容到数据库中
                                        NSArray *keys=[shopDict allKeys];
                                        for (NSString *key in keys)
                                        {
                                            if ([cataStr isEqualToString:key])
                                            {
                                                cataStr=[NSString stringWithFormat:@"%@",[shopDict objectForKey:key]];
                                            }
                                        }
                                        
                                        historyMessageStr=[NSString stringWithFormat:@"你向%@发送%@",historyaddressStr,cataStr];
                                        historyPriceStr=[NSString stringWithFormat:@"-%.2f",[tmpStr floatValue]];
                                        historyAccounttypeStr=@"send";
                                        historyTypeStr=cataStr;
                                        if ([cataStr isEqualToString:@"CNY"] || [cataStr isEqualToString:@"USD"])
                                        {
                                            historyImageStr=[NSString stringWithFormat:@"wallet_%@.png",cataStr];
                                        }
                                        else
                                        {
                                            historyImageStr=[NSString stringWithFormat:@"card.png"];
                                        }
                                        historyAccountresultStr=@"交易成功";
                                        historyKeyStr=@"0000";
                                        
                                    }
                                    
                                }
                                else if ([tx[@"TransactionType"] isEqualToString:@"OfferCreate"])
                                {
                                    NSDictionary *getDict=[tx objectForKey:@"TakerPays"];
                                    NSString *tmpStr=[NSString stringWithFormat:@"%.2f",[[getDict objectForKey:@"value"] floatValue]];
                                    NSString *currrencyStr=[NSString stringWithFormat:@"%@",[getDict objectForKey:@"currency"]];
                                    
                                    NSArray *keys=[shopDict allKeys];
                                    for (NSString *key in keys)
                                    {
                                        if ([currrencyStr isEqualToString:key])
                                        {
                                            currrencyStr=[NSString stringWithFormat:@"%@",[shopDict objectForKey:key]];
                                        }
                                    }
                                    
                                    historyAddressStr=[tx objectForKey:@"Account"];
                                    historyMessageStr=[NSString stringWithFormat:@"你已成功购买%@",currrencyStr];
                                    historyPriceStr=[NSString stringWithFormat:@"+%@",tmpStr];
                                    historyAccounttypeStr=@"shopbuy";
                                    historyTypeStr=currrencyStr;
                                    historyImageStr=@"card.png";
                                    historyAccountresultStr=@"交易成功";
                                    historyKeyStr=@"1111";
                                    
                                    
                                    
                                }
                                
                            }
                        }
                        
                        
                        else if ([tx[@"Destination"] isEqualToString:[[JingtumJSManager shared] jingtumWalletAddress]])
                        {
                            NSDictionary *meta=[dict objectForKey:@"meta"];
                            NSString *TransactionResult=[meta objectForKey:@"TransactionResult"];
                            if ([TransactionResult isEqualToString:@"tesSUCCESS"])
                            {
                                
                                if ([tx[@"TransactionType"] isEqualToString:@"Payment"])
                                {
                                    historyAddressStr=[NSString stringWithFormat:@"%@",tx[@"Account"]];
                                    //判断历史账单里的钱包地址是否是已有联系人
                                    NSString *historyaddressStr=[[tx[@"Account"] substringWithRange:NSMakeRange(0,6)] stringByAppendingString:JINGTUM_HISTORY_STAR];
                                    for (RPContact *conTmp in contractArr)
                                    {
                                        if ([tx[@"Account"] isEqualToString:conTmp.fid])
                                        {
                                            historyaddressStr=conTmp.fname;
                                        }
                                    }
                                    if ([[tx objectForKey:@"Amount"] isKindOfClass:[NSString class]])
                                    {
                                        
                                        NSString *tmpStr=[NSString stringWithFormat:@"%.2f",[tx[@"Amount"] longLongValue]*0.000001];
                                        
                                        //保存账单里的内容到数据库中
                                        historyMessageStr=[NSString stringWithFormat:@"%@向你发送SWT",historyaddressStr];
                                        historyPriceStr=[NSString stringWithFormat:@"+%@",tmpStr];
                                        historyAccounttypeStr=@"receive";
                                        historyTypeStr=@"SWT";
                                        historyImageStr=@"wallet_SWT.png";
                                        historyAccountresultStr=@"交易成功";
                                        historyKeyStr=@"1111";
                                        
                                    }
                                    else
                                    {
                                        
                                        NSString *tmpStr=[NSString stringWithFormat:@"%@",tx[@"Amount"][@"value"]];
                                        NSString *cataStr=[NSString stringWithFormat:@"%@",tx[@"Amount"][@"currency"]];
                                        
                                        //保存账单里的内容到数据库中
                                        historyMessageStr=[NSString stringWithFormat:@"%@向你发送%@",historyaddressStr,cataStr];
                                        historyPriceStr=[NSString stringWithFormat:@"+%.2f",[tmpStr floatValue]];
                                        historyAccounttypeStr=@"receive";
                                        historyTypeStr=cataStr;
                                        if ([cataStr isEqualToString:@"CNY"] || [cataStr isEqualToString:@"USD"])
                                        {
                                            historyImageStr=[NSString stringWithFormat:@"wallet_%@.png",cataStr];
                                        }
                                        else
                                        {
                                            NSArray *keys=[shopDict allKeys];
                                            for (NSString *key in keys)
                                            {
                                                if ([cataStr isEqualToString:key])
                                                {
                                                    cataStr=[NSString stringWithFormat:@"%@",[shopDict objectForKey:key]];
                                                    historyMessageStr=[NSString stringWithFormat:@"%@向你发送%@",historyaddressStr,cataStr];
                                                }
                                            }
                                            historyImageStr=[NSString stringWithFormat:@"card.png"];
                                        }
                                        
                                        historyAccountresultStr=@"交易成功";
                                        historyKeyStr=@"1111";
                                        
                                    }
                                }
                            }
                            
                        }
                        
                        if (historyMessageStr != nil  && historyPriceStr != nil && historyTypeStr != nil)
                        {
                            RPHistory *rpHistory=[RPHistory new];
                            rpHistory.type=historyTypeStr;
                            rpHistory.accountType=historyAccounttypeStr;
                            rpHistory.accountResult=historyAccountresultStr;
                            rpHistory.image=historyImageStr;
                            rpHistory.price=historyPriceStr;
                            rpHistory.message=historyMessageStr;
                            rpHistory.key=historyKeyStr;
                            rpHistory.detailTime=historyDetailtimeStr;
                            rpHistory.mounthTime=historyMonthtimeStr;
                            rpHistory.mounthDay=historyMonthdayStr;
                            rpHistory.address=historyAddressStr;
                            rpHistory.hash=historyHashStr;
                            
                            //                        NSLog(@"%@ %@ %@ %@ %@ %@ %@ %@ %@ %@ %@",rpHistory.type,rpHistory.accountType,rpHistory.accountResult,rpHistory.image,rpHistory.price,rpHistory.message,rpHistory.key,rpHistory.detailTime,rpHistory.mounthTime,rpHistory.mounthDay,rpHistory.address);
                            if ([[UserDB shareInstance] addHistory:rpHistory])
                            {
                                NSLog(@"插入历史账单成功");
                            }
                            
                        }
                    }
                    
                }
                //发出通知，更新历史账单
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdatedAccountTx object:@"1"];
            }
            else
            {
                NSString *message=[NSString stringWithFormat:@"错误:%@",[responseData objectForKey:@"error"]];
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
            
        }];
    }
    else
    {
        //发出通知，没有更多账单纪录
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdatedAccountTx object:@"0"];
    }
}


- (NSArray *)cellContract
{
    return [NSMutableArray arrayWithArray:[[UserDB shareInstance] findContracts]];
    
}

@end
