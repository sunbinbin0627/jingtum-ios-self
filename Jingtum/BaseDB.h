//
//  BaseDB.h
//  UserDemo
//
//  Created by wei.chen on 13-2-27.
//  Copyright (c) 2013年 www.iphonetrain.com 无限互联3G学院. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface BaseDB : NSObject

//创建表
- (void)createTable:(NSString *)sql;

/**
 * 接口描述：插入数据、删除数据、修改数据
 * 参数：  sql: SQL语句
 * 返回值：是否执行成功
 *
 */
- (BOOL)dealData:(NSString *)sql paramsarray:(NSArray *)params;

/**
 *  接口描述：查询数据
 *  参数：  sql:SQL语句
 *  返回值：[
                [“字段值1”，“字段值2”，“字段值3”],
                [“字段值1”，“字段值2”，“字段值3”],
                [“字段值1”，“字段值2”，“字段值3”], 
           ]
 */
- (NSMutableArray *)selectData:(NSString *)sql columns:(int)number paramsarray:(NSArray *)params;

@end
