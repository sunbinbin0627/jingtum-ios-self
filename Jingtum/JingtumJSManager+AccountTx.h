//
//  JingtumJSManager+AccountTx.h
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "JingtumJSManager.h"

@interface JingtumJSManager (AccountTx)

-(void)wrapperAccountTx_transation:(NSString *)hash withBlock:(void(^)(id responseData))block;

-(void)wrapperMoreAccountTx;
-(void)wrapperAccountTx;

@end
