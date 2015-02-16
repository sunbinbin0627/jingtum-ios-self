//
//  HistoryTableViewCell.m
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "HistoryTableViewCell.h"
#import "AppDelegate.h"

@implementation HistoryTableViewCell

- (void)awakeFromNib {
    [AppDelegate storyBoradAutoLay:self];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
