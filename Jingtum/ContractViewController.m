//
//  ContractViewController.m
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "ContractViewController.h"
#import "conDetailViewController.h"
#import "AddContractViewController.h"
#import "JingtumJSManager.h"
#import "JingtumJSManager+NetworkStatus.h"
#import "RPContact.h"
#import "pinyin.h"
#import "ChineseString.h"
#import "Contracts.h"
#import "ZBarSDK.h"
#import "QRCodeGenerator.h"
#import "SCLAlertView.h"
#import <sqlite3.h>
#import "UserDB.h"
#import "AppDelegate.h"

@interface ContractViewController ()
{
    NSMutableArray *contracts;
    NSMutableDictionary *realContracts;
    NSString *tmpName,*tmpAddress;
    UISearchDisplayController *searchController;//搜索的控制器
    NSMutableArray *filterNames;//搜索的结果
    NSArray *filter;//索引的数组
    UIView *_navView;
    
    ZBarReaderController *cameraReader;//相册获取二维码
    ZBarReaderViewController *myReader;//相机扫描二维码
    UIAlertView *alertCamera;//扫描相册二维码无效时弹出框
    UIImageView* line;//二维码扫描线
    NSTimer* lineTimer;//二维码扫描线计时器。
    BOOL camera;//判断actionsheet是在当前那个页面显示
    
    UITextField *contractTextFiled;
    NSString *addressStr;
    sqlite3 *db;//sqlite 数据库对象
    BOOL isExistContract;//判断联系人是否存在
    
    BOOL isCamera;
    
}
@end

@implementation ContractViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    [AppDelegate  storyBoradAutoLay:self.view];
    
    [self.tabBarController.tabBar setSelectedImageTintColor:RGBA(54, 189, 237, 1)];
    
    //tabbar图标
#ifdef IOS7_SDK_AVAILABLE
    _walletItem.image = [[UIImage imageNamed:@"contactsOff.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _walletItem.selectedImage  = [[UIImage imageNamed:@"contactson.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
#else
#endif
    
    camera=NO;
    isExistContract=NO;
    
    //自定义navgation
    UIView *statusBarView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, -20.f, self.view.frame.size.width, 0.f)];
    if (isIos7 >= 7 && __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1)
    {
        statusBarView.frame = CGRectMake(statusBarView.frame.origin.x, statusBarView.frame.origin.y, statusBarView.frame.size.width, 20.f);
        statusBarView.backgroundColor = [UIColor clearColor];
        ((UIImageView *)statusBarView).backgroundColor = RGBA(62,130,248,1);
        [self.view addSubview:statusBarView];
    }
    
    _navView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, StatusbarSize-20.f, self.view.frame.size.width, 44.f+NavViewHeigth)];
    ((UIImageView *)_navView).backgroundColor = RGBA(62,130,248,1);
    [self.view insertSubview:_navView belowSubview:statusBarView];
    _navView.userInteractionEnabled = YES;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((_navView.frame.size.width - 200)/2, (_navView.frame.size.height - 40)/2, 200, 40)];
    [titleLabel setText:@"联系人"];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [_navView addSubview:titleLabel];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(_navView.frame.size.width-41, 2, 40, 40)];
    [button setTitle:@"添加" forState:UIControlStateNormal];
    [button setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [button setTintColor:[UIColor whiteColor]];
    [button setBackgroundColor:[UIColor clearColor]];
    button.titleLabel.font=[UIFont systemFontOfSize:13];
    [button addTarget:self action:@selector(addButton) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:button];

    
    //表格 单元格的模板
    UITableView *tableView=(UITableView *)[self.view viewWithTag:1];
    [tableView registerClass:[UITableViewCell class]  forCellReuseIdentifier:@"ContractCell"];
    self.tableView.tableFooterView=[[UIView alloc] init];
    
    //创建搜索框
    UISearchBar *searchBar=[[UISearchBar alloc] initWithFrame:CGRectMake1(0, 44, 320, 44)];
    [self.view addSubview:searchBar];
    
    //searchController 包含了TableView
    searchController=[[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchController.delegate=self;
    searchController.searchResultsDelegate=self;
    searchController.searchResultsDataSource=self;
    
    filterNames=[NSMutableArray array];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getContract];
}

#pragma mark - UIAlertView delegete

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == alertCamera)
    {
        if (buttonIndex == 0)
        {
            [cameraReader dismissViewControllerAnimated:YES completion:nil];
        }
        
    }
}



#pragma mark -- LXActionSheetDelegate

- (void)didClickOnButtonIndex:(NSInteger *)buttonIndex
{
    int index=(int)buttonIndex;
    if (index == 0)
    {
        [self performSegueWithIdentifier:@"add" sender:nil];
    }
    else if (index == 1)
    {
        [self qrcodeContract];
    }
    NSLog(@"%d",(int)buttonIndex);
}

- (void)didClickOnCancelButton
{
    NSLog(@"点击了取消按钮");
}

- (void)qrcodeContract
{
    camera=NO;
    myReader=[ZBarReaderViewController  new];
    myReader.readerDelegate=self;
//    myReader.wantsFullScreenLayout=NO;
    myReader.showsZBarControls=NO;
    [self setOverlayPickerView:myReader];
    myReader.supportedOrientationsMask=ZBarOrientationMaskAll;
    ZBarImageScanner *scanner=myReader.scanner;
    [scanner setSymbology:ZBAR_I25
                   config:ZBAR_CFG_ENABLE
                       to:0];

    [self presentViewController:myReader animated:YES completion:nil];
}

- (void)addButton
{
    self.actionSheet=[[LXActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@[@"输入地址",@"扫描二维码"]];
    [self.actionSheet showInView:self.view];
}



#pragma mark - 二维码扫描

- (void)setOverlayPickerView:(ZBarReaderViewController *)reader

{
    
    //清除原有控件
    
    for (UIView *temp in [reader.view subviews]) {
        
        for (UIButton *button in [temp subviews]) {
            
            if ([button isKindOfClass:[UIButton class]]) {
                
                [button removeFromSuperview];
                
            }
            
        }
        
        for (UIToolbar *toolbar in [temp subviews]) {
            
            if ([toolbar isKindOfClass:[UIToolbar class]]) {
                
                [toolbar setHidden:YES];
                
                [toolbar removeFromSuperview];
                
            }
            
        }
        
    }
    
    
    
    //画中间的基准线
    line = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2-100, self.view.bounds.size.height/2+100, 199, 14)];
    line.image=[UIImage imageNamed:@"ORline(1).png"];
    [reader.view addSubview:line];
    
    //加上扫描线动画
    lineTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(moveLine) userInfo:nil repeats:YES];
    [lineTimer fire];
    
    //navgation
    UIView *statusBarView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, 0.f)];
    if (isIos7 >= 7 && __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1)
    {
        statusBarView.frame = CGRectMake(statusBarView.frame.origin.x, statusBarView.frame.origin.y, statusBarView.frame.size.width, 20.f);
        statusBarView.backgroundColor = [UIColor clearColor];
        ((UIImageView *)statusBarView).backgroundColor = RGBA(62,130,248,1);
        [reader.view addSubview:statusBarView];
    }
    
    _navView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, StatusbarSize, self.view.frame.size.width, 44.f)];
    ((UIImageView *)_navView).backgroundColor = RGBA(62,130,248,1);
    [reader.view insertSubview:_navView belowSubview:statusBarView];
    _navView.userInteractionEnabled = YES;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((_navView.frame.size.width - 200)/2, (_navView.frame.size.height - 40)/2, 200, 40)];
    [titleLabel setText:@"添加联系人"];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [_navView addSubview:titleLabel];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(14, 2, 70, 40)];
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
    
    UIButton *photoButton = [[UIButton alloc] initWithFrame:CGRectMake(_navView.frame.size.width-41, 2, 40, 40)];
    [photoButton setTitle:@"相册" forState:UIControlStateNormal];
    [photoButton setTintColor:[UIColor whiteColor]];
    [photoButton setBackgroundColor:[UIColor clearColor]];
    photoButton.titleLabel.font=[UIFont systemFontOfSize:13];
    [photoButton addTarget:self action:@selector(getPhoto:) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:photoButton];
    
    
    //上方的view
    UIView * upView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height/2-164)];
    upView.alpha = 0.3;
    upView.backgroundColor = [UIColor blackColor];
    [reader.view addSubview:upView];
    
    //左侧的view
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height/2-100, self.view.bounds.size.width/2-100, 200)];
    leftView.alpha = 0.3;
    leftView.backgroundColor = [UIColor blackColor];
    [reader.view addSubview:leftView];
    
    
    //右侧的view
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2+100, self.view.bounds.size.height/2-100, self.view.bounds.size.width/2-100, 200)];
    rightView.alpha = 0.3;
    rightView.backgroundColor = [UIColor blackColor];
    [reader.view addSubview:rightView];
    
    //底部view
    UIView * downView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height/2+100, self.view.bounds.size.width,self.view.bounds.size.height/2-100)];
    downView.alpha = 0.3;
    downView.backgroundColor = [UIColor blackColor];
    [reader.view addSubview:downView];
    
    //扫描边框
    UIImageView *borderImage=[[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2-100, self.view.bounds.size.height/2-100, 200, 200)];
    borderImage.image=[UIImage imageNamed:@"QRborder.png"];
    [borderImage setBackgroundColor:[UIColor clearColor]];
    [reader.view addSubview:borderImage];
    
}

- (void)backtoGround
{
    [lineTimer invalidate];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)getPhoto:(id)sender
{
    //相册获取二维码
    camera=YES;
    cameraReader=[ZBarReaderController new];
    cameraReader.readerDelegate=self;
    cameraReader.showsHelpOnFail=NO;
    cameraReader.allowsEditing=YES;
    cameraReader.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    [myReader presentViewController:cameraReader animated:YES completion:^{
        NSLog(@"跳转成功---");
    }];
}


-(void)moveLine
{
    CGRect lineFrame = line.frame;
    CGFloat y = lineFrame.origin.y;
    y=y-200.0;
    lineFrame.origin.y = y;
    [UIView animateWithDuration:2 animations:^{
        
        line.frame = lineFrame;
        
    }];
    y=y+200.0;
    lineFrame.origin.y=y;
    [UIView animateWithDuration:2 animations:^{
        
        line.frame = lineFrame;
        
    }];
}

- (void)dismissOverlayView:(id)sender
{
    [lineTimer invalidate];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

//二维码扫描
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    id<NSFastEnumeration> results=[info objectForKey:ZBarReaderControllerResults];
    ZBarSymbol *symbol=nil;
    for (symbol in results)
        break;
    if ([[symbol.data substringWithRange:NSMakeRange(11, 7)] isEqualToString:@"jingtum"])
    {
        [myReader.readerView stop];
        [lineTimer invalidate];
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        
        NSArray *jsonarray=[symbol.data componentsSeparatedByString:@"="];
        addressStr=[jsonarray objectAtIndex:1];
        contractTextFiled=[alert addTextField:@"请输入备注(不能为空)"];
//        contractTextFiled.delegate=self;
        [alert addButton:@"确定" actionBlock:^{
            if (![contractTextFiled.text isEqualToString:@""])
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
            if (camera==YES)
            {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else
            {
                [picker dismissViewControllerAnimated:YES completion:nil];
            }
        }];
        NSString *str;
        if ([addressStr isEqualToString:[[JingtumJSManager shared] jingtumWalletAddress]])
        {
            [contractTextFiled removeFromSuperview];
            str=[NSString stringWithFormat:@"你不能添加自己"];
        }
        else
        {
            str=[NSString stringWithFormat:@"你将添加%@",addressStr];
        }
        
        [alert showEdit:picker title:@"添加联系人" subTitle:str closeButtonTitle:nil duration:0.0f];
        
    }
    
}

- (void) readerControllerDidFailToRead: (ZBarReaderController*) reader
                             withRetry: (BOOL) retry
{
    if (retry)
    {
        NSLog(@"获取二维码失败");
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"获取二维码失败,请重新选取." delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        
        alertCamera=alert;
        [alert show];
        
        
    }
}

#pragma mark - 中文排序处理

-(void)updateTx
{
    realContracts=[[NSMutableDictionary alloc] init];
    realContracts=[self zhongWenPaiXu:contracts];
//    NSLog(@"realContracts--->%@",realContracts);
}

-(NSMutableDictionary *)zhongWenPaiXu:(NSMutableArray *)newArray
{
    
    self.namearray=[[NSMutableArray alloc]init];//将所有联系人通过中文排序后的数组
    self.xingarray=[[NSMutableArray alloc]init];//存所有联系人的姓（去重）
    self.addressarray=[[NSMutableArray alloc]init];//存所有联系人的地址
    
    
    //中文排序。
    NSMutableArray *chineseStringsArray=[NSMutableArray array];//存返回的顺序数组
    
    for(int i=0;i<[newArray count];i++)//遍历数组中每个名字
    {
        RPContact *tmp=[newArray objectAtIndex:i];
        ChineseString *chineseString=[[ChineseString alloc]init];
        //对chinesestring进行初始化（类中包括string名字和pinyin名字中所有汉字的开头大写字母）
        
        chineseString.string=tmp.fname;
        chineseString.address=tmp.fid;
        
        if(chineseString.string==nil)//判断名字是否为空
        {
            
            chineseString.string=@"";//如果名字是空就将string赋为0
            
        }
        
        if(![chineseString.string isEqualToString:@""])//判断名字是否为空
        {
            //名字不为空的时侯
            
            NSString *pinYinResult=[NSString string];  //存每个名字中每个字的开头大写字母
            
            //加上以下代码同时获得联系人 得姓
            chineseString.xing=[[NSString stringWithFormat:@"%c",pinyinFirstLetter([chineseString.string characterAtIndex:0])]uppercaseString];//每个名字的姓
            
            
            for(int j=0;j<chineseString.string.length;j++)//遍历名字中的每个字
            {
                
                NSString *singlePinyinLetter=[[NSString stringWithFormat:@"%c",pinyinFirstLetter([chineseString.string characterAtIndex:j])]uppercaseString];//取出字中的开头字母并转为大写字母
                
                pinYinResult=[pinYinResult stringByAppendingString:singlePinyinLetter];//取出名字的所有字的开头字母
            }
            
            chineseString.pinYin=pinYinResult;//将名字中所有字的开头大写字母存入chinesestring对象的pinYin中
        }
        else
        {
            //名字为空的时侯
            chineseString.pinYin=@"";
            
        }
        
        [chineseStringsArray addObject:chineseString];//将包含名字的大写字母和名字的chinesestring对象存在数组中
    }
    
    //按照拼音首字母对这些Strings进行排序
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"pinYin" ascending:YES]];//对pinyin 进行排序  就像sql中的order by后指定的根据谁排序   生成一个数组
    
    [chineseStringsArray sortUsingDescriptors:sortDescriptors];
    
    
    //最终的字典
    NSMutableDictionary *contractdic=[[NSMutableDictionary alloc] init];
    
    //将排好序的联系人的开头字母，名字，地址分别存入到对应的数组中去
    for (ChineseString *temp in chineseStringsArray)
    {
        
        [self.xingarray addObject:temp.xing];//将姓存到xingarray保证不重复
        
        [self.namearray addObject:temp.string];//将姓对应的名字保存起来
        
        [self.addressarray addObject:temp.address];//将姓对应的地址保存起来
//        NSLog(@"=======%@ %@ %@",temp.xing,temp.string,temp.address);
        
    }
    
    //去除姓中相同的姓，如A和A
    for (int i = 0; i<[self.xingarray count]; i++)
    {
        NSString *temp=self.xingarray[i];
        for (int j = i+1;j<[self.xingarray count] ; j++)
        {
            if ([temp isEqualToString:self.xingarray[j]])
            {
                [self.xingarray removeObjectAtIndex:j];
            }
        }
    }
    
    //将姓与和姓相同的名字对应起来保存到字典中。
    for (int i=0; i<[self.xingarray count]; i++)//遍历所有姓
    {
        NSMutableArray *xing00=[[NSMutableArray alloc]init];
        
        for (int j=0; j<[self.namearray count]; j++)//遍历所有联系人
        {
            ChineseString *tempString1=[chineseStringsArray objectAtIndex:j];//依次取出arr中的（chineseString*）对象
            if ([tempString1.xing isEqualToString:[self.xingarray objectAtIndex:i]]==YES) //将每个联系人得姓跟每个姓比较
            {
                Contracts *tmpCon=[[Contracts alloc] init];
                //姓相同就将对应的联系人存起来放入xing00中
                tmpCon.conName=[self.namearray objectAtIndex:j];
                tmpCon.conAddress=[self.addressarray objectAtIndex:j];
                [xing00 addObject:tmpCon];
                
            }
            
        }
        [contractdic setObject:xing00 forKey:[self.xingarray objectAtIndex:i]];//生成对应的字典
    }
    
    return contractdic;
}


