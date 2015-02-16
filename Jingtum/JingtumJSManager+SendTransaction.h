//
//  JingtumJSManager+SendTransaction.h
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "JingtumJSManager.h"

@interface JingtumJSManager (SendTransaction)

-(void)wrapperFindPathWithAmount:(NSNumber*)amount currency:(NSString*)currency toRecipient:(NSString*)recipient withBlock:(void(^)(NSArray * paths, NSError* error))block;
-(void)wrapperSendTransactionAmount:(RPNewTransaction*)transaction withBlock:(void(^)(NSError* error))block;
-(void)wrapperIsValidAccount:(NSString*)account withBlock:(void(^)(NSError* error))block;

-(void)wrapperSendSubmit:(RPNewTransaction*)transaction withBlock:(void(^)(NSError* error))block;
-(void)wrapperSendShop:(RPNewTransaction*)transaction withBlock:(void(^)(NSError* error))block;
-(void)setTrust:(RPTrsut *)transaction withBlock:(void(^)(NSError* error))block;
-(void)offcreate:(RPCreatorder *)transaction withBlock:(void(^)(NSError* error))block;
-(void)book_offers:(NSDictionary *)transaction withBlock:(void(^)(id responseData))block;


@end
