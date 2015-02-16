//
//  GuadanTradeViewController.m
//  Ripple
//
//  Created by Sha  Zhou on 2/2/15.
//  Copyright (c) 2015 OpenCoin Inc. All rights reserved.
//

#import "GuadanTradeViewController.h"

@interface GuadanTradeViewController ()

@end

@implementation GuadanTradeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _buyCurData = @[@"one", @"two", @"three"];
    _sellCurData = @[@"1", @"2", @"3"];
    [self addDropDown];
}

- (void)addDropDown {
    buyCurDropView = [[DropDownView alloc] initWithArrayData:_buyCurData cellHeight:30 heightTableView:200 paddingTop:-8 paddingLeft:-5 paddingRight:-10 refView:self.buycurButton animation:BLENDIN openAnimationDuration:.5 closeAnimationDuration:.5];
    buyCurDropView.delegate = self;
    [self.view addSubview:buyCurDropView.view];
    
    sellCurDropView = [[DropDownView alloc] initWithArrayData:_sellCurData cellHeight:30 heightTableView:200 paddingTop:-8 paddingLeft:-5 paddingRight:-10 refView:self.sellcurButton animation:BLENDIN openAnimationDuration:.5 closeAnimationDuration:.5];
    sellCurDropView.delegate = self;
    [self.view addSubview:sellCurDropView.view];
}

#pragma mark - DropDownView delegate

- (void)dropDownCellSelected:(NSInteger)returnIndex sender:(id)sender {
    if ([sender isEqual:sellCurDropView]) {
        [self.sellcurButton setTitle:[_sellCurData objectAtIndex:returnIndex] forState:UIControlStateNormal];
        [sellCurDropView closeAnimation];
    } else {
        [self.buycurButton setTitle:[_buyCurData objectAtIndex:returnIndex] forState:UIControlStateNormal];
        [buyCurDropView closeAnimation];
    }
}

- (IBAction)clickBuyCurButton:(id)sender {
    [buyCurDropView openAnimation];
}

- (IBAction)clickSellCurButton:(id)sender {
    [sellCurDropView openAnimation];
}

- (IBAction)onTap:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)segementControl:(id)sender {
}

@end
