//
//  UserDB.m
//  UserDemo
//
//  Created by wei.chen on 13-2-27.
//  Copyright (c) 2013年 www.iphonetrain.com 无限互联3G学院. All rights reserved.
//

#import "UserDB.h"

static UserDB *instnce;

@implementation UserDB

+ (id)shareInstance {
    if (instnce == nil) {
        instnce = [[[self class] alloc] init];
    }
    return instnce;
}

//钱包
- (void)createWalletTable {
    NSString *sql = @"CREATE TABLE IF NOT EXISTS wallet(wallettype TEXT primary key,walletnum TEXT,walletkey TEXT,walletimage TEXT,wallettitle TEXT)";
    [self createTable:sql];
}

- (BOOL)deleteWallet
{
    NSString *sql = @"delete FROM wallet";
    
    return [self dealData:sql paramsarray:nil];
}

- (BOOL)addWallet:(RPWallet *)rpWallet
{
    NSString *sql = @"INSERT INTO wallet(wallettype,walletnum,walletkey,walletimage,wallettitle) VALUES(?,?,?,?,?)";
    
    NSArray *params = [NSArray arrayWithObjects:rpWallet.type,
                                                rpWallet.num,
                                                rpWallet.key,
                                                rpWallet.image,
                                                rpWallet.title,
                                                nil];
    return [self dealData:sql paramsarray:params];
}

- (BOOL)updateWallet:(RPWallet *)rpWallet
{
    NSString *sql = @"UPDATE wallet SET walletnum=?,walletkey=?,walletimage=?,wallettitle=? WHERE wallettype=?";
    
    NSArray *params = [NSArray arrayWithObjects:rpWallet.num,
                       rpWallet.key,
                       rpWallet.image,
                       rpWallet.title,
                       rpWallet.type,
                       nil];
    return [self dealData:sql paramsarray:params];
}

- (NSArray *)searchWallet:(NSString *)rpWallet
{
    NSString *sql = @"SELECT * FROM wallet WHERE wallettype=?";
    
    NSArray *params = [NSArray arrayWithObjects:rpWallet,nil];
    NSArray *data = [self selectData:sql columns:5 paramsarray:params];
    
    NSMutableArray *wallet = [NSMutableArray array];
    for (NSArray *row in data)
    {
        NSString *walletType = [row objectAtIndex:0];
        NSString *walletNum = [row objectAtIndex:1];
        NSString *walletKey = [row objectAtIndex:2];
        NSString *walletImage = [row objectAtIndex:3];
        NSString *walletTitle = [row objectAtIndex:4];
        
        RPWallet *con = [[RPWallet alloc] init];
        con.type = walletType;
        con.num = walletNum;
        con.key = walletKey;
        con.image = walletImage;
        con.title = walletTitle;
        [wallet addObject:con];
    }
    
    return wallet;
    
}

- (NSArray *)findAllWallet
{
    NSString *sql = @"SELECT * FROM wallet";
    
    NSArray *data = [self selectData:sql columns:5 paramsarray:nil];
    
    NSMutableArray *wallet = [NSMutableArray array];
    for (NSArray *row in data)
    {
        NSString *typeStr = [row objectAtIndex:0];
        NSString *numStr = [row objectAtIndex:1];
        NSString *keyStr = [row objectAtIndex:2];
        NSString *imageStr = [row objectAtIndex:3];
        NSString *titleStr = [row objectAtIndex:4];
        
        RPWallet *con = [[RPWallet alloc] init];
        con.type = typeStr;
        con.num = numStr;
        con.key = keyStr;
        con.image = imageStr;
        con.title = titleStr;
        [wallet addObject:con];
    }
    
    return wallet;
}


//历史账单
- (void)createHistoryAccount
{
    NSString *sql = @"CREATE TABLE IF NOT EXISTS history(historytype TEXT,historyaccountType TEXT,historyaccountResult TEXT,historyimage TEXT,historymessage TEXT,historyprice TEXT,historykey TEXT,historydetailTime TEXT,historymounthTime TEXT,historymounthDay TEXT,historyaddress TEXT,historyhash TEXT)";
    [self createTable:sql];
}


- (BOOL)deleteHistory
{
    NSString *sql = @"delete FROM history";
    
    return [self dealData:sql paramsarray:nil];
}


- (BOOL)addHistory:(RPHistory *)rpHistory
{
    NSString *sql = @"INSERT INTO history(historytype,historyaccountType,historyaccountResult,historyimage,historymessage,historyprice,historykey,historydetailTime,historymounthTime,historymounthDay,historyaddress,historyhash) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)";
    
    NSArray *params = [NSArray arrayWithObjects:
                       rpHistory.type,
                       rpHistory.accountType,
                       rpHistory.accountResult,
                       rpHistory.image,
                       rpHistory.message,
                       rpHistory.price,
                       rpHistory.key,
                       rpHistory.detailTime,
                       rpHistory.mounthTime,
                       rpHistory.mounthDay,
                       rpHistory.address,
                       rpHistory.hash,
                       nil];
    
    return [self dealData:sql paramsarray:params];
}


