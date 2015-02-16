//
//  JingtumJSManager+SendTransaction.m
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "JingtumJSManager+SendTransaction.h"
#import "JingtumJSManager+NetworkStatus.h"

@implementation JingtumJSManager (SendTransaction)

-(NSError *)checkForErrorResponse:(NSDictionary*)responseData
{
    NSError * error;
    if (responseData && [responseData isKindOfClass:[NSDictionary class]]) {
        // Check for jingtum-lib error
        NSNumber * returnCode = [responseData objectForKey:@"engine_result_code"];
        if (returnCode.integerValue != 0) {
            // Could not send transaction
            NSString * errorMessage = [responseData objectForKey:@"engine_result_message"];
            error = [NSError errorWithDomain:@"send_transaction" code:1 userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
        }
        
        
        // Check for wrapper error
        NSString * errorMessage = [responseData objectForKey:@"error"];
        if (errorMessage) {
            error = [NSError errorWithDomain:@"send_transaction" code:1 userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
        }
    }
    return error;
}

-(void)wrapperSendTransactionAmount:(RPNewTransaction*)transaction withBlock:(void(^)(NSError* error))block
{
    /*
    {
        "engine_result" = "tecUNFUNDED_PAYMENT";
        "engine_result_code" = 104;
        "engine_result_message" = "Insufficient XRP balance to send.";
        "tx_blob" = 1200002200000000240000000861400000E8D4A5100068400000000000000A73210376BA4EAE729354BED97E26A03AEBA6FB9078BBBB1EAB590772734BCE42E82CD574473045022100D95DA3C853A9C0E048290E142887163B24263ED4A2538F24DC44852E45273D1F0220551C62788BA3A5E35356B8377821916989C3A34AC4E120069EC2F7DC0655B6338114B4037480188FA0DD8DC61DC57791C94A940CF1F083142B56FFC66587C6ECF125506A599C0BD9D376430D;
        "tx_json" =     {
            Account = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
            Amount = 1000000000000;
            Destination = rhxwHhfMhySyYB5Wrq7ohSNBqBfAYanAAx;
            Fee = 10;
            Flags = 0;
            Sequence = 8;
            SigningPubKey = 0376BA4EAE729354BED97E26A03AEBA6FB9078BBBB1EAB590772734BCE42E82CD5;
            TransactionType = Payment;
            TxnSignature = 3045022100D95DA3C853A9C0E048290E142887163B24263ED4A2538F24DC44852E45273D1F0220551C62788BA3A5E35356B8377821916989C3A34AC4E120069EC2F7DC0655B633;
            hash = 42C46F9F0F95E70ABB3AE0B47A7B83F02C07B5F58385F7FE17400A3CE655E780;
        };
    }
    
    
    {
        "engine_result" = tesSUCCESS;
        "engine_result_code" = 0;
        "engine_result_message" = "The transaction was applied.";
        "tx_blob" = 120000220000000024000000096140000000000F424068400000000000000A73210376BA4EAE729354BED97E26A03AEBA6FB9078BBBB1EAB590772734BCE42E82CD5744730450221009AA1970167D0E241DFE58EBC34214F70FCE3E76B98C42FA0575C635AB823D1B6022004C7D8195895F5EBE3BB71D39AE9E26517376FC1F7413E0B2BD3CD794A71B2AB8114B4037480188FA0DD8DC61DC57791C94A940CF1F083142B56FFC66587C6ECF125506A599C0BD9D376430D;
        "tx_json" =     {
            Account = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
            Amount = 1000000;
            Destination = rhxwHhfMhySyYB5Wrq7ohSNBqBfAYanAAx;
            Fee = 10;
            Flags = 0;
            Sequence = 9;
            SigningPubKey = 0376BA4EAE729354BED97E26A03AEBA6FB9078BBBB1EAB590772734BCE42E82CD5;
            TransactionType = Payment;
            TxnSignature = 30450221009AA1970167D0E241DFE58EBC34214F70FCE3E76B98C42FA0575C635AB823D1B6022004C7D8195895F5EBE3BB71D39AE9E26517376FC1F7413E0B2BD3CD794A71B2AB;
            hash = 0A86E4DD55686ECBB000B2699D9A8D8C0FF0FD1C6DCB7246C18FD03538D79E72;
        };
    }
    
     */
    
    if (!transaction || !transaction.to_address || !_blobData) {
        NSError * error = [NSError errorWithDomain:@"send_transaction" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Invalid amount"}];
        block(error);
        return;
    }
    
    NSNumberFormatter *formatter1 = [NSNumberFormatter new];
    [formatter1 setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
    [formatter1 setMaximumFractionDigits:20];
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:
                               @{@"account": _blobData.account_id,
                              @"to_address": transaction.to_address,
                              @"to_currency": transaction.to_currency,
                              @"to_amount": [transaction.to_amount stringValue], // [formatter stringFromNumber:transaction.to_amount],
                              @"from_currency": transaction.from_currency,
                              @"secret": _blobData.master_seed
                               }];
    
    // Add path
    transaction.path ? [params setObject:transaction.path forKey:@"path"]: nil;
    
    [_bridge callHandler:@"send_transaction" data:params responseCallback:^(id responseData) {
        NSLog(@"send_transaction response: %@", responseData);
        NSError * error = [self checkForErrorResponse:responseData];
        block(error);
    }];
}


-(void)wrapperFindPathWithAmount:(NSDecimalNumber*)amount currency:(NSString*)currency toRecipient:(NSString*)recipient withBlock:(void(^)(NSArray * paths, NSError* error))block
{
    /*
    {
        alternatives =     (
                            {
                                "paths_canonical" =             (
                                );
                                "paths_computed" =             (
                                                                (
                                                                 {
                                                                     account = rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B;
                                                                     currency = USD;
                                                                     issuer = rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B;
                                                                     type = 49;
                                                                     "type_hex" = 0000000000000031;
                                                                 },
                                                                 {
                                                                     currency = XRP;
                                                                     type = 16;
                                                                     "type_hex" = 0000000000000010;
                                                                 }
                                                                 )
                                                                );
                                "source_amount" =             {
                                    currency = USD;
                                    issuer = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                    value = "0.03408163265306123";
                                };
                            }
                            );
        "destination_account" = rhxwHhfMhySyYB5Wrq7ohSNBqBfAYanAAx;
        "destination_currencies" =     (
                                        XRP
                                        );
        "ledger_current_index" = 1365182;
    }
     */
//    
//    NSNumberFormatter *formatter = [NSNumberFormatter new];
//    [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
//    [formatter setMaximumFractionDigits:20];
//
    
    NSDictionary * params = @{@"account": _blobData.account_id,
                              @"recipient_address": recipient,
                              @"currency": currency,
                              @"amount": [amount stringValue],
                              @"secret": _blobData.master_seed
                              };
    
    [_bridge callHandler:@"find_path_currencies" data:params responseCallback:^(id responseData) {
        NSLog(@"find_path_currencies response: %@", responseData);
        NSError * error = [self checkForErrorResponse:responseData];
        NSMutableArray * paths;
        if (!error) {
            paths = [NSMutableArray array];
            for (NSDictionary * path in responseData) {
                RPAmount * obj = [[RPAmount alloc] initWithObject:path];
                [paths addObject:obj];
            }
            
            if ([currency isEqualToString:GLOBAL_XRP_STRING]) {
                RPAmount * obj = [RPAmount new];
                obj.from_currency = GLOBAL_XRP_STRING;
                obj.from_amount = amount;
                [paths addObject:obj];
            }
        }
        block(paths, error);
    }];
}

-(void)wrapperIsValidAccount:(NSString*)account withBlock:(void(^)(NSError* error))block
{
    [_bridge callHandler:@"is_valid_account" data:@{@"account": account} responseCallback:^(id responseData) {
        NSLog(@"is_valid_account response: %@", responseData);
        NSError * error;
        NSString * errorMessage = [responseData objectForKey:@"error"];
        if (errorMessage) {
            error = [NSError errorWithDomain:@"send_transaction" code:1 userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
        }
        block(error);
    }];
}



//法币的交易
-(void)wrapperSendSubmit:(RPNewTransaction*)transaction withBlock:(void(^)(NSError* error))block
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:
                                    @{@"account": _blobData.account_id,
                                      @"to_issuer": transaction.to_issuer,
                                      @"to_address": transaction.to_address,
                                      @"to_currency": transaction.to_currency,
                                      @"to_amount": [transaction.to_amount stringValue], // [formatter stringFromNumber:transaction.to_amount],
                                      @"from_currency": transaction.from_currency,
                                      @"secret": _blobData.master_seed
                                      }];

//    NSLog(@"params-->%@",params);
    [_bridge callHandler:@"send_submit" data:params responseCallback:^(id responseData) {
        NSLog(@"send_submit response: %@", responseData);
        NSError * error = [self checkForErrorResponse:responseData];
        if (!error)
        {
//            NSDate *senddate=[NSDate date];
//            NSString *locationString=[formatter stringFromDate:senddate];
            NSArray *contacts=[self getcontract];
//            NSLog(@"locationString:%@",locationString);
            NSDictionary *tmpDict=[responseData objectForKey:@"tx_json"];
            NSString *oppoAddress=[NSString stringWithFormat:@"%@",tmpDict[@"Destination"]];
            NSString *selfAddress=[NSString stringWithFormat:@"%@",tmpDict[@"Account"]];
            NSString *selfNotfitionStr,*oppositeNotifitionStr;
            NSString *tmpAddress=[NSString stringWithFormat:@"%@",tmpDict[@"Destination"]];
            for (RPContact *rpCon in contacts)
            {
                if ([rpCon.fid isEqualToString:oppoAddress])
                {
                    tmpAddress=[NSString stringWithFormat:@"%@",rpCon.fname];
                }
            }
            
            if ([tmpDict[@"Amount"] isKindOfClass:[NSString class]])
            {
                oppoAddress=[NSString stringWithFormat:@"%@",tmpDict[@"Destination"]];
                selfAddress=[NSString stringWithFormat:@"%@",tmpDict[@"Account"]];
                NSString *price=[NSString stringWithFormat:@"%.2f",[tmpDict[@"Amount"] longLongValue]*0.000001];
                selfNotfitionStr=[NSString stringWithFormat:@"你已成功向%@发送了%@SWT",tmpAddress,price];
                oppositeNotifitionStr=[NSString stringWithFormat:@"%@向你发送%@SWT",selfAddress,price];
//                NSLog(@"%@ %@",selfNotfitionStr,oppositeNotifitionStr);
                
//                NSDictionary *selfdict=@{@"type":@"send",@"value":price,@"currency":@"SWT",@"address":oppoAddress,@"time":locationString,@"selfAddress":_blobData.account_id};
//                NSDictionary *oppodict=@{@"type":@"receive",@"value":price,@"currency":@"SWT",@"address":selfAddress,@"time":locationString,@"selfAddress":oppoAddress};
                
                NSDictionary *selfdict=@{@"type":@"send"};
                NSDictionary *oppodict=@{@"type":@"receive"};
                
                [self afnetWorkContent:selfNotfitionStr andAddress:oppoAddress andContent:oppositeNotifitionStr andSelfPlayLoad:selfdict andoppoPlayload:oppodict];
                
                
            }
            else
            {
                NSString *oppoAddress=[NSString stringWithFormat:@"%@",tmpDict[@"Destination"]];
                NSString *selfAddress=[NSString stringWithFormat:@"%@",tmpDict[@"Account"]];
                NSString *price2=tmpDict[@"Amount"][@"value"];
                NSString *cata=tmpDict[@"Amount"][@"currency"];
                selfNotfitionStr=[NSString stringWithFormat:@"你已成功向%@发送了%@%@",tmpAddress,price2,cata];
                oppositeNotifitionStr=[NSString stringWithFormat:@"%@向你发送%@%@",selfAddress,price2,cata];
//                NSLog(@"%@ %@",selfNotfitionStr,oppositeNotifitionStr);
                
//                NSDictionary *selfdict=@{@"type":@"send",@"value":price2,@"currency":cata,@"address":oppoAddress,@"time":locationString,@"selfAddress":_blobData.account_id};
//                NSDictionary *oppodict=@{@"type":@"receive",@"value":price2,@"currency":cata,@"address":selfAddress,@"time":locationString,@"selfAddress":oppoAddress};
                NSDictionary *selfdict=@{@"type":@"send"};
                NSDictionary *oppodict=@{@"type":@"receive"};
                
                [self afnetWorkContent:selfNotfitionStr andAddress:oppoAddress andContent:oppositeNotifitionStr andSelfPlayLoad:selfdict andoppoPlayload:oppodict];
                
                
            }
            
        }        
        block(error);
        
    }];
    
}

//发送用户通的交易
-(void)wrapperSendShop:(RPNewTransaction*)transaction withBlock:(void(^)(NSError* error))block
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:
                                    @{@"account": _blobData.account_id,
                                      @"to_issuer": transaction.to_issuer,
                                      @"to_address": transaction.to_address,
                                      @"to_currency": transaction.to_currency,
                                      @"to_amount": [transaction.to_amount stringValue], // [formatter stringFromNumber:transaction.to_amount],
                                      @"from_currency": transaction.from_currency,
                                      @"secret": _blobData.master_seed
                                      }];
    
//    NSLog(@"params-->%@",params);
    [_bridge callHandler:@"send_submit" data:params responseCallback:^(id responseData) {
        NSLog(@"send_submit response: %@", responseData);
        NSError * error = [self checkForErrorResponse:responseData];
        if (!error)
        {
//            NSDate *senddate=[NSDate date];
//            NSString *locationString=[formatter stringFromDate:senddate];
            NSArray *contacts=[self getcontract];
//            NSLog(@"locationString:%@",locationString);
            NSDictionary  *shopdict= [USERDEFAULTS objectForKey:USERDEFAULTS_JINGTUM_SHOPSURE];
            
            NSDictionary *tmpDict=[responseData objectForKey:@"tx_json"];
            NSString *numStr=[NSString stringWithFormat:@"%@",tmpDict[@"Amount"][@"value"]];
            NSString *oppositeAddress=[NSString stringWithFormat:@"%@",tmpDict[@"Destination"]];
            NSString *selfAddress=[NSString stringWithFormat:@"%@",tmpDict[@"Account"]];
            NSString *shopname;
            NSArray *keys=[shopdict allKeys];
            for (NSString *key in keys)
            {
                if ([key isEqualToString:tmpDict[@"Amount"][@"currency"]])
                {
                    shopname=[shopdict objectForKey:key];
                }
            }
            NSString *tmpAddress=[NSString stringWithFormat:@"%@",tmpDict[@"Destination"]];
            for (RPContact *rpCon in contacts)
            {
                if ([rpCon.fid isEqualToString:oppositeAddress])
                {
                    tmpAddress=[NSString stringWithFormat:@"%@",rpCon.fname];
                }
            }
            
//            NSString *currencyStr=[NSString stringWithFormat:@"%@",tmpDict[@"Amount"][@"currency"]];
            NSString *selfNotifitionStr=[NSString stringWithFormat:@"你向%@发送了%@份%@",tmpAddress,numStr,shopname];
            NSString *oppositeNotifitionStr=[NSString stringWithFormat:@"%@向你发送了%@份%@",selfAddress,numStr,shopname];
//            NSDictionary *selfdict=@{@"address":oppositeAddress,@"type":@"shopsend",@"value":numStr,@"currency":currencyStr,@"selfAddress":_blobData.account_id,@"shopname":shopname,@"time":locationString};
//            NSDictionary *oppodict=@{@"address":selfAddress,@"type":@"shopreceive",@"value":numStr,@"currency":currencyStr,@"selfAddress":oppositeAddress,@"shopname":shopname,@"time":locationString};
            
            NSDictionary *selfdict=@{@"type":@"shopsend"};
            NSDictionary *oppodict=@{@"type":@"shopreceive"};
            
            [self afnetWorkContent:selfNotifitionStr andAddress:oppositeAddress andContent:oppositeNotifitionStr andSelfPlayLoad:selfdict andoppoPlayload:oppodict];
            
        }
        else
        block(error);
    }];
}

