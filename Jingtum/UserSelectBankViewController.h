//
//  UserSelectBankViewController.h
//  Jingtum
//
//  Created by sunbinbin on 15-1-22.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WithdrawDelegate <NSObject>

-(void)withdrawValue:(NSDictionary *)value;

@end


@protocol RechargeDelegate <NSObject>

-(void)rechargeValue:(NSDictionary *)value;

@end

@interface UserSelectBankViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>


@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic,assign) NSObject<WithdrawDelegate> *withdrawDelegate;
@property(nonatomic,assign) NSObject<RechargeDelegate> *rechargeDelegate;

@end