- (NSArray *)searchHistory:(NSString *)rpHistory andSqlite:(NSString *)sqlite
{
    NSString *sql=[NSString stringWithFormat:@"SELECT * FROM history WHERE %@=? ORDER BY historydetailTime DESC",sqlite];
//    NSString *sql = @"SELECT * FROM history WHERE historytype=?";
    
    NSArray *params = [NSArray arrayWithObjects:rpHistory,nil];
    NSArray *data = [self selectData:sql columns:12 paramsarray:params];
    
    NSMutableArray *wallet = [NSMutableArray array];
    for (NSArray *row in data)
    {
        NSString *historyType = [row objectAtIndex:0];
        NSString *historyAccountType = [row objectAtIndex:1];
        NSString *historyAccountResult = [row objectAtIndex:2];
        NSString *historyImage = [row objectAtIndex:3];
        NSString *historyMessage = [row objectAtIndex:4];
        NSString *historyPrice = [row objectAtIndex:5];
        NSString *historyKey = [row objectAtIndex:6];
        NSString *historyDetailtime = [row objectAtIndex:7];
        NSString *historyMounthtime = [row objectAtIndex:8];
        NSString *historyMounthday = [row objectAtIndex:9];
        NSString *historyAddress = [row objectAtIndex:10];
        NSString *historyHash = [row objectAtIndex:11];
        
        RPHistory *con = [[RPHistory alloc] init];
        con.type = historyType;
        con.accountType = historyAccountType;
        con.accountResult = historyAccountResult;
        con.image = historyImage;
        con.message = historyMessage;
        con.price = historyPrice;
        con.key = historyKey;
        con.detailTime = historyDetailtime;
        con.mounthTime = historyMounthtime;
        con.mounthDay = historyMounthday;
        con.address = historyAddress;
        con.hash = historyHash;
        [wallet addObject:con];
    }
    
    return wallet;
}


- (NSArray *)findAllHistory
{

    NSString *sql = @"SELECT * FROM history ORDER BY historydetailTime DESC";
    
    NSArray *data = [self selectData:sql columns:12 paramsarray:nil];
    
    NSMutableArray *wallet = [NSMutableArray array];
    for (NSArray *row in data)
    {
        NSString *historyType = [row objectAtIndex:0];
        NSString *historyAccountType = [row objectAtIndex:1];
        NSString *historyAccountResult = [row objectAtIndex:2];
        NSString *historyImage = [row objectAtIndex:3];
        NSString *historyMessage = [row objectAtIndex:4];
        NSString *historyPrice = [row objectAtIndex:5];
        NSString *historyKey = [row objectAtIndex:6];
        NSString *historyDetailtime = [row objectAtIndex:7];
        NSString *historyMounthtime = [row objectAtIndex:8];
        NSString *historyMounthday = [row objectAtIndex:9];
        NSString *historyAddress = [row objectAtIndex:10];
        NSString *historyHash = [row objectAtIndex:11];
        
        RPHistory *con = [[RPHistory alloc] init];
        con.type = historyType;
        con.accountType = historyAccountType;
        con.accountResult = historyAccountResult;
        con.image = historyImage;
        con.message = historyMessage;
        con.price = historyPrice;
        con.key = historyKey;
        con.detailTime = historyDetailtime;
        con.mounthTime = historyMounthtime;
        con.mounthDay = historyMounthday;
        con.address = historyAddress;
        con.hash = historyHash;
        [wallet addObject:con];
    }
    
    return wallet;
}



//联系人
- (void)createContractTable {
    NSString *sql = @"CREATE TABLE IF NOT EXISTS contract(CONTRACTNAME TEXT primary key,CONTRACTADDRESS TEXT)";
    [self createTable:sql];
}

- (BOOL)addContract:(RPContact *)rpContract {
    NSString *sql = @"INSERT INTO contract(CONTRACTNAME,CONTRACTADDRESS) VALUES(?,?)";
    
    NSArray *params = [NSArray arrayWithObjects:rpContract.fname,
                                                rpContract.fid,
                                                        nil];
    
    return [self dealData:sql paramsarray:params];
}

- (NSArray *)findContracts {
    NSString *sql = @"SELECT * FROM contract";
    NSArray *data = [self selectData:sql columns:2 paramsarray:nil];

    NSMutableArray *users = [NSMutableArray array];
    for (NSArray *row in data) {
        NSString *username = [row objectAtIndex:0];
        NSString *password = [row objectAtIndex:1];
        
        RPContact *con = [[RPContact alloc] init];
        con.fname = username;
        con.fid = password;
        [users addObject:con];
    }
    
    return users;
}

- (BOOL)deleteContract
{
    NSString *sql = @"delete FROM contract";
    
    return [self dealData:sql paramsarray:nil];
}

- (BOOL)deleteContract:(NSString *)contractName
{
    NSString *sql = @"delete FROM contract WHERE CONTRACTNAME=?";
    
    NSArray *params = [NSArray arrayWithObjects:contractName, nil];
    
    return [self dealData:sql paramsarray:params];
    
}