#pragma mark - 表格 DataSource DataDelegate

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        
        Contracts *temp=[realContracts objectForKey:self.xingarray[indexPath.section]][indexPath.row];
        NSLog(@"nameStr---%@",temp.conName);
        
        [self deletecontract:temp];
        [self deletecontract2:temp];
        //在tableview中删除联系人
        NSArray *temparray=[NSArray arrayWithArray:contracts];
        for (RPContact *con in temparray)
        {
            NSLog(@"fname---%@",con.fname);
            if ([con.fname isEqualToString:temp.conName])
            {
                [contracts removeObject:con];
            }
        }
        NSLog(@"%@",contracts);
        [self updateTx];
        [self.tableView reloadData];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag==1)
    {
        NSArray *countArr=[realContracts objectForKey:self.xingarray[section]];
        return [countArr count];
        
    }
    else
    {
        return filterNames.count;
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView.tag==1)
    {
        return self.xingarray.count;
    }
    else
    {
        return 1;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    
    if (tableView.tag == 1)
    {
        NSArray *arr=[realContracts objectForKey:[self.xingarray objectAtIndex:indexPath.section]];
        Contracts *tmp=arr[indexPath.row];
        tmpName=tmp.conName;
        tmpAddress=tmp.conAddress;
    }
    else
    {
        for (RPContact *con in contracts)
        {
            if (con.fname==filterNames[indexPath.row])
            {
                tmpName=con.fname;
                tmpAddress=con.fid;
            }
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"detail" sender:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContractCell"];
    
    if (tableView.tag==1)
    {
        NSArray *arr=[realContracts objectForKey:[self.xingarray objectAtIndex:indexPath.section]];
        Contracts *tmp=arr[indexPath.row];
        cell.textLabel.textColor=RGBA(109, 109, 109, 1);
        cell.textLabel.text=tmp.conName;
        cell.detailTextLabel.text=tmp.conAddress;
    }
    else
    {
        cell.textLabel.text=filterNames[indexPath.row];
    }
    
    return cell;
}

//段标题
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView.tag==1)
    {
        return self.xingarray[section];
    }
    return nil;
    
}

