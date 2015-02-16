//
//  JingtumJSManager+Register.h
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "JingtumJSManager.h"

@interface JingtumJSManager (Register)


- (void)RegisterForAccountId:(id)tmpData withBlock:(void(^)(id responseData))block;
- (void)RegisterForMassterId:(NSString *)tmpData withBlock:(void(^)(id responseData))block;
- (void)RegisterEncrypt:(NSDictionary *)tmpDict withBlock:(void (^)(id responseData))block;

@end
