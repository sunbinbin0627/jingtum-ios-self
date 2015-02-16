//
//  FirstTableViewCell.h
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstTableViewCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UIImageView *mImageView1;
@property (strong, nonatomic) IBOutlet UILabel *mPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *mCataLabel;
@property (strong, nonatomic) IBOutlet UIImageView *mImageView2;
@property (strong, nonatomic) IBOutlet UIButton *mColorButton;



- (void)changeArrowWithUp:(BOOL)up;
@end
