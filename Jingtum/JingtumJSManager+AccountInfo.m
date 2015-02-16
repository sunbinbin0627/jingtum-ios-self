//
//  JingtumJSManager+AccountInfo.m
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "JingtumJSManager+AccountInfo.h"
#import "NSString+Hashes.h"

@implementation JingtumJSManager (AccountInfo)

-(void)wrapperAccountInfo
{
    
    NSDictionary * params = @{@"account": _blobData.account_id,
                              @"secret": _blobData.master_seed
                              };
    [_bridge callHandler:@"account_info" data:params responseCallback:^(id responseData) {
//        NSLog(@"account_info response: %@", responseData);
        if ([responseData isKindOfClass:[NSDictionary class]] && ![responseData objectForKey:@"error"])
        {
            
            NSString *str=[[responseData objectForKey:@"account_data"] objectForKey:@"Balance"];
            float swtNum=[str longLongValue]*0.000001;
            NSString *str2=[NSString stringWithFormat:@"%.2f",swtNum];
            
            RPWallet *rpwall=[RPWallet new];
            rpwall.type=@"SWT";
            rpwall.num=str2;
            rpwall.key=@"000000";
            rpwall.image=@"wallet_SWT.png";
            rpwall.title=@"SWT(井通币)";
            if ([[UserDB shareInstance] addWallet:rpwall])
            {
                NSLog(@"添加SWT余额到数据库成功");
            }
            else
            {
                NSLog(@"添加SWT余额到数据库失败");
            }
        
        }
        else
        {
            NSString *message=[NSString stringWithFormat:@"错误:%@",[responseData objectForKey:@"error"]];
            if (![[responseData objectForKey:@"error"] isEqualToString:@"remoteError"])
            {
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
           
            
        }
    }];
}


@end
