//
//  myTextFiled.m
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "myTextFiled.h"

@implementation myTextFiled

-(id)initWithFrame:(CGRect)frame Icon:(UIImageView*)icon
{	self = [super initWithFrame:frame];
    if (self) {
        self.leftView = icon;
        self.leftViewMode = UITextFieldViewModeAlways;
    }	return self;
}
-(CGRect) leftViewRectForBounds:(CGRect)bounds
{	CGRect iconRect = [super leftViewRectForBounds:bounds];
    iconRect.origin.x += 13;// 右偏10
    return iconRect;
}

-(CGRect)textRectForBounds:(CGRect)bounds
{
    //return CGRectInset(bounds, 50, 0);
    CGRect inset = CGRectMake(bounds.origin.x+52, bounds.origin.y, bounds.size.width -10, bounds.size.height);//更好理解些
    return inset;
    
}

-(CGRect)editingRectForBounds:(CGRect)bounds
{
    //return CGRectInset( bounds, 10 , 0 );
    CGRect inset = CGRectMake(bounds.origin.x +52, bounds.origin.y, bounds.size.width -10, bounds.size.height);
    return inset;
}


@end