//设置信任
-(void)setTrust:(RPTrsut *)transaction withBlock:(void(^)(NSError* error))block
{
    //添加trust
    NSDictionary * params = @{@"selfAddress": _blobData.account_id,
                              @"address": JINGTUM_ISSURE,
                              @"currency":transaction.currency,
                              @"amount":transaction.amount,
                              @"allowrippling":transaction.allowrippling,
                              @"account":_blobData.account_id,
                              @"secret":_blobData.master_seed
                              };

//    NSLog(@"params-->%@",params);
    [_bridge callHandler:@"set_trust" data:params responseCallback:^(id responseData) {
        NSLog(@"set_trust response: %@", responseData);
        NSError * error = [self checkForErrorResponse:responseData];
        block(error);
    }];
}

//创建挂单，购买用户通
-(void)offcreate:(RPCreatorder *)transaction withBlock:(void(^)(NSError* error))block
{
    
    NSDictionary * params = @{@"account": _blobData.account_id,
                               @"sell_currency": transaction.sell_currency,//美甲券
                               @"buy_currency": transaction.buy_currency,//易宝CNY
                               @"amount": transaction.amount,//数量
                               @"actualTotal":transaction.actualTotal,//总额
                               @"issuer":JINGTUM_ISSURE,
                               @"flag":transaction.flag,
                               @"secret": _blobData.master_seed
                               };
//    NSLog(@"params-->%@",params);
    [_bridge callHandler:@"off_create" data:params responseCallback:^(id responseData) {
        NSLog(@"off_create response: %@", responseData);
        NSError * error = [self checkForErrorResponse:responseData];
        if (!error)
        {
        }
        block(error);
    }];
    
}

