//
//  RPCreatorder.h
//  Jingtum
//
//  Created by sunbinbin on 14-12-26.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RPCreatorder : NSObject

@property (strong, nonatomic) NSString   *sell_currency;
@property (strong, nonatomic) NSString   *buy_currency;
@property (strong, nonatomic) NSDecimalNumber   *amount;
@property (strong, nonatomic) NSDecimalNumber   *actualTotal;
@property (strong, nonatomic) NSString   *issuer;
@property (strong, nonatomic) NSString   *flag;

@end
