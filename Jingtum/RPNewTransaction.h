//
//  RPNewTransaction.h
//  Jingtum
//
//  Created by Kevin Johnson on 7/23/13.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RPNewTransaction : NSObject

//@property (strong, nonatomic) NSString * Account;
//@property (strong, nonatomic) NSNumber * Amount;
//@property (strong, nonatomic) NSString * Destination;
//@property (strong, nonatomic) NSString * Destination_name;
//@property (strong, nonatomic) NSString * Destination_currency;
//@property (strong, nonatomic) NSString * Currency;
//@property (strong, nonatomic) NSDate   * Date;

@property (strong, nonatomic) NSString        * to_issuer;
@property (strong, nonatomic) NSString        * to_address;
@property (strong, nonatomic) NSString        * to_name;
@property (strong, nonatomic) NSString        * to_currency;
@property (strong, nonatomic) NSDecimalNumber * to_amount;

@property (strong, nonatomic) NSString * from_address;
@property (strong, nonatomic) NSString * from_currency;
//@property (strong, nonatomic) NSDecimalNumber * from_amount;

@property (strong, nonatomic) NSDictionary * path;

@property (strong, nonatomic) NSDate   * date;

@end
