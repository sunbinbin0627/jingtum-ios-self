//
//  UserDB.h
//  UserDemo
//
//  Created by wei.chen on 13-2-27.
//  Copyright (c) 2013年 www.iphonetrain.com 无限互联3G学院. All rights reserved.
//

#import "BaseDB.h"
#import "RPContact.h"
#import "RPWallet.h"
#import "RPHistory.h"
#import "RPShop.h"

@interface UserDB : BaseDB

+ (id)shareInstance;

//创建钱包页表
- (void)createWalletTable;

//删除所有钱包数据
- (BOOL)deleteWallet;

//添加钱包币种余额
- (BOOL)addWallet:(RPWallet *)rpWallet;

//修改钱包币种余额
- (BOOL)updateWallet:(RPWallet *)rpWallet;

//查询某一币种的余额
- (NSArray *)searchWallet:(NSString *)rpWallet;

//查询所有币种余额
- (NSArray *)findAllWallet;




//创建历史账单页表
- (void)createHistoryAccount;

//删除所有账单数据
- (BOOL)deleteHistory;

//添加账单
- (BOOL)addHistory:(RPHistory *)rpHistory;

//查询某一笔账单
- (NSArray *)searchHistory:(NSString *)rpHistory andSqlite:(NSString *)sqlite;

//查询所有账单
- (NSArray *)findAllHistory;





//创建联系人用户表
- (void)createContractTable;

//添加联系人
- (BOOL)addContract:(RPContact *)rpContract;

//查询联系人
- (NSArray *)findContracts;

//删除所有联系人
- (BOOL)deleteContract;

//删除某一个联系人
- (BOOL)deleteContract:(NSString *)contractName;



//创建用户通表
- (void)createShopTable;

//删除所有用户通数据
- (BOOL)deleteShop;

//查询所有用户通数据
- (NSArray *)findShop;

//添加一个用户通
- (BOOL)addShop:(RPShop *)rpShop;

//查询某一个用户通
- (NSArray *)searchShop:(NSString *)rpShop;





@end
