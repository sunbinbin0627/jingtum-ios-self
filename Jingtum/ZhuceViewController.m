//
//  ZhuceViewController.m
//  Jingtum
//
//  Created by sunbinbin on 14-10-11.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "ZhuceViewController.h"
#import "SMS_SDK/SMS_SDK.h"
#import "SMS_SDK/CountryAndAreaCode.h"
#import "ZhucePhoneViewController.h"
#import "JingtumJSManager.h"
#import "JingtumJSManager+SendTransaction.h"
#import "AppDelegate.h"

@interface ZhuceViewController ()
{
    NSMutableArray *areaArray;
    UIAlertView *alert1;
    UIAlertView *alert2;
    UIView *_navView;
    UIPickerView *myPickerView;
    NSArray *areaList;
    NSArray *areaCodeList;

}

@end

@implementation ZhuceViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [AppDelegate  storyBoradAutoLay:self.view];
    
    self.mNextButton.enabled=NO;
    
    //自定义navgation
    self.view.backgroundColor = [UIColor whiteColor];
    UIView *statusBarView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, 0.f)];
    if (isIos7 >= 7 && __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1)
    {
        statusBarView.frame = CGRectMake(statusBarView.frame.origin.x, statusBarView.frame.origin.y, statusBarView.frame.size.width, 20.f);
        statusBarView.backgroundColor = [UIColor clearColor];
        ((UIImageView *)statusBarView).backgroundColor = RGBA(62,130,248,1);
        [self.view addSubview:statusBarView];
    }
    
    _navView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, StatusbarSize, self.view.frame.size.width, 44.f+NavViewHeigth)];
    ((UIImageView *)_navView).backgroundColor = RGBA(62,130,248,1);
    [self.view insertSubview:_navView belowSubview:statusBarView];
    _navView.userInteractionEnabled = YES;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((_navView.frame.size.width - 200)/2, (_navView.frame.size.height - 40)/2, 200, 40)];
    [titleLabel setText:@"注 册"];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [_navView addSubview:titleLabel];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 2+NavViewHeigth/2, 70, 40)];
    [backButton setTitle:@"取消" forState:UIControlStateNormal];
    [backButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [backButton setTintColor:[UIColor whiteColor]];
    [backButton setBackgroundColor:[UIColor clearColor]];
    backButton.titleLabel.font=[UIFont systemFontOfSize:13];
    [backButton addTarget:self action:@selector(backtoGround) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:backButton];
    
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(11, (_navView.frame.size.height - 20)/2+5, 7, 10)];
    imageView.image=[UIImage imageNamed:@"title-left.png"];
    [_navView addSubview:imageView];
    
    
    self.mNextButton.enabled=NO;
    [self.mNextButton setTitleColor:RGBA(119, 206, 237, 1) forState:UIControlStateNormal];
    
    self.jsonDict=[[NSMutableDictionary alloc] init];
    
    [SMS_SDK getZone:^(enum SMS_ResponseState state, NSArray *array) {
        if (1==state)
        {
            NSLog(@"block 获取区号成功");
            //区号数据
            areaArray=[NSMutableArray arrayWithArray:array];
//            NSLog(@"==========%@",areaArray);
        }
        else if (0==state)
        {
            NSLog(@"block 获取区号失败");
        }
        
    }];
    
    //设置pickerView  66
    areaList=@[@"中国大陆",@"香港",@"澳门",@"台湾",@"韩国",@"日本",@"美国",@"加拿大",@"英国",@"澳大利亚",@"新加坡",@"马来西亚",@"泰国",@"越南",@"菲律宾",@"印度利西亚",@"德国",@"意大利",@"法国",@"俄罗斯"];
    areaCodeList=@[@"+86",@"+852",@"+853",@"+886",@"+82",@"+81",@"+1",@"+1",@"+44",@"+61",@"+65",@"+60",@"+66",@"+84",@"+63",@"+62",@"+49",@"+39",@"+33",@"+7"];
    myPickerView=[[UIPickerView alloc] init];
    myPickerView.delegate=self;
    
    isOpened=NO;
    [self.phoneNameTextFiled becomeFirstResponder];
    
}


- (void)showInView:(UIView *) view
{
    myPickerView.frame = CGRectMake(0, view.frame.size.height, self.view.frame.size.width, 180);
    [view addSubview:myPickerView];
    
    [UIView animateWithDuration:0.3 animations:^{
        myPickerView.frame = CGRectMake(0, view.frame.size.height - 200, self.view.frame.size.width, 180);
    }];
    
}

- (void)cancelPicker
{
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         myPickerView.frame = CGRectMake(0, myPickerView.frame.origin.y+myPickerView.frame.size.height, myPickerView.frame.size.width, myPickerView.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         [myPickerView removeFromSuperview];
                         
                     }];
    
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return areaList.count;
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return areaList[row];
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.areaTextFiled.text=areaList[row];
    self.areaCodeLabel.text=areaCodeList[row];

}