//发送tips
- (void)afnetWorkContent:(NSString *)content andAddress:(NSString *)tempAddress andContent:(NSString *)tmpContent andSelfPlayLoad:(NSDictionary *)selfTmpPlayLoad andoppoPlayload:(NSDictionary *)oppoTmpPlayLoad
{
    
    NSString *urlStr = [NSString stringWithFormat:JINGTUM_TIPS_SEVER];
    NSArray *arr=@[@{@"address":[[JingtumJSManager shared] jingtumWalletAddress],@"content":content,@"payload":selfTmpPlayLoad},
                   @{@"address":tempAddress,@"content":tmpContent,@"payload":oppoTmpPlayLoad}];
    
    [[JingtumJSManager shared] operationManagerPOST:urlStr parameters:arr withBlock:^(NSString *error, id responseData) {
        
        NSLog(@"发送tipsResponse->%@",responseData);
        [self isConnectionAvailable];
        
    }];
    
}

//查询挂单量（库存量）
-(void)book_offers:(NSDictionary *)transaction withBlock:(void(^)(id responseData))block
{
    
    NSDictionary * params = @{@"gets":@{@"issuer":JINGTUM_ISSURE,@"currency":[transaction objectForKey:@"gets"]},
                               @"pays":@{@"issuer":JINGTUM_ISSURE,@"currency":[transaction objectForKey:@"pays"]}
                                  };
//        NSLog(@"-=>%@",params);
        [_bridge callHandler:@"book_offers" data:params responseCallback:^(id responseData) {
            NSLog(@"book_offers response: %@", responseData);
            NSError * error = [self checkForErrorResponse:responseData];
            if (!error)
            {
                block(responseData);
            }
            else
            {
                NSLog(@"error:%@",error.localizedDescription);
//                NSString *message=[NSString stringWithFormat:@"失败:%@",error.localizedDescription];
//                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//                [alert show];
                
            }

        }];
}

- (NSArray *)getcontract
{
    return [[UserDB shareInstance] findContracts];
}



@end
