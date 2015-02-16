//
//  ReceiveViewController.h
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReceiveViewController : JingtumStatusViewController<UITextFieldDelegate,UIAlertViewDelegate,UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UILabel *userLabel;
@property (strong, nonatomic) IBOutlet UIButton *btnImage;
- (IBAction)Btn:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UILabel *cataLabel;



@end
