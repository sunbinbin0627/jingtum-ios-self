

#define GLOBAL_BLOB_VAULT           @"http://rztong.jingtum.com/api/user" //192.168.10.201
#define GLOBAL_Jingtum_LIB_VERSION   @"jingtum-0.7.36(1)"

#define GLOBAL_XRP_STRING @"SWT"
#define XRP_FACTOR @"1000000.0"

//历史账单拉取的数量
#define MAX_TRANSACTIONS 30

#define SSKEYCHAIN_SERVICE      @"jingtum"

//通知
#define kNotificationUpdatedBalance             @"notificationUpdatedBalance"
#define kNotificationUpdatedShopCard            @"notificationUpdatedShopCard"
#define kNotificationUpdatedBalanceList         @"notificationUpdatedBalanceList"
#define kNotificationUpdatedAccountTx           @"notificationUpdatedAccountTx"
#define kNotificationAccountRefresh             @"notificationAccountRefresh"
#define kNotificationAccountChange              @"notificationAccountChange"
#define kNotificationCardInfoChange             @"notificationCardInfoChange"
#define kNotificationUserLoggedIn               @"notificationUserLoggedIn"
#define kNotificationUserLoggedOut              @"notificationUserLoggedOut"
#define kNotificationHistoryChange              @"notificationHistoryChange"
#define kNotificationUserSecret                 @"notificationUserSecret"


#define JINGTUM_APPID                       @"930383148"
#define JINGTUM_ISSURE                      @"janxMdrWE2SUzTqRUtfycH4UGewMMeHa9f"// jfxfa81B4VLd7yvx9EQ8wTDe45qs6PVH1k
#define JINGTUM_TIME                        @946656000
#define JINGTUM_URL                         @"http://rztong.jingtum.com"
#define JINGTUM_TIPS_SEVER                  @"http://rztong.jingtum.com/api/sendTips/sendTips"
#define JINGTUM_SHOP                        @"http://rztong.jingtum.com/api/currency"
#define JINGTUM_SHOP_OTHERPHOTO             @"http://115.28.26.220:10018/buckets/other/keys"
#define JINGTUM_SHOP_PHOTO                  @"http://115.28.26.220:10018/buckets/photo/keys"

//本地存储
#define USERDEFAULTS [NSUserDefaults standardUserDefaults]
#define USERDEFAULTS_JINGTUM_KEY             @"JingTumKey"
#define USERDEFAULTS_JINGTUM_USERNAME        @"JingTumUsername"
#define USERDEFAULTS_JINGTUM_SECRT           @"JingTumSeed"
#define USERDEFAULTS_JINGTUM_USERNAMEDECRYPT @"JingTumUsernameDecrypt"
#define USERDEFAULTS_JINGTUM_USERSESSION     @"JingTumSession"
#define USERDEFAULTS_JINGTUM_SHOPSURE        @"jingtumShopsure"//卡包里币种和名字的对应
#define USERDEFAULTS_JINGTUM_MARKER          @"jingtumMarker"//保存历史账单的marker值
#define USERDEFAULTS_JINGTUM_USERSURE        @"jingtumUserSure"//保存用户的实名信息
#define USERDEFAULTS_JINGTUM_XIALA           @"jingtumXiaLa"//保存钱包页下拉账单
#define USERDEFAULTS_JINGTUM_SHOPCARD        @"jingtumShopcard"//卡包币种和余额的对应
#define USERDEFAULTS_JINGTUM_CNY             @"jingtumCNY"//CNY的余额
#define USERDEFAULTS_JINGTUM_PHONE           @"JingTumPhone"//保存电话号码
#define USERDEFAULTS_JINGTUM_LASTLOGIN       @"JingTumLastLogin"//保存最后一次登录时间
#define USERDEFAULTS_JINGTUM_MIDDLEADDRESS   @"JingTumMiddleAddress"//保存中间人得公钥地址
#define USERDEFAULTS_JINGTUM_MIDDLESECRET    @"JingTumMiddleSecret"//保存中间人得私钥地址
#define USERDEFAULTS_JINGTUM_ISSURE          @"JingTumIssure"//保存银关地址
#define USERDEFAULTS_JINGTUM_PAYSECRET       @"JingTumPaySecret"//保存支付密码的状态


#define JINGTUM_SAVETOKEN                   @"savetoken"
#define JINGTUM_COOKIE                      @"cookie"
#define CONNECT                             1
#define DISCONNECT                          0
#define JINGTUM_TIMER_ADD                   @8
#define kFilename                           @"data.sqlite"
#define JINGTUM_HISTORY_STAR                @"..."
#define JINGTUM_USERID_STAR                 @"********"

//获取屏幕 宽度、高度
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define isIos7      ([[[UIDevice currentDevice] systemVersion] floatValue])
#define StatusbarSize ((isIos7 >= 7 && __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1)?20.f:0.f)
#define NavViewHeigth ((SCREEN_WIDTH == 320)?0.f:((SCREEN_WIDTH == 375)?11.f:19.f))

#define RGBA(R/*红*/, G/*绿*/, B/*蓝*/, A/*透明*/) \
[UIColor colorWithRed:R/255.f green:G/255.f blue:B/255.f alpha:A]

#define ISIPHONE5 568
#define ISIPHONE4 480


#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
#define IOS7_SDK_AVAILABLE 1
#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
#define IOS8_SDK_AVAILABLE 1
#endif







