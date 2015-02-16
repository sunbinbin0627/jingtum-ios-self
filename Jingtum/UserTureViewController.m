//
//  UserTureViewController.m
//  Jingtum
//
//  Created by sunbinbin on 14-12-11.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "UserTureViewController.h"
#import "JingtumJSManager.h"
#import "JingtumJSManager+Authentication.h"
#import "JingtumJSManager+NetworkStatus.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"

@interface UserTureViewController ()
{
    UIView *_navView;
    NSString *sexStr;
}
@end

@implementation UserTureViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [AppDelegate  storyBoradAutoLay:self.view];
    
    sexStr=@"0";
    
    NSString *useSureStr=[[NSString alloc] init];
    AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appdelegate.firstLogin == 0)
    {
        useSureStr=@"实名信息";
    }
    else if (appdelegate.firstLogin == 1)
    {
        useSureStr=@"实名认证";
    }
    
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
    [titleLabel setText:useSureStr];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [_navView addSubview:titleLabel];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(14, 2+NavViewHeigth/2, 70, 40)];
    [backButton setTitle:@"账户设置" forState:UIControlStateNormal];
    [backButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [backButton setTintColor:[UIColor whiteColor]];
    [backButton setBackgroundColor:[UIColor clearColor]];
    backButton.titleLabel.font=[UIFont systemFontOfSize:13];
    [backButton addTarget:self action:@selector(backtoGround) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:backButton];
    
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(11, (_navView.frame.size.height - 20)/2+5, 7, 10)];
    imageView.image=[UIImage imageNamed:@"title-left.png"];
    [_navView addSubview:imageView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appdelegate.firstLogin == 0)
    {
        NSDictionary *userDict=[USERDEFAULTS objectForKey:USERDEFAULTS_JINGTUM_USERSURE];
        self.TureNameLabel.enabled=NO;
        self.idTextFiled.enabled=NO;
        self.addressTextFiled.enabled=NO;
        self.segementController.hidden=YES;
        self.sexLabel.hidden=NO;
        self.sendButton.hidden=YES;
        self.TureNameLabel.text=[userDict objectForKey:@"name"];
        NSString *idStr=[NSString stringWithFormat:@"%@",[[userDict objectForKey:@"id"] stringByReplacingCharactersInRange:NSMakeRange(6, 8) withString:JINGTUM_USERID_STAR]];
        self.idTextFiled.text=idStr;
        self.addressTextFiled.text=[userDict objectForKey:@"address"];
        if ([[userDict objectForKey:@"sex"] isEqualToString:@"0"])
        {
            self.sexLabel.text=@"男";
        }
        else if ([[userDict objectForKey:@"sex"] isEqualToString:@"1"])
        {
            self.sexLabel.text=@"女";
        }
    }
    
}

- (void)backtoGround
{
    [self.navigationController popViewControllerAnimated:YES];
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

- (IBAction)background:(id)sender
{
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    self.view.frame = rect;
    [UIView commitAnimations];
    
    [self.view endEditing:YES];
    
}


- (void)userSure
{
    NSString * urlStr = [NSString stringWithFormat:@"%@/userReal?sid=%@",GLOBAL_BLOB_VAULT,[[[JingtumJSManager shared] jingtumSession] objectForKey:@"sid"]];
    
    NSDictionary *dict=@{@"type":@2,@"address":self.addressTextFiled.text,@"name":self.TureNameLabel.text,@"nation":@"86",@"sex":sexStr,@"id":self.idTextFiled.text};
    
    [[JingtumJSManager shared] operationManagerPOST:urlStr parameters:dict withBlock:^(NSString *error, id responseData) {
        if ([error isEqualToString:@"0"])
        {
            NSLog(@"实名认证responseData->%@",responseData);
            NSString *datastr=[NSString stringWithFormat:@"%@",responseData[@"data"]];
            if (![datastr isEqualToString:@"<null>"])
            {
                AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
                appdelegate.firstLogin=0;
                
                NSMutableDictionary *userDict=[[NSMutableDictionary alloc] init];
                NSString *nameStr=[NSString stringWithFormat:@"%@",self.TureNameLabel.text];
                NSString *sexstr=[NSString stringWithFormat:@"%@",sexStr];
                NSString *idStr=[NSString stringWithFormat:@"%@",self.idTextFiled.text];
                NSString *nationStr=@"86";
                NSString *addressStr=[NSString stringWithFormat:@"%@",self.addressTextFiled.text];
                
                [userDict setObject:nameStr forKey:@"name"];
                [userDict setObject:sexstr forKey:@"sex"];
                [userDict setObject:idStr forKey:@"id"];
                [userDict setObject:nationStr forKey:@"nation"];
                [userDict setObject:addressStr forKey:@"address"];
                [USERDEFAULTS setObject:userDict forKey:USERDEFAULTS_JINGTUM_USERSURE];
                
                [self sendGit];
            }
            else
            {
                [SVProgressHUD dismiss];
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"认证失败，请检查您的信息是否正确" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil ];
                [alert show];
                
            }
            
        }
        else
        {
            NSLog(@"实名认证请求失败");
            [SVProgressHUD dismiss];
        }
    }];
    
    
}


