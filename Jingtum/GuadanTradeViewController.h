//
//  GuadanTradeViewController.h
//  Ripple
//
//  Created by Sha  Zhou on 2/2/15.
//  Copyright (c) 2015 OpenCoin Inc. All rights reserved.
//

#import "ViewController.h"
#import "DropDownView.h"

@interface GuadanTradeViewController : ViewController <DropDownViewDelegate>
{
    DropDownView *buyCurDropView;
    DropDownView *sellCurDropView;
}

@property (strong, nonatomic) IBOutlet UIButton *buycurButton;
@property (strong, nonatomic) IBOutlet UIButton *sellcurButton;
@property (strong, nonatomic) IBOutlet UITextField *priceField;
@property (strong, nonatomic) IBOutlet UITextField *amoutField;

@property (strong, nonatomic) NSArray *buyCurData;
@property (strong, nonatomic) NSArray *sellCurData;

- (IBAction)clickBuyCurButton:(id)sender;
- (IBAction)clickSellCurButton:(id)sender;
- (IBAction)onTap:(id)sender;
- (IBAction)segementControl:(id)sender;

@end