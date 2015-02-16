//
//  JingtumJSManager+PaySecret.h
//  Jingtum
//
//  Created by sunbinbin on 15-2-5.
//  Copyright (c) 2015年 OpenCoin Inc. All rights reserved.
//

#import "JingtumJSManager.h"

@interface JingtumJSManager (PaySecret)


-(void)setPaySecret:(NSDictionary *)secret withBlock:(void(^)(id responseData))block;

-(void)VerifyPaySecret:(NSString *)secret withBlock:(void(^)(id responseData))block;


@end