- (void)sendGit
{
     NSString * urlStr = [NSString stringWithFormat:@"%@/sendGift",GLOBAL_BLOB_VAULT];
     NSDictionary *dict=@{@"address":[[JingtumJSManager shared] jingtumWalletAddress]};
    
    [[JingtumJSManager shared] operationManagerPOST:urlStr parameters:dict withBlock:^(NSString *error, id responseData) {
        if ([error isEqualToString:@"0"])
        {
            NSLog(@"发送GitresponseData->%@",responseData);
            if ([[responseData objectForKey:@"data"] isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *datadict=[NSDictionary dictionaryWithDictionary:[responseData objectForKey:@"data"]];
                NSString *successStr=[NSString stringWithFormat:@"%@",[datadict objectForKey:@"success"]];
                if (![datadict isEqual:@"<null>"]  && [successStr isEqualToString:@"1"])
                {
                    [SVProgressHUD dismiss];
                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"您已成功激活你的账户,获得100SWT." delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil ];
                    [alert show];
                }
                else
                {
                    [SVProgressHUD dismiss];
                    NSString *message=[NSString stringWithFormat:@"错误:%@",[datadict objectForKey:@"message"]];
                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil ];
                    [alert show];
                }
            }
            else
            {
                [SVProgressHUD dismiss];
                NSString *message=[NSString stringWithFormat:@"错误:%@",[[responseData objectForKey:@"error"] objectForKey:@"message"]];
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil ];
                [alert show];
            }

        }
        else
        {
            NSLog(@"发送Git请求失败");
            [SVProgressHUD dismiss];
        }
    }];
    
     
}

- (IBAction)mSelectSegment:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0)
    {
        sexStr=@"0";
    }
    else if (sender.selectedSegmentIndex == 1)
    {
        sexStr=@"1";
    }
}

- (IBAction)sendBtn:(id)sender
{
    [self.TureNameLabel resignFirstResponder];
    [self.idTextFiled resignFirstResponder];
    [self.addressTextFiled resignFirstResponder];
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    self.view.frame = rect;
    [UIView commitAnimations];
    [self delayMethod];
    
    
}