//索引的数组
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView.tag==1)
    {
        return self.xingarray;
    }
    return nil;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

#pragma mark - 搜索 delegate
- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:
     @"ContractCell"];
    
}


//一旦searchBar输入内容有变化，则执行这个方法，并询问是否要重新load搜索结果的TableView
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    //将搜索框里的内容清空
    [filterNames removeAllObjects];
    if (searchString.length>0)
    {
        //定义谓词
        NSPredicate *pre=[NSPredicate predicateWithFormat:@"SELF CONTAINS %@",searchString];
      
        NSMutableArray *arr=[[NSMutableArray alloc] init];
        for (RPContact *con in contracts)
        {
            [arr addObject:con.fname];
        }
        //用谓词过滤
        NSArray *matches=[arr filteredArrayUsingPredicate:pre];
        [filterNames addObjectsFromArray:matches];
       
    }
    return YES;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"detail"])
    {
        conDetailViewController *vc=[segue destinationViewController];
        vc.hidesBottomBarWhenPushed=YES;
        vc.name=tmpName;
        vc.address=tmpAddress;
    }
    else if ([segue.identifier isEqualToString:@"add"])
    {
        AddContractViewController *addVC=[segue destinationViewController];
        addVC.hidesBottomBarWhenPushed=YES;
    }
}


