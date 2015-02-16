//
//  JingtumJSManager+TransactionCallback.h
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "JingtumJSManager.h"

@interface JingtumJSManager (TransactionCallback)

-(void)wrapperSubscribeTransactions;
-(void)wrapperRegisterHandlerTransactionCallback;

@end
