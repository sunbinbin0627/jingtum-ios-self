//
//  JingtumJSManager+NetworkStatus.h
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "JingtumJSManager.h"

@interface JingtumJSManager (NetworkStatus)

-(void)wrapperRegisterBridgeHandlersNetworkStatus;

-(void)getAllocationInfomation;

-(void)operationManagerGET:(NSString *)url parameters:(id )params withBlock:(void(^)(NSString *error, id responseData))block;

-(void)operationManagerPOST:(NSString *)url parameters:(id )params withBlock:(void(^)(NSString *error, id responseData))block;

@end