#pragma mark - 联系人连接后台

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
                if ([contractTextFiled.text isEqualToString:[[NSString alloc] initWithUTF8String:field1]] || [addressStr isEqualToString:[[NSString alloc] initWithUTF8String:field2]])
                {
                    isExistContract=YES;
                }
                
            }
            NSLog(@"--->%@",contracts);
        }
        sqlite3_finalize(statment);
    }
    sqlite3_close(db);
}

- (void)saveContract
{

    if (![contractTextFiled.text isEqualToString:@""])
    {
        NSString *urlStr=[NSString stringWithFormat:@"%@/add_contact",GLOBAL_BLOB_VAULT];
        NSDictionary *dict=@{@"key":[[JingtumJSManager shared] jingtumUserNameDecrypt],@"address":addressStr,@"name":contractTextFiled.text};
        
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
        
}

- (void)deletecontract:(Contracts *)contmp
{

    //删除后台服务器中联系人的数据
    NSString *urlStr = [NSString stringWithFormat:@"%@/remove_contact",GLOBAL_BLOB_VAULT];
    NSDictionary *dict=@{@"key":[[JingtumJSManager shared] jingtumUserNameDecrypt],@"address":contmp.conAddress};
    
    [[JingtumJSManager shared] operationManagerPOST:urlStr parameters:dict withBlock:^(NSString *error, id responseData) {
        NSLog(@"删除联系人 responseData->%@",responseData);
        if ([error isEqualToString:@"0"])
        {
            if ([responseData[@"error"] isEqual:[NSNull null]])
            {
                NSLog(@"删除成功");
            }
            else
            {
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"消息" message:@"同步删除联系人失败." delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }

        }
        
    }];

}

- (void)getContract
{
    contracts=[NSMutableArray arrayWithArray:[[UserDB shareInstance] findContracts]];
    [self updateTx];
    [self.tableView reloadData];
    
}

- (void)saveContract2
{
    if (![contractTextFiled.text isEqualToString:@""])
    {
        RPContact *rpCon=[RPContact new];
        rpCon.fname=contractTextFiled.text;
        rpCon.fid=addressStr;
        if ([[UserDB shareInstance] addContract:rpCon])
        {
            NSLog(@"添加联系人到数据库成功");
        }
    }
    [self getContract];
    
}

- (void)deletecontract2:(Contracts *)contmp
{
    NSString *nameStr=contmp.conName;
    if ([[UserDB shareInstance] deleteContract:nameStr])
    {
        NSLog(@"在数据库中删除联系人成功");
    }
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
