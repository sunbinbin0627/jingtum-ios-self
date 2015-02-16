//
//  HZAreaPickerView.m
//  areapicker
//
//  Created by Cloud Dai on 12-9-9.
//  Copyright (c) 2012年 clouddai.com. All rights reserved.
//

#import "HZAreaPickerView.h"
#import <QuartzCore/QuartzCore.h>

#define kDuration 0.3

@interface HZAreaPickerView ()
{
    NSArray *provinces, *cities, *areas;
    NSArray *banks,*contrys;
    NSArray *catagorys;
}

@end

@implementation HZAreaPickerView

@synthesize delegate=_delegate;
@synthesize pickerStyle=_pickerStyle;
@synthesize locate=_locate;
@synthesize locatePicker = _locatePicker;

- (void)dealloc
{
    [_locate release];
    [_locatePicker release];
    [provinces release];
    [super dealloc];
}

-(HZLocation *)locate
{
    if (_locate == nil) {
        _locate = [[HZLocation alloc] init];
    }
    
    return _locate;
}

- (id)initWithStyle:(HZAreaPickerStyle)pickerStyle delegate:(id<HZAreaPickerDelegate>)delegate
{
    
    self = [[[[NSBundle mainBundle] loadNibNamed:@"HZAreaPickerView" owner:self options:nil] objectAtIndex:0] retain];
    if (self) {
        self.delegate = delegate;
        self.pickerStyle = pickerStyle;
        self.locatePicker.dataSource = self;
        self.locatePicker.delegate = self;
        
        //加载数据
        if (self.pickerStyle == HZAreaPickerWithStateAndCityAndDistrict)
        {
            provinces = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"area.plist" ofType:nil]];
            cities = [[provinces objectAtIndex:0] objectForKey:@"cities"];
            
            self.locate.state = [[provinces objectAtIndex:0] objectForKey:@"state"];
            self.locate.city = [[cities objectAtIndex:0] objectForKey:@"city"];
            
            areas = [[cities objectAtIndex:0] objectForKey:@"areas"];
            if (areas.count > 0) {
                self.locate.district = [areas objectAtIndex:0];
            } else{
                self.locate.district = @"";
            }
            
        }
        else if(self.pickerStyle == HZAreaPickerWithCountry)
        {
            contrys = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Countries.plist" ofType:nil]];
            self.locate.country = [contrys objectAtIndex:0];
        }
        else if (self.pickerStyle == HZAreaPickerWithBank)
        {
            banks = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"bank.plist" ofType:nil]];
            self.locate.bank = [banks objectAtIndex:0];
        }
        else if (self.pickerStyle == HZAreaPickerWithCatagory)
        {
            catagorys = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"catagory.plist" ofType:nil]];
            self.locate.catagory = [catagorys objectAtIndex:0];
        }
    }
        
    return self;
    
}



