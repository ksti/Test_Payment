//
//  GJSPayWXpay.m
//  Test_payment
//
//  Created by forp on 15/11/27.
//  Copyright © 2015年 forp. All rights reserved.
//

#import "GJSPayWXpay.h"
#import "WXApi.h"
#import "WXApiRequestHandler.h"
#import "WXApiResponseHandler.h"
#import "GJSUtils.h"
#import "WXUtil.h"
#import "payRequsestHandler.h"
#import "WXpayPartnerConfig.h"

@interface GJSPayWXpay () {
    id<ProductItem>_product;
    id<OrderItem>_order;
}

@end

@implementation GJSPayWXpay

- (void)dealloc {
    self.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        if([WXApi isWXAppInstalled]) // 判断 用户是否安装微信
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getOrderPayResult:) name:ORDER_PAY_NOTIFICATION object:nil];//监听一个通知
            //初始化私有参数，主要是一些和商户有关的参数
            self.payUrl = @"https://api.mch.weixin.qq.com/pay/unifiedorder";
            if (self.debugInfo == nil){
                self.debugInfo = [NSMutableString string];
            }
            [self.debugInfo setString:@""];
        }
    }
    return self;
}

//初始化函数
-(id)initWithAppID:(NSString*)appID mchID:(NSString*)mchID spKey:(NSString*)key
{
    self = [super init];
    if(self)
    {
        if([WXApi isWXAppInstalled]) // 判断 用户是否安装微信
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getOrderPayResult:) name:ORDER_PAY_NOTIFICATION object:nil];//监听一个通知
            //初始化私有参数，主要是一些和商户有关的参数
            self.payUrl = @"https://api.mch.weixin.qq.com/pay/unifiedorder";
            if (self.debugInfo == nil){
                self.debugInfo  = [NSMutableString string];
            }
            [self.debugInfo setString:@""];
            self.appId = appID;//微信分配给商户的appID
            self.mchId = mchID;//
            self.spKey = key;//商户的密钥
        }
    }
    return self;
}

#pragma mark - 通知信息
- (void)getOrderPayResult:(NSNotification *)notification {
    id payment = nil;
    if (_order && _product) {
        payment = nil;
    }else if (_order) {
        payment = _order;
    } else if (_product) {
        payment = _product;
    }
    
    if ([notification.object isEqualToString:@"success"])
    {
        //[self alert:@"恭喜" msg:@"您已成功支付啦!"];
        if ([self.delegate respondsToSelector:@selector(paymentDidSuccess:responseInfo:payType:)]) {
            [self.delegate paymentDidSuccess:payment responseInfo:notification.userInfo[@"response"] payType:WXpayType];
        }
    } else if ([notification.object isEqualToString:@"cancel"]) {
        //[self alert:@"提示" msg:@"用户点击取消并返回"];
        if ([self.delegate respondsToSelector:@selector(paymentDidCanceled:responseInfo:payType:)]) {
            [self.delegate paymentDidCanceled:payment responseInfo:notification.userInfo[@"response"] payType:WXpayType];
        }
    }
    else
    {
        //[self alert:@"提示" msg:@"支付失败"];
        if ([self.delegate respondsToSelector:@selector(paymentDidFailed:responseInfo:payType:)]) {
            [self.delegate paymentDidFailed:payment responseInfo:notification.userInfo[@"response"] payType:AlipayType];
        }
    }
}

//客户端提示信息
- (void)alert:(NSString *)title msg:(NSString *)msg
{
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alter show];
}

//获取debug信息
-(NSString*)getDebugInfo
{
    NSString *res = [NSString stringWithString:self.debugInfo];
    [self.debugInfo setString:@""];
    return res;
}

- (int)genTimeStamp
{
    //return [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    
    int time_stamp = (int)[date timeIntervalSince1970];
    return time_stamp;
}

/**
 选中商品调用微信支付,自定义Product
 */
