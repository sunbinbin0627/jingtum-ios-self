//
//  UserAddBankViewController.h
//  Jingtum
//
//  Created by sunbinbin on 15-1-22.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface UserAddBankViewController : UIViewController


@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)mSendBtn:(id)sender;


@property (nonatomic,strong) NSString *bankName;
@property (nonatomic,strong) NSString *bankCode;


@property (nonatomic,strong) NSString *cityName;
@property (nonatomic,strong) NSString *provinceCode;
@property (nonatomic,strong) NSString *cityCode;

@end
