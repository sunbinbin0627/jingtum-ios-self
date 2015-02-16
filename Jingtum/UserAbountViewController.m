//
//  UserAbountViewController.m
//  Jingtum
//
//  Created by sunbinbin on 14-10-21.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "UserAbountViewController.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "JingtumJSManager+NetworkStatus.h"

@interface UserAbountViewController ()
{
    UIView *_navView;
    NSString *currentVersion;//当前版本号
    NSString *newVersionURlString;//最新版本号
}
@end

@implementation UserAbountViewController

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
    
    
    //获取当前应用版本号
    NSDictionary *appInfo = [[NSBundle mainBundle] infoDictionary];
    currentVersion = [appInfo objectForKey:@"CFBundleVersion"];
    
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
    [titleLabel setText:@"关于井通"];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [_navView addSubview:titleLabel];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 2+NavViewHeigth/2, 70, 40)];
    [backButton setTitle:@"设 置" forState:UIControlStateNormal];
    [backButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [backButton setTintColor:[UIColor whiteColor]];
    [backButton setBackgroundColor:[UIColor clearColor]];
    backButton.titleLabel.font=[UIFont systemFontOfSize:13];
    [backButton addTarget:self action:@selector(backtoGround) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:backButton];
    
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(11, (_navView.frame.size.height - 20)/2+5, 7, 10)];
    imageView.image=[UIImage imageNamed:@"title-left.png"];
    [_navView addSubview:imageView];
    
    self.mVersionLabel.text=currentVersion;
    
    self.list=@[@"联系我们",@"检查新版本",@"常见问题",@"意见反馈"];
    
//    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.tableView.tableFooterView=[[UIView alloc] init];
    

    
}

- (void)backtoGround
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UITableViewDelegete

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" ];
    
    cell.textLabel.textColor=RGBA(109, 109, 109, 1);
    cell.textLabel.font=[UIFont fontWithName:@"Helvetica" size:14.0];
    cell.textLabel.text=self.list[indexPath.row];
    if (indexPath.row == 0)
    {
        UILabel *phoneLabel=[[UILabel alloc] initWithFrame:CGRectMake1(140, 10, 140, 20)];
        phoneLabel.textAlignment=NSTextAlignmentRight;
        phoneLabel.textColor=RGBA(109, 109, 109, 1);
        phoneLabel.font=[UIFont fontWithName:@"Helvetica" size:14.0];
        phoneLabel.text=[NSString stringWithFormat:@"0510-85380216-8003"];
        [cell.contentView addSubview:phoneLabel];
    }
    if (indexPath.row == 1)
    {

        UILabel *verLabel=[[UILabel alloc] initWithFrame:CGRectMake1(180, 12, 100, 20)];
        verLabel.textAlignment=NSTextAlignmentRight;
        verLabel.textColor=RGBA(109, 109, 109, 1);
        verLabel.font=[UIFont fontWithName:@"Helvetica" size:14.0];
        verLabel.text=[NSString stringWithFormat:@"当前版本v%@",currentVersion];
        [cell.contentView addSubview:verLabel];

    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row==0)
    {
        UIActionSheet *sheet=[[UIActionSheet alloc] initWithTitle:@"工作时间:每天9:00-17:30" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"呼叫0510-85380216-8003", nil];
        [sheet showInView:self.view];

    }
    else if (indexPath.row==1)
    {
        [self checkUpdateWithAPPID:JINGTUM_APPID];
    }
    else if (indexPath.row==2)
    {
//            [self performSegueWithIdentifier:@"" sender:nil];
    }
    else
    {
        [self sendEMail];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        //跳转到拨打电话
        NSString *phoneStr=[NSString stringWithFormat:@"tel://0510-85380216-8003"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneStr]];
    }
    
}


#pragma mark - 版本验证