- (void)delayMethod
{
    AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([self chk18PaperId:self.idTextFiled.text] == YES)
    {
        if (appdelegate.firstLogin==1)
        {
            
            [SVProgressHUD showWithStatus:@"认证中..." maskType:SVProgressHUDMaskTypeGradient];
            [self userSure];
            
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"您已经实名认证过了。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"身份证验证失败，请检查。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }

}
    

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        appdelegate.firstLogin=0;
        [[JingtumJSManager shared] logout];
        [appdelegate  setmainview];
//        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

-(BOOL) chk18PaperId:(NSString *) sPaperId

{
    //判断位数
    
    
    if ([sPaperId length] != 15 && [sPaperId length] != 18) {
        return NO;
    }
    NSString *carid = sPaperId;
    
    long lSumQT =0;
    
    //加权因子
    
    int R[] ={7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2 };
    
    //校验码
    
    unsigned char sChecker[11]={'1','0','X', '9', '8', '7', '6', '5', '4', '3', '2'};
    
    
    
    //将15位身份证号转换成18位
    
    NSMutableString *mString = [NSMutableString stringWithString:sPaperId];
    
    if ([sPaperId length] == 15) {
        
        [mString insertString:@"19" atIndex:6];
        
        long p = 0;
        
        const char *pid = [mString UTF8String];
        
        for (int i=0; i<=16; i++)
            
        {
            
            p += (pid[i]-48) * R[i];
            
        }
        
        int o = p%11;
        
        NSString *string_content = [NSString stringWithFormat:@"%c",sChecker[o]];
        
        [mString insertString:string_content atIndex:[mString length]];
        
        carid = mString;
        
    }
    
    //判断地区码
    
    NSString * sProvince = [carid substringToIndex:2];
    
    if (![self areaCode:sProvince]) {
        
        return NO;
        
    }
    
    //判断年月日是否有效
    
    
    
    //年份
    
    int strYear = [[self getStringWithRange:carid Value1:6 Value2:4] intValue];
    
    //月份
    
    int strMonth = [[self getStringWithRange:carid Value1:10 Value2:2] intValue];
    
    //日
    
    int strDay = [[self getStringWithRange:carid Value1:12 Value2:2] intValue];
    
    
    
    NSTimeZone *localZone = [NSTimeZone localTimeZone];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    [dateFormatter setTimeZone:localZone];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *date=[dateFormatter dateFromString:[NSString stringWithFormat:@"%d-%d-%d 12:01:01",strYear,strMonth,strDay]];
    
    if (date == nil) {
        
        return NO;
        
    }
    
    const char *PaperId  = [carid UTF8String];
    
    //检验长度
    
    if( 18 != strlen(PaperId)) return -1;
    
    
    
    //校验数字
    
    for (int i=0; i<18; i++)
        
    {
        
        if ( !isdigit(PaperId[i]) && !(('X' == PaperId[i] || 'x' == PaperId[i]) && 17 == i) )
            
        {
            
            return NO;
            
        }
        
    }
    
    //验证最末的校验码
    
    for (int i=0; i<=16; i++)
        
    {
        
        lSumQT += (PaperId[i]-48) * R[i];
        
    }
    
    if (sChecker[lSumQT%11] != PaperId[17] )
        
    {
        
        return NO;
        
    }
    
    return YES;
    
}

-(BOOL)areaCode:(NSString *)code

{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    [dic setObject:@"北京" forKey:@"11"];
    
    [dic setObject:@"天津" forKey:@"12"];
    
    [dic setObject:@"河北" forKey:@"13"];
    
    [dic setObject:@"山西" forKey:@"14"];
    
    [dic setObject:@"内蒙古" forKey:@"15"];
    
    [dic setObject:@"辽宁" forKey:@"21"];
    
    [dic setObject:@"吉林" forKey:@"22"];
    
    [dic setObject:@"黑龙江" forKey:@"23"];
    
    [dic setObject:@"上海" forKey:@"31"];
    
    [dic setObject:@"江苏" forKey:@"32"];
    
    [dic setObject:@"浙江" forKey:@"33"];
    
    [dic setObject:@"安徽" forKey:@"34"];
    
    [dic setObject:@"福建" forKey:@"35"];
    
    [dic setObject:@"江西" forKey:@"36"];
    
    [dic setObject:@"山东" forKey:@"37"];
    
    [dic setObject:@"河南" forKey:@"41"];
    
    [dic setObject:@"湖北" forKey:@"42"];
    
    [dic setObject:@"湖南" forKey:@"43"];
    
    [dic setObject:@"广东" forKey:@"44"];
    
    [dic setObject:@"广西" forKey:@"45"];
    
    [dic setObject:@"海南" forKey:@"46"];
    
    [dic setObject:@"重庆" forKey:@"50"];
    
    [dic setObject:@"四川" forKey:@"51"];
    
    [dic setObject:@"贵州" forKey:@"52"];
    
    [dic setObject:@"云南" forKey:@"53"];
    
    [dic setObject:@"西藏" forKey:@"54"];
    
    [dic setObject:@"陕西" forKey:@"61"];
    
    [dic setObject:@"甘肃" forKey:@"62"];
    
    [dic setObject:@"青海" forKey:@"63"];
    
    [dic setObject:@"宁夏" forKey:@"64"];
    
    [dic setObject:@"新疆" forKey:@"65"];
    
    [dic setObject:@"台湾" forKey:@"71"];
    
    [dic setObject:@"香港" forKey:@"81"];
    
    [dic setObject:@"澳门" forKey:@"82"];
    
    [dic setObject:@"国外" forKey:@"91"];
    
    if ([dic objectForKey:code] == nil) {
        
        return NO;
        
    }
    
    return YES;
    
}


-(NSString *)getStringWithRange:(NSString *)str Value1:(int)value1 Value2:(NSInteger )value2;

{
    
    return [str substringWithRange:NSMakeRange(value1,value2)];
    
}


@end