//用户通
//创建用户通表
- (void)createShopTable
{
    NSString *sql = @"CREATE TABLE IF NOT EXISTS shop(shopName TEXT primary key,shopDate TEXT,shopInfo TEXT,shopDetail TEXT,shopPrice TEXT,shopNum TEXT,shopAddress TEXT,shopPhone TEXT,shopCurrency TEXT,shopCurrencyName TEXT,shopMerchantCurrency TEXT,shopOtherImage TEXT,shopPhotoImage TEXT)";
    
    [self createTable:sql];
}

//删除所有用户通数据
- (BOOL)deleteShop
{
    NSString *sql = @"delete FROM shop";
    
    return [self dealData:sql paramsarray:nil];
}

//查询所有用户通数据
- (NSArray *)findShop
{
    NSString *sql = @"SELECT * FROM shop";
    NSArray *data = [self selectData:sql columns:13 paramsarray:nil];
    
    NSMutableArray *shops = [NSMutableArray array];
    for (NSArray *row in data) {
        NSString *nameStr = [row objectAtIndex:0];
        NSString *dateStr = [row objectAtIndex:1];
        NSString *infoStr = [row objectAtIndex:2];
        NSString *detailStr = [row objectAtIndex:3];
        NSString *priceStr = [row objectAtIndex:4];
        NSString *numStr = [row objectAtIndex:5];
        NSString *addressStr = [row objectAtIndex:6];
        NSString *phoneStr = [row objectAtIndex:7];
        NSString *currencyStr = [row objectAtIndex:8];
        NSString *currencyNameStr = [row objectAtIndex:9];
        NSString *merchantCurrencyStr = [row objectAtIndex:10];
        NSString *otherStr = [row objectAtIndex:11];
        NSString *photoStr = [row objectAtIndex:12];
        
        RPShop *con = [[RPShop alloc] init];
        con.name = nameStr;
        con.date = dateStr;
        con.shopInfo = infoStr;
        con.shopDetail = detailStr;
        con.price = priceStr;
        con.num = numStr;
        con.address = addressStr;
        con.phone = phoneStr;
        con.currency = currencyStr;
        con.currencyName = currencyNameStr;
        con.merchantCurrency = merchantCurrencyStr;
        con.otherImage = otherStr;
        con.photoImage = photoStr;
        
        [shops addObject:con];
    }
    
    return shops;
    
}


//添加一个用户通
- (BOOL)addShop:(RPShop *)rpShop
{
    NSString *sql = @"INSERT INTO shop(shopName,shopDate,shopInfo,shopDetail,shopPrice,shopNum,shopAddress,shopPhone,shopCurrency,shopCurrencyName,shopMerchantCurrency,shopOtherImage,shopPhotoImage) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)";
    
    NSArray *params = [NSArray arrayWithObjects:
                       rpShop.name,
                       rpShop.date,
                       rpShop.shopInfo,
                       rpShop.shopDetail,
                       rpShop.price,
                       rpShop.num,
                       rpShop.address,
                       rpShop.phone,
                       rpShop.currency,
                       rpShop.currencyName,
                       rpShop.merchantCurrency,
                       rpShop.otherImage,
                       rpShop.photoImage,
                       nil];
    
    return [self dealData:sql paramsarray:params];
}

//查询某一个用户通
- (NSArray *)searchShop:(NSString *)rpShop
{
    NSString *sql = @"SELECT * FROM shop WHERE shopCurrency=?";
    
    NSArray *params = [NSArray arrayWithObjects:rpShop,nil];
    NSArray *data = [self selectData:sql columns:13 paramsarray:params];
    
    NSMutableArray *shops = [NSMutableArray array];
    for (NSArray *row in data)
    {
        NSString *nameStr = [row objectAtIndex:0];
        NSString *dateStr = [row objectAtIndex:1];
        NSString *infoStr = [row objectAtIndex:2];
        NSString *detailStr = [row objectAtIndex:3];
        NSString *priceStr = [row objectAtIndex:4];
        NSString *numStr = [row objectAtIndex:5];
        NSString *addressStr = [row objectAtIndex:6];
        NSString *phoneStr = [row objectAtIndex:7];
        NSString *currencyStr = [row objectAtIndex:8];
        NSString *currencyNameStr = [row objectAtIndex:9];
        NSString *merchantCurrencyStr = [row objectAtIndex:10];
        NSString *otherStr = [row objectAtIndex:11];
        NSString *photoStr = [row objectAtIndex:12];
        
        RPShop *con = [[RPShop alloc] init];
        con.name = nameStr;
        con.date = dateStr;
        con.shopInfo = infoStr;
        con.shopDetail = detailStr;
        con.price = priceStr;
        con.num = numStr;
        con.address = addressStr;
        con.phone = phoneStr;
        con.currency = currencyStr;
        con.currencyName = currencyNameStr;
        con.merchantCurrency = merchantCurrencyStr;
        con.otherImage = otherStr;
        con.photoImage = photoStr;
        
        [shops addObject:con];
    }
    
    return shops;

}






@end