- (void)checkUpdateWithAPPID:(NSString *)APPID
{
    [SVProgressHUD showWithStatus:@"正在检查更新..." maskType:SVProgressHUDMaskTypeGradient];
    
    NSString *updateUrlString = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@",APPID];
    
    [[JingtumJSManager shared] operationManagerGET:updateUrlString parameters:nil withBlock:^(NSString *error, id responseData) {
        if ([error isEqualToString:@"0"])
        {
            NSLog(@"版本更新返回数据->%@",responseData);
            if (responseData != nil) {
                NSInteger resultCount = [[responseData objectForKey:@"resultCount"] integerValue];
                if (resultCount == 1) {
                    NSArray *resultArray = [responseData objectForKey:@"results"];
                    NSDictionary *resultDict = [resultArray objectAtIndex:0];
                    NSString *newVersion = [resultDict objectForKey:@"version"];
                    
                    if ([newVersion doubleValue] > [currentVersion doubleValue]) {
                        [SVProgressHUD dismiss];
                        NSString *msg = [NSString stringWithFormat:@"最新版本为%@,是否更新？",newVersion];
                        newVersionURlString = [[resultDict objectForKey:@"trackViewUrl"] copy];
                        //                        NSLog(@"newVersionUrl is %@",newVersionURlString);
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"立即更新" otherButtonTitles:@"暂不", nil];
                        [alertView show];
                    }else
                    {
                        [SVProgressHUD dismiss];
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您使用的是最新版本！" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                        [alertView show];
                    }
                }
            }
            else
            {
                NSLog(@"版本更新请求失败");
                [SVProgressHUD dismiss];
            }

        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"操作失败,请稍后再试!" maskType:SVProgressHUDMaskTypeGradient];
        }
    }];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    NSLog(@"newVersionUrl is %@",newVersionURlString);
    if (buttonIndex == 0) {
            if(newVersionURlString)
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:newVersionURlString]];
            }
    }
}

- (IBAction)aggrementBtn:(id)sender
{
    [self performSegueWithIdentifier:@"aggrement" sender:nil];
}


#pragma mark - 发送邮件

//点击完send后  成功失败都弹框显示：
- (void) alertWithTitle: (NSString *)_title_ msg: (NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_title_
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}
//点击Mail按钮后，触发这个方法
-(void)sendEMail
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    
    if (mailClass != nil)
    {
        if ([mailClass canSendMail])
        {
            [self displayComposerSheet];
        }
        else
        {
            [self launchMailAppOnDevice];
        }
    }
    else
    {
        [self launchMailAppOnDevice];
    }
}
//可以发送邮件的话
-(void)displayComposerSheet
{
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    
    mailPicker.mailComposeDelegate = self;
    
    //设置主题
    [mailPicker setSubject: @"意见反馈"];
    
    // 添加发送者
    NSArray *toRecipients = [NSArray arrayWithObject: @"support@jingtum.com"];
//    NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil];
    //NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com", nil];
    [mailPicker setToRecipients: toRecipients];
//    [mailPicker setCcRecipients:ccRecipients];
    //[picker setBccRecipients:bccRecipients];
    
//    // 添加图片
//    UIImage *addPic = [UIImage imageNamed: @"3.jpg"];
//    NSData *imageData = UIImagePNGRepresentation(addPic);            // png
//    // NSData *imageData = UIImageJPEGRepresentation(addPic, 1);    // jpeg
//    [mailPicker addAttachmentData: imageData mimeType: @"" fileName: @"3.jpg"];
    
    NSString *emailBody = @"请输入您的意见,我们会尽快处理。";
    [mailPicker setMessageBody:emailBody isHTML:NO];
    
    [self presentViewController:mailPicker animated:YES completion:nil];
}
-(void)launchMailAppOnDevice
{
    NSString *recipients = @"mailto:first@example.com&subject=my email!";
    //@"mailto:first@example.com?cc=second@example.com,third@example.com&subject=my email!";
    NSString *body = @"&body=email body!";
    
    NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
    email = [email stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:email]];
}
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    NSString *msg;
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            msg = @"邮件发送取消";
            break;
        case MFMailComposeResultSaved:
            msg = @"邮件保存成功";
            [self alertWithTitle:nil msg:msg];
            break;
        case MFMailComposeResultSent:
            msg = @"邮件发送成功";
            [self alertWithTitle:nil msg:msg];
            break;
        case MFMailComposeResultFailed:
            msg = @"邮件发送失败";
            [self alertWithTitle:nil msg:msg];
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


CG_INLINE CGRect//注意：这里的代码要放在.m文件最下面的位置
CGRectMake1(CGFloat x, CGFloat y, CGFloat width, CGFloat height)
{
    AppDelegate *myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CGRect rect;
    rect.origin.x = x * myDelegate.autoSizeScaleX; rect.origin.y = y * myDelegate.autoSizeScaleY;
    rect.size.width = width * myDelegate.autoSizeScaleX; rect.size.height = height * myDelegate.autoSizeScaleY;
    return rect;
}




@end
