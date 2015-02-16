//
//  ZhuceViewController.h
//  Jingtum
//
//  Created by sunbinbin on 14-10-11.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface ZhuceViewController : JingtumStatusViewController<UIAlertViewDelegate,UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate>
{
    BOOL isOpened;
}

@property (weak, nonatomic) IBOutlet UITextField *phoneNameTextFiled;
@property (strong, nonatomic) IBOutlet UILabel *areaCodeLabel;
@property (strong, nonatomic) IBOutlet UITextField *areaTextFiled;

- (IBAction)nextBtn:(id)sender;
- (IBAction)gouBtn:(id)sender;
- (IBAction)abountBtn:(id)sender;


@property (strong, nonatomic) IBOutlet UIButton *mNextButton;
@property (strong, nonatomic) IBOutlet UIButton *openButton;
@property (nonatomic,strong) NSMutableDictionary *jsonDict;

@end
