//
//  RPAmount.h
//  Jingtum
//
//  Created by Kevin Johnson on 8/7/13.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RPAmount : NSObject

//@property (strong, nonatomic) NSString * to_currency;
//@property (strong, nonatomic) NSString * to_address;
//@property (strong, nonatomic) NSDecimalNumber * to_amount;

@property (strong, nonatomic) NSString * from_currency;
@property (strong, nonatomic) NSDecimalNumber * from_amount;

@property (strong, nonatomic) NSDictionary * path;

-(id)initWithObject:(id)object;

@end
