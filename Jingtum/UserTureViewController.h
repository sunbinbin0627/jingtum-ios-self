//
//  UserTureViewController.h
//  Jingtum
//
//  Created by sunbinbin on 14-12-11.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserTureViewController : JingtumStatusViewController<UIAlertViewDelegate>


@property (strong, nonatomic) IBOutlet UITextField *TureNameLabel;

@property (strong, nonatomic) IBOutlet UISegmentedControl *segementController;

@property (strong, nonatomic) IBOutlet UITextField *idTextFiled;
@property (strong, nonatomic) IBOutlet UITextField *addressTextFiled;
@property (strong, nonatomic) IBOutlet UILabel *sexLabel;


- (IBAction)mSelectSegment:(UISegmentedControl *)sender;

- (IBAction)sendBtn:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;


@end
