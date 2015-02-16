//
//  ShoperTableViewCell.h
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShoperTableViewCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UILabel *mNameLabel;

@property (strong, nonatomic) IBOutlet UIImageView *imgView;

@property (strong, nonatomic) IBOutlet UILabel *detailLabel;

@property (strong, nonatomic) IBOutlet UILabel *priceLabel;

@property (strong, nonatomic) IBOutlet UILabel *sendLabel;

@property (strong, nonatomic) IBOutlet UILabel *mDataLabel;


@property (strong, nonatomic) IBOutlet UILabel *mCurrencyNameLabel;

@end
