//
//  UserAccountViewController.m
//  Jingtum
//
//  Created by sunbinbin on 14-11-17.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "UserAccountViewController.h"
#import "AppDelegate.h"

@interface UserAccountViewController ()
{
    UIView *_navView;
}
@end

@implementation UserAccountViewController

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
    [titleLabel setText:@"账户设置"];
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
    
    
    self.titleList=@[@"账户名",@"账户类型",@"账号二维码",@"实名认证"];
//    self.imageList=@[@"",@"account.png",@"QR.png",@"truename.png"];
    
//    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.tableView.tableFooterView=[[UIView alloc] init];
}

- (void)backtoGround
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titleList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    cell.textLabel.textColor=RGBA(109, 109, 109, 1);
    cell.textLabel.font=[UIFont fontWithName:@"Helvetica" size:14.0];
    cell.textLabel.text=self.titleList[indexPath.row];
//    cell.imageView.image=[UIImage imageNamed:self.imageList[indexPath.row]];
    if (indexPath.row == 0)
    {
        cell.accessoryType=UITableViewCellAccessoryNone;
        UILabel *nameLabel=[[UILabel alloc] initWithFrame:CGRectMake1(188, 12, 100, 20)];
        nameLabel.textAlignment=NSTextAlignmentRight;
        nameLabel.textColor=RGBA(109, 109, 109, 1);
        nameLabel.font=[UIFont fontWithName:@"Helvetica" size:14.0];
        nameLabel.text=[NSString stringWithFormat:@"%@",[USERDEFAULTS objectForKey:USERDEFAULTS_JINGTUM_USERNAME]];
        [cell.contentView addSubview:nameLabel];
        
    }
    if (indexPath.row == 1)
    {
        cell.accessoryType=UITableViewCellAccessoryNone;
        UILabel *typeLabel=[[UILabel alloc] initWithFrame:CGRectMake1(188, 12, 100, 20)];
        typeLabel.textAlignment=NSTextAlignmentRight;
        typeLabel.textColor=RGBA(109, 109, 109, 1);
        typeLabel.font=[UIFont fontWithName:@"Helvetica" size:14.0];
        typeLabel.text=[NSString stringWithFormat:@"个人账户"];
        [cell.contentView addSubview:typeLabel];
    }
    if (indexPath.row == 3)
    {
        AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (appdelegate.firstLogin == 0)
        {
            
            UILabel *verLabel=[[UILabel alloc] initWithFrame:CGRectMake1(188, 12, 100, 20)];
            verLabel.textAlignment=NSTextAlignmentRight;
            verLabel.textColor=RGBA(109, 109, 109, 1);
            verLabel.font=[UIFont fontWithName:@"Helvetica" size:14.0];
            verLabel.text=[NSString stringWithFormat:@"已验证"];
            [cell.contentView addSubview:verLabel];
        }
        else if (appdelegate.firstLogin == 1)
        {
            UILabel *verLabel=[[UILabel alloc] initWithFrame:CGRectMake1(188 ,12, 100, 20)];
            verLabel.textAlignment=NSTextAlignmentRight;
            verLabel.textColor=RGBA(109, 109, 109, 1);
            verLabel.font=[UIFont fontWithName:@"Helvetica" size:14.0];
            verLabel.text=[NSString stringWithFormat:@"未验证"];
            [cell.contentView addSubview:verLabel];

            UIImageView *dotImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"redcircular.png"]];
            dotImage.backgroundColor = [UIColor clearColor];
            dotImage.frame=CGRectMake1(120, 14, 6, 6);
            [cell.contentView addSubview:dotImage];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2)
    {
        [self performSegueWithIdentifier:@"qrcode" sender:nil];
    }
    else if (indexPath.row == 3)
    {
        [self performSegueWithIdentifier:@"ture" sender:nil];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
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
