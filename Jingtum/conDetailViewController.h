//
//  conDetailViewController.h
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HZAreaPickerView.h"

@interface conDetailViewController : JingtumStatusViewController<HZAreaPickerDelegate,UITextFieldDelegate,UIAlertViewDelegate>
{
    BOOL isOpened;
}

@property (nonatomic,strong) NSString *name,*address;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UITextField *cataTextFiled;
@property (weak, nonatomic) IBOutlet UITextField *priceTextFiled;



- (IBAction)send:(id)sender;

@end