- (void)backtoGround
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.areaTextFiled])
    {
        [self.phoneNameTextFiled resignFirstResponder];
        [self showInView:self.view];
        return NO;
    }
    else
    {
        return YES;
    }
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
 
    CGRect frame = textField.frame;
    int offset = frame.origin.y + 32 - (self.view.frame.size.height - 216.0);//键盘高度216
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    if(offset > 0)
    {
        CGRect rect = CGRectMake(0.0f, -offset-100,width,height);
        self.view.frame = rect;
    }
    [UIView commitAnimations];
    
}




- (IBAction)nextBtn:(id)sender
{
    int compareResult = 0;
    for (int i=0; i<areaArray.count; i++) {
        NSDictionary* dict1=[areaArray objectAtIndex:i];
        NSString* code1=[dict1 valueForKey:@"zone"];
        //        NSLog(@"areacode:%@",code1);
        if ([code1 isEqualToString:[self.areaCodeLabel.text stringByReplacingOccurrencesOfString:@"+" withString:@""]]) {
            compareResult=1;
            NSString* rule1=[dict1 valueForKey:@"rule"];
            //            NSLog(@"rule:%@",rule1);
            NSPredicate* pred=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",rule1];
            BOOL isMatch=[pred evaluateWithObject:self.phoneNameTextFiled.text];
            if (!isMatch) {
                //手机号码不正确
                UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"手机号码非法，请重新填写" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                return;
            }
            break;
        }
    }
    
    if (!compareResult) {
        if (self.phoneNameTextFiled.text.length!=11) {
            //手机号码不正确
            UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"手机号码非法，请重新填写" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
    }
    
    NSString* str=[NSString stringWithFormat:@"我们将发送验证码短信到这个号码:%@ %@",self.areaCodeLabel.text,self.phoneNameTextFiled.text];
    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"确认手机号码" message:str delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert1=alert;
    [alert show];
}

- (IBAction)gouBtn:(id)sender
{
    if (isOpened) {
        
//        119,206,237
        
        [UIView animateWithDuration:0.3 animations:^{
            UIImage *closeImage=[UIImage imageNamed:@"cb_glossy_off.png"];
            [_openButton setImage:closeImage forState:UIControlStateNormal];
            self.mNextButton.enabled=NO;
            [self.mNextButton  setTitleColor:RGBA(119, 206, 237, 1) forState:UIControlStateNormal];
            
        } completion:^(BOOL finished){
            
            isOpened=NO;
        }];
    }else{
        
        
        [UIView animateWithDuration:0.3 animations:^{
            UIImage *openImage=[UIImage imageNamed:@"cb_glossy_on.png"];
            [_openButton setImage:openImage forState:UIControlStateNormal];
            self.mNextButton.enabled=YES;
            [self.mNextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
        } completion:^(BOOL finished){
            
            isOpened=YES;
        }];
        
        
    }
}

- (IBAction)abountBtn:(id)sender
{
    [self performSegueWithIdentifier:@"abount" sender:nil];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView==alert1)
    {
        if (1==buttonIndex)
        {
            NSLog(@"点击了确定按钮");
            NSString* str2=[self.areaCodeLabel.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
            NSLog(@"str2-->%@",str2);
            [SMS_SDK getVerifyCodeByPhoneNumber:self.phoneNameTextFiled.text AndZone:str2 result:^(enum SMS_GetVerifyCodeResponseState state) {
                if (1==state) {
                    NSLog(@"block 获取验证码成功");
                    [self performSegueWithIdentifier:@"Next" sender:nil];
                    
                }
                else if(0==state)
                {
                    NSLog(@"block 获取验证码失败");
                    NSString* str=[NSString stringWithFormat:@"验证码发送失败 请稍后重试"];
                    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"发送失败" message:str delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alert show];
                }
                else if (SMS_ResponseStateMaxVerifyCode==state)
                {
                    NSString* str=[NSString stringWithFormat:@"请求验证码超上限 请稍后重试"];
                    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"超过上限" message:str delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alert show];
                }
                else if(SMS_ResponseStateGetVerifyCodeTooOften==state)
                {
                    NSString* str=[NSString stringWithFormat:@"客户端请求发送短信验证过于频繁"];
                    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"提示" message:str delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alert show];
                }
            }];
        }
    }
    
    else if (alertView==alert2)
    {
        if (buttonIndex == 0)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
}

- (IBAction)background:(id)sender
{
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    self.view.frame = rect;
    [UIView commitAnimations];
    
    [self cancelPicker];
    [self.view endEditing:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Next"]) {
        ZhucePhoneViewController * view = [segue destinationViewController];
        view.tmpPhone=self.phoneNameTextFiled.text;
        view.tmpPhoneCode=self.areaCodeLabel.text;
    }
}



@end