#pragma mark - PickerView lifecycle

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (self.pickerStyle == HZAreaPickerWithStateAndCityAndDistrict)
    {
        return 3;
    }
    else if(self.pickerStyle == HZAreaPickerWithCountry)
    {
        return 1;
    }
    else if (self.pickerStyle == HZAreaPickerWithBank)
    {
        return 1;
    }
    else if (self.pickerStyle == HZAreaPickerWithCatagory)
    {
        return 1;
    }
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component)
    {
        case 0:
            if (self.pickerStyle == HZAreaPickerWithCountry)
            {
                return [contrys count];
            }
            else if (self.pickerStyle == HZAreaPickerWithStateAndCityAndDistrict)
            {
                return [provinces count];
            }
            else if (self.pickerStyle == HZAreaPickerWithBank)
            {
                return [banks count];
            }
            else if (self.pickerStyle == HZAreaPickerWithCatagory)
            {
                return [catagorys count];
            }
            break;
        case 1:
            if (self.pickerStyle == HZAreaPickerWithStateAndCityAndDistrict)
            {
                return [cities count];
            }
            break;
        case 2:
            if (self.pickerStyle == HZAreaPickerWithStateAndCityAndDistrict)
            {
                return [areas count];
                break;
            }
        default:
            return 0;
            break;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (self.pickerStyle == HZAreaPickerWithStateAndCityAndDistrict) {
        switch (component) {
            case 0:
                return [[provinces objectAtIndex:row] objectForKey:@"state"];
                break;
            case 1:
                return [[cities objectAtIndex:row] objectForKey:@"city"];
                break;
            case 2:
                if ([areas count] > 0) {
                    return [areas objectAtIndex:row];
                    break;
                }
            default:
                return  @"";
                break;
        }
    } else if (self.pickerStyle == HZAreaPickerWithCountry){
        switch (component) {
            case 0:
                return [contrys objectAtIndex:row];
                break;
            default:
                return @"";
                break;
        }
    }else if (self.pickerStyle == HZAreaPickerWithBank){
        switch (component) {
            case 0:
                return [banks objectAtIndex:row];
                break;
                
            default:
                return @"";
                break;
        }
        
    }else if (self.pickerStyle == HZAreaPickerWithCatagory){
        switch (component) {
            case 0:
                return [catagorys objectAtIndex:row];
                break;
                
            default:
                return @"";
                break;
        }
        
    }
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (self.pickerStyle == HZAreaPickerWithStateAndCityAndDistrict) {
        switch (component) {
            case 0:
                cities = [[provinces objectAtIndex:row] objectForKey:@"cities"];
                [self.locatePicker selectRow:0 inComponent:1 animated:YES];
                [self.locatePicker reloadComponent:1];
                
                areas = [[cities objectAtIndex:0] objectForKey:@"areas"];
                [self.locatePicker selectRow:0 inComponent:2 animated:YES];
                [self.locatePicker reloadComponent:2];
                
                self.locate.state = [[provinces objectAtIndex:row] objectForKey:@"state"];
                self.locate.city = [[cities objectAtIndex:0] objectForKey:@"city"];
                if ([areas count] > 0) {
                    self.locate.district = [areas objectAtIndex:0];
                } else{
                    self.locate.district = @"";
                }
                break;
            case 1:
                areas = [[cities objectAtIndex:row] objectForKey:@"areas"];
                [self.locatePicker selectRow:0 inComponent:2 animated:YES];
                [self.locatePicker reloadComponent:2];
                
                self.locate.city = [[cities objectAtIndex:row] objectForKey:@"city"];
                if ([areas count] > 0) {
                    self.locate.district = [areas objectAtIndex:0];
                } else{
                    self.locate.district = @"";
                }
                break;
            case 2:
                if ([areas count] > 0) {
                    self.locate.district = [areas objectAtIndex:row];
                } else{
                    self.locate.district = @"";
                }
                break;
            default:
                break;
        }
    } else if(self.pickerStyle == HZAreaPickerWithCountry){
        switch (component) {
            case 0:
                self.locate.country=[contrys objectAtIndex:row];
                break;
            default:
                break;
        }
    } else if (self.pickerStyle == HZAreaPickerWithBank){
        switch (component) {
            case 0:
                self.locate.bank=[banks objectAtIndex:row];
                break;
            default:
                break;
        }
    } else if (self.pickerStyle == HZAreaPickerWithCatagory){
        switch (component) {
            case 0:
                self.locate.catagory=[catagorys objectAtIndex:row];
                break;
            default:
                break;
        }
    }
    
    if([self.delegate respondsToSelector:@selector(pickerDidChaneStatus:)]) {
        [self.delegate pickerDidChaneStatus:self];
    }

}


#pragma mark - animation

- (void)showInView:(UIView *) view
{
    self.frame = CGRectMake(0, view.frame.size.height, self.frame.size.width, self.frame.size.height);
    [view addSubview:self];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, view.frame.size.height - self.frame.size.height, self.frame.size.width, self.frame.size.height);
    }];
    
}

- (void)cancelPicker
{
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.frame = CGRectMake(0, self.frame.origin.y+self.frame.size.height, self.frame.size.width, self.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                         
                     }];
    
}

@end
