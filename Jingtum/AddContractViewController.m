//
//  AddContractViewController.m
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "AddContractViewController.h"
#import <sqlite3.h>
#import "JingtumJSManager.h"
#import "JingtumJSManager+NetworkStatus.h"
#import "UserDB.h"
#import "AppDelegate.h"

@interface AddContractViewController ()
{
    UIView *_navView;
    sqlite3 *db;//sqlite 数据库对象
    BOOL isExistContract;//判断联系人是否存在
}
@end

@implementation AddContractViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [AppDelegate  storyBoradAutoLay:self.view];
    
    isExistContract=NO;
    
    //自定义navgation
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
    [titleLabel setText:@"添加联系人"];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [_navView addSubview:titleLabel];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 2+NavViewHeigth/2, 70, 40)];
    [backButton setTitle:@"联系人" forState:UIControlStateNormal];
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

- (void)backtoGround
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)mSendBtn:(id)sender
{
    
    if (![self.mAddressTextFiled.text isEqualToString:@""] && ![self.mNameTextFiled.text isEqualToString:@""])
    {
        [self checkContract];
        if (isExistContract==NO)
        {
            [self saveContract];
            [self saveContract2];
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"联系人已存在" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"内容不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
    
    
}

- (void)checkContract
{
    NSString *filePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",kFilename];
    NSLog(@"filePath--->%@",filePath);
    
    if(sqlite3_open([filePath UTF8String], &db) == SQLITE_OK)
    {
        //查询
        NSString *sql=@"SELECT * FROM contract";
        sqlite3_stmt *statment;
        if(sqlite3_prepare_v2(db, [sql UTF8String], -1, &statment, NULL) == SQLITE_OK)
        {
            //执行查询
            while (sqlite3_step(statment) == SQLITE_ROW)
            {
                char *field1=(char *)sqlite3_column_text(statment, 0);
                char *field2=(char *)sqlite3_column_text(statment, 1);
                if ([self.mNameTextFiled.text isEqualToString:[[NSString alloc] initWithUTF8String:field1]] || [self.mAddressTextFiled.text isEqualToString:[[NSString alloc] initWithUTF8String:field2]])
                {
                    isExistContract=YES;
                }
                
            }
        }
        sqlite3_finalize(statment);
    }
    sqlite3_close(db);
}

- (void)saveContract
{
    
    NSString *urlStr=[NSString stringWithFormat:@"%@/add_contact",GLOBAL_BLOB_VAULT];
    NSDictionary *dict=@{@"key":[[JingtumJSManager shared] jingtumUserNameDecrypt],@"address":self.mAddressTextFiled.text,@"name":self.mNameTextFiled.text};
    
    [[JingtumJSManager shared] operationManagerPOST:urlStr parameters:dict withBlock:^(NSString *error, id responseData) {
        
        NSLog(@"添加联系人 responseData->%@",responseData);
        
        if ([error isEqualToString:@"0"])
        {
            if ([responseData[@"error"] isEqual:[NSNull null]])
            {
                NSLog(@"添加成功");
            }
            else
            {
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"消息" message:@"同步添加联系人失败." delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
        
    }];

}

- (void)saveContract2
{
    RPContact *rpCon=[RPContact new];
    rpCon.fname=self.mNameTextFiled.text;
    rpCon.fid=self.mAddressTextFiled.text;
    if ([[UserDB shareInstance] addContract:rpCon])
    {
        NSLog(@"添加联系人到数据库成功");
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (IBAction)background:(id)sender
{
    [self.view endEditing:YES];
}


@end
