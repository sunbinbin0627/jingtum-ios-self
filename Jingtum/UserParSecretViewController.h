//
//  UserParSecretViewController.h
//  Jingtum
//
//  Created by sunbinbin on 15-2-10.
//  Copyright (c) 2015年 OpenCoin Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserParSecretViewController : UIViewController


@property (strong, nonatomic) IBOutlet UITextField *passwordFiled;

@property (strong, nonatomic) IBOutlet UITextField *passwordSureFiled;


- (IBAction)sendBtn:(id)sender;


@end
