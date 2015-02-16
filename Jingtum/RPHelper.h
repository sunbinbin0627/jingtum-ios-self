//
//  RPHelper.h
//  Jingtum
//
//  Created by Kevin Johnson on 7/31/13.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RPHelper : NSObject

+(NSNumber*)safeNumberFromDictionary:(NSDictionary*)dic withKey:(NSString*)key;
+(NSDecimalNumber*)safeDecimalNumberFromDictionary:(NSDictionary*)dic withKey:(NSString*)key;
+(NSDecimalNumber*)dropsToJingtums:(NSDecimalNumber*)drops;
+(NSDecimalNumber*)jingtumsToDrops:(NSDecimalNumber*)jingtums;

@end