- (void)actionPayProduct:(id<ProductItem>)product {
    
    //获取prodcut实例并初始化订单信息
    //如果是空返回
    if (product == nil) {
        return;
    }
    _product = product;
    
    /*
     *商户的唯一的parnter和mch。
     *签约后，微信会为每个商户分配一个唯一的 parnter 和 mch。
     */
    
    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/
    NSString *partner = self.partnerId;
    NSString *mch = self.mchId;
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/
    
    //partner和mch获取失败,提示
    if ([partner length] == 0 ||
        [mch length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少partner或者mch。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    /*
     *生成订单信息及签名
     */
    NSString *identifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSDictionary *dictPrepay = [self getPrepayWithOrderName:[product subject] price:[NSString stringWithFormat:@"%f",[product price]] device:identifier];
    [self weiXinPayAction:partner prepay_id:dictPrepay[@"prepayid"] nonceStr:dictPrepay[@"noncestr"] sign:dictPrepay[@"sign"]];
}

/**
 选中商品调用微信支付,自定义Order
 */
- (void)actionPayOrder:(id<OrderItem>)customOrder {
    
    //获取customOrder实例并初始化订单信息
    //如果是空返回
    if (customOrder == nil) {
        return;
    }
    _order = customOrder;
    
    /*
     *商户的唯一的parnter和mch。
     *签约后，微信会为每个商户分配一个唯一的 parnter 和 mch。
     */
    
    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/
    NSString *partner = self.partnerId;
    NSString *mch = self.mchId;
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/
    
    //partner和mch获取失败,提示
    if ([partner length] == 0 ||
        [mch length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少partner或者mch。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    /*
     *生成订单信息及签名
     */
    //[self weiXinPayAction:partner prepay_id:[customOrder prepayid] nonceStr:[customOrder noncestr] sign:[customOrder signedString]];
    [self weiXinPayAction:partner prepay_id:[customOrder prepayid] nonceStr:[customOrder noncestr] selfSign:[customOrder signedString]];
}

/**
 *  weiXinPayAction
 */

-(void)weiXinPayAction:(NSString*)partner_idStr prepay_id:(NSString*)prepay_idStr {
    
    payRequsestHandler *handler = [[payRequsestHandler alloc]init];
    
    int randomX = arc4random() %10000;
    
    PayReq*request = [[PayReq alloc]init];
    
    request.openID = self.appId;//公众账号ID
    
    request.partnerId = partner_idStr;//商户号
    
    request.prepayId = prepay_idStr;//(接口返回--预支付交易会话ID)
    
    request.package = @"Sign=WXPay";//(固定写法)
    
    request.nonceStr=[WXUtil md5:[[NSString alloc]initWithFormat:@"%d",randomX]];//随机字符串
    
    int time_stamp = [self genTimeStamp];
    
    request.timeStamp= time_stamp;//时间戳
    
    NSDictionary*parameters =@{@"appid":self.appId,@"partnerid":partner_idStr,@"prepayid":prepay_idStr,@"package":@"Sign=WXPay",@"noncestr":request.nonceStr,@"timestamp":[[NSString alloc]initWithFormat:@"%d",time_stamp]};
    
    NSMutableDictionary*mutableDic=[[NSMutableDictionary alloc]initWithDictionary:parameters];
    
    [handler setKey:partner_idStr];
    
    request.sign=[handler createMd5Sign:mutableDic];
    
    [WXApi sendReq:request];
}

/**
 *  weiXinPayAction 自助签名
 */

-(void)weiXinPayAction:(NSString*)partner_idStr prepay_id:(NSString*)prepay_idStr nonceStr:(NSString *)nonceStr selfSign:(NSString *)signedString {
    
    payRequsestHandler *handler = [[payRequsestHandler alloc]init];
    
    //int randomX = arc4random() %10000;
    
    PayReq*request = [[PayReq alloc]init];
    
    request.openID = self.appId;//公众账号ID
    
    request.partnerId = partner_idStr;//商户号
    
    request.prepayId = prepay_idStr;//(接口返回--预支付交易会话ID)
    
    request.package = @"Sign=WXPay";//(固定写法)
    
    //request.nonceStr=[WXUtil md5:[[NSString alloc]initWithFormat:@"%d",randomX]];//随机字符串
    request.nonceStr = nonceStr;
    
    int time_stamp = [self genTimeStamp];
    
    request.timeStamp= time_stamp;//时间戳
    
    NSDictionary*parameters =@{@"appid":self.appId,@"partnerid":partner_idStr,@"prepayid":prepay_idStr,@"package":@"Sign=WXPay",@"noncestr":request.nonceStr,@"timestamp":[[NSString alloc]initWithFormat:@"%d",time_stamp], @"sign":signedString};
    
    NSMutableDictionary*mutableDic=[[NSMutableDictionary alloc]initWithDictionary:parameters];
    
    [handler setKey:partner_idStr];
    
    request.sign=[handler createMd5Sign:mutableDic];
    
    [WXApi sendReq:request];
}

- (void)weiXinPayAction:(NSString*)partner_idStr prepay_id:(NSString*)prepay_idStr nonceStr:(NSString *)nonceStr sign:(NSString *)signedString {
    /*
    PayReq *request = [[PayReq alloc] init];
    request.partnerId = @"10000100";
    request.prepayId= @"1101000000140415649af9fc314aa427";
    request.package = @"Sign=WXPay";
    request.nonceStr= @"a462b76e7436e98e0ed6e13c64b4fd1c";
    request.timeStamp= @"1397527777";
    request.sign= @"582282D72DD2B03AD892830965F428CB16E7A256";
    */
    PayReq *request = [[PayReq alloc] init];
    request.partnerId = partner_idStr;
    request.prepayId = prepay_idStr;
    request.package = @"Sign=WXPay";
    request.nonceStr = nonceStr;
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    int time_stamp = (int)[date timeIntervalSince1970];
    request.timeStamp = time_stamp;
    request.sign = signedString;
    [WXApi sendReq:request];
}

/*============================================*/
//创建package签名
-(NSString*)createMd5Sign:(NSMutableDictionary*)dict
{
    NSMutableString *contentString  =[NSMutableString string];
    NSArray *keys = [dict allKeys];
    //按字母顺序排序
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    //拼接字符串
    for (NSString *categoryId in sortedArray) {
        if (   ![[dict objectForKey:categoryId] isEqualToString:@""]
            && ![categoryId isEqualToString:@"sign"]
            && ![categoryId isEqualToString:@"key"]
            )
        {
            [contentString appendFormat:@"%@=%@&", categoryId, [dict objectForKey:categoryId]];
        }
        
    }
    //添加key字段
    [contentString appendFormat:@"key=%@", self.spKey];
    //得到MD5 sign签名
    NSString *md5Sign =[WXUtil md5:contentString];
    
    //输出Debug Info
    [self.debugInfo appendFormat:@"MD5签名字符串：%@",contentString];
    
    return md5Sign;
}

//获取package带参数的签名包
-(NSString *)genPackage:(NSMutableDictionary*)packageParams
{
    NSString *sign;
    NSMutableString *reqPars=[NSMutableString string];
    //生成签名
    sign = [self createMd5Sign:packageParams];
    //生成xml的package
    NSArray *keys = [packageParams allKeys];
    [reqPars appendString:@"<xml>"];
    for (NSString *categoryId in keys) {
        //[reqPars appendFormat:@"<%@>%@<!--%@--></%@>", categoryId, [packageParams objectForKey:categoryId], categoryId, categoryId];
        [reqPars appendFormat:@"<%@>%@</%@>", categoryId, [packageParams objectForKey:categoryId], categoryId];
    }
    [reqPars appendFormat:@"<sign>%@</sign></xml>", sign];
    
    return [NSString stringWithString:reqPars];
}

//提交预支付
-(NSString *)sendPrepay:(NSMutableDictionary *)prePayParams
{
    NSString *prepayid = nil;
    
    //获取提交支付
    NSString *send = [self genPackage:prePayParams];
    
    //输出Debug Info
    [self.debugInfo appendFormat:@"API链接:%@", self.payUrl];
    [self.debugInfo appendFormat:@"发送的xml:%@", send];
    
    //发送请求post xml数据
    NSData *res = [WXUtil httpSend:self.payUrl method:@"POST" data:send];
    
    //输出Debug Info
    [self.debugInfo appendFormat:@"服务器返回：%@",[[NSString alloc] initWithData:res encoding:NSUTF8StringEncoding]];
    
    XMLHelper *xml = [[XMLHelper alloc] init];
    
    //开始解析
    [xml startParse:res];
    
    NSMutableDictionary *resParams = [xml getDict];
    
    //判断返回
    NSString *return_code   = [resParams objectForKey:@"return_code"];
    NSString *return_msg   = [resParams objectForKey:@"return_msg"];
    NSString *result_code   = [resParams objectForKey:@"result_code"];
    if ( [return_code isEqualToString:@"SUCCESS"] )
    {
        //生成返回数据的签名
        NSString *sign      = [self createMd5Sign:resParams ];
        NSString *send_sign =[resParams objectForKey:@"sign"] ;
        
        //验证签名正确性
        if( [sign isEqualToString:send_sign]){
            if( [result_code isEqualToString:@"SUCCESS"]) {
                //验证业务处理状态
                prepayid    = [resParams objectForKey:@"prepay_id"];
                return_code = 0;
                
                [self.debugInfo appendFormat:@"获取预支付交易标示成功！"];
            }
        }else{
            self.lastErrCode = 1;
            [self.debugInfo appendFormat:@"gen_sign=%@&_sign=%@",sign,send_sign];
            [self.debugInfo appendFormat:@"服务器返回签名验证错误！！！"];
        }
    }else{
        self.lastErrCode = 2;
        [self.debugInfo appendFormat:@"接口返回错误！！！"];
        [GJSUtils showMessage:return_msg];
    }
    
    return prepayid;
}

- (NSMutableDictionary*)getPrepayWithOrderName:(NSString*)name
                                         price:(NSString*)price
                                        device:(NSString*)device
{
    //订单标题，展示给用户
    NSString* orderName = name;
    //订单金额,单位（分）
    NSString* orderPrice = price;//以分为单位的整数
    //支付设备号或门店号
    NSString* orderDevice = device;
    //支付类型，固定为APP
    NSString* orderType = @"APP";
    //发起支付的机器ip,暂时没有发现其作用
    NSString* orderIP = @"196.168.1.1";
    
    //随机数串
    srand( (unsigned)time(0) );
    NSString *noncestr  = [NSString stringWithFormat:@"%d", rand()];
    NSString *orderNO   = [NSString stringWithFormat:@"%ld",time(0)];
    
    //================================
    //预付单参数订单设置
    //================================
    NSMutableDictionary *packageParams = [NSMutableDictionary dictionary];
    
    [packageParams setObject: self.appId  forKey:@"appid"];       //开放平台appid
    [packageParams setObject: self.mchId  forKey:@"mch_id"];      //商户号
    [packageParams setObject: orderDevice  forKey:@"device_info"]; //支付设备号或门店号
    [packageParams setObject: noncestr     forKey:@"nonce_str"];   //随机串
    [packageParams setObject: orderType    forKey:@"trade_type"];  //支付类型，固定为APP
    [packageParams setObject: orderName    forKey:@"body"];        //订单描述，展示给用户
    [packageParams setObject: NOTIFY_URL  forKey:@"notify_url"];  //支付结果异步通知
    [packageParams setObject: orderNO      forKey:@"out_trade_no"];//商户订单号
    [packageParams setObject: orderIP      forKey:@"spbill_create_ip"];//发起支付的机器ip
    [packageParams setObject: orderPrice   forKey:@"total_fee"];       //订单金额，单位为分
    
    //获取prepayId（预支付交易会话标识）
    NSString *prePayid;
    prePayid = [self sendPrepay:packageParams];
    
    if(prePayid == nil)
    {
        [self.debugInfo appendFormat:@"获取prepayid失败！"];
        return nil;
    }
    
    //获取到prepayid后进行第二次签名
    NSString    *package, *time_stamp, *nonce_str;
    //设置支付参数
    time_t now;
    time(&now);
    time_stamp  = [NSString stringWithFormat:@"%ld", now];
    nonce_str = [WXUtil md5:time_stamp];
    //重新按提交格式组包，微信客户端暂只支持package="Sign=WXPay"格式，须考虑升级后支持携带package具体参数的情况
    //package       = [NSString stringWithFormat:@"Sign=%@",package];
    package = @"Sign=WXPay";
    //第二次签名参数列表
    NSMutableDictionary *signParams = [NSMutableDictionary dictionary];
    [signParams setObject:self.appId forKey:@"appid"];
    [signParams setObject:self.mchId forKey:@"partnerid"];
    [signParams setObject:nonce_str forKey:@"noncestr"];
    [signParams setObject:package forKey:@"package"];
    [signParams setObject:time_stamp forKey:@"timestamp"];
    [signParams setObject:prePayid forKey:@"prepayid"];
    
    //生成签名
    NSString *sign  = [self createMd5Sign:signParams];
    
    //添加签名
    [signParams setObject:sign forKey:@"sign"];
    
    [self.debugInfo appendFormat:@"第二步签名成功，sign＝%@",sign];
    
    //返回参数列表
    return signParams;
}

- (NSMutableDictionary*)getPrepayWithNonce_str:(NSString*)nonce_str
                                      prePayId:(NSString*)prePayId
                                          sign:(NSString*)sign
{
    //获取到prepayid后进行第二次签名
    NSString *package, *time_stamp;
    //设置支付参数
    time_t now;
    time(&now);
    time_stamp  = [NSString stringWithFormat:@"%ld", now];
    //重新按提交格式组包，微信客户端暂只支持package="Sign=WXPay"格式，须考虑升级后支持携带package具体参数的情况
    //package       = [NSString stringWithFormat:@"Sign=%@",package];
    package = @"Sign=WXPay";
    //第二次签名参数列表
    NSMutableDictionary *signParams = [NSMutableDictionary dictionary];
    [signParams setObject:self.appId forKey:@"appid"];
    [signParams setObject:self.mchId forKey:@"partnerid"];
    [signParams setObject:nonce_str forKey:@"noncestr"];
    [signParams setObject:package forKey:@"package"];
    [signParams setObject:time_stamp forKey:@"timestamp"];
    [signParams setObject:prePayId forKey:@"prepayid"];
    
    //添加签名
    [signParams setObject:sign forKey:@"sign"];
    
    [self.debugInfo appendFormat:@"第二步签名成功，sign＝%@",sign];
    
    //返回参数列表
    return signParams;
}

- (NSString*)getPrepaySignWithOrderName:(NSString*)name
                                         price:(NSString*)price
                                        device:(NSString*)device
{
    //订单标题，展示给用户
    NSString* orderName = name;
    //订单金额,单位（分）
    NSString* orderPrice = price;//以分为单位的整数
    //支付设备号或门店号
    NSString* orderDevice = device;
    //支付类型，固定为APP
    NSString* orderType = @"APP";
    //发起支付的机器ip,暂时没有发现其作用
    NSString* orderIP = @"196.168.1.1";
    
    //随机数串
    srand( (unsigned)time(0) );
    NSString *noncestr  = [NSString stringWithFormat:@"%d", rand()];
    NSString *orderNO   = [NSString stringWithFormat:@"%ld",time(0)];
    
    //================================
    //预付单参数订单设置
    //================================
    NSMutableDictionary *packageParams = [NSMutableDictionary dictionary];
    
    [packageParams setObject: self.appId  forKey:@"appid"];       //开放平台appid
    [packageParams setObject: self.mchId  forKey:@"mch_id"];      //商户号
    [packageParams setObject: orderDevice  forKey:@"device_info"]; //支付设备号或门店号
    [packageParams setObject: noncestr     forKey:@"nonce_str"];   //随机串
    [packageParams setObject: orderType    forKey:@"trade_type"];  //支付类型，固定为APP
    [packageParams setObject: orderName    forKey:@"body"];        //订单描述，展示给用户
    [packageParams setObject: NOTIFY_URL  forKey:@"notify_url"];  //支付结果异步通知
    [packageParams setObject: orderNO      forKey:@"out_trade_no"];//商户订单号
    [packageParams setObject: orderIP      forKey:@"spbill_create_ip"];//发器支付的机器ip
    [packageParams setObject: orderPrice   forKey:@"total_fee"];       //订单金额，单位为分
    
    //获取prepayId（预支付交易会话标识）
    NSString *prePayid;
    prePayid = [self sendPrepay:packageParams];
    
    if(prePayid == nil)
    {
        [self.debugInfo appendFormat:@"获取prepayid失败！"];
        return nil;
    }
    
    //获取到prepayid后进行第二次签名
    NSString    *package, *time_stamp, *nonce_str;
    //设置支付参数
    time_t now;
    time(&now);
    time_stamp  = [NSString stringWithFormat:@"%ld", now];
    nonce_str = [WXUtil md5:time_stamp];
    //重新按提交格式组包，微信客户端暂只支持package="Sign=WXPay"格式，须考虑升级后支持携带package具体参数的情况
    //package       = [NSString stringWithFormat:@"Sign=%@",package];
    package = @"Sign=WXPay";
    //第二次签名参数列表
    NSMutableDictionary *signParams = [NSMutableDictionary dictionary];
    [signParams setObject:self.appId forKey:@"appid"];
    [signParams setObject:self.mchId forKey:@"partnerid"];
    [signParams setObject:nonce_str forKey:@"noncestr"];
    [signParams setObject:package forKey:@"package"];
    [signParams setObject:time_stamp forKey:@"timestamp"];
    [signParams setObject:prePayid forKey:@"prepayid"];
    
    //生成签名
    NSString *sign  = [self createMd5Sign:signParams];
    
    //返回参数列表
    return sign;
}

@end
