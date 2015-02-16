//
//  FirstTableViewCell.m
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "FirstTableViewCell.h"
#import "AppDelegate.h"

@implementation FirstTableViewCell

- (void)awakeFromNib
{
    [AppDelegate  storyBoradAutoLay:self];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)changeArrowWithUp:(BOOL)up
{
    if (up) {
        self.mImageView2.image = [UIImage imageNamed:@"cellup.png"];
        [self.mColorButton setBackgroundImage:[UIImage imageNamed:@"tip-gray.png"] forState:UIControlStateNormal];
        [self.mColorButton setTitle:@"+0.00" forState:UIControlStateNormal];
    }else
    {
        self.mImageView2.image = [UIImage imageNamed:@"celldown.png"];
        [self.mColorButton setBackgroundImage:[UIImage imageNamed:@"tip-gray.png"] forState:UIControlStateNormal];
        [self.mColorButton setTitle:@"+0.00" forState:UIControlStateNormal];
    }
}


@end
