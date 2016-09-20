//
//  GJSPayUnionpay.m
//  Test_payment
//
//  Created by forp on 15/11/27.
//  Copyright © 2015年 forp. All rights reserved.
//

#import "GJSPayUnionpay.h"
#import "UnionPayPartnerConfig.h"
//#import "RSA.h"
#import "RSA_ByUnionPay.h"
#import <CommonCrypto/CommonDigest.h>

@interface GJSPayUnionpay () // <UPPayPluginDelegate>
{
    id<OrderItem>_order;
}

@end

@implementation GJSPayUnionpay

- (void)dealloc {
    self.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getOrderPayResult:) name:ORDER_PAY_NOTIFICATION object:nil];//监听一个通知
    }
    return self;
}

-(instancetype)initPure {
    self = [super init];
    if (self) {
        //
    }
    return self;
}

+(BOOL) handleOpenURL:(NSURL *) url delegate:(id<GJSPayProtocol>) delegate {
    
    //处理银联通过URL启动App时传递的数据
    [[UPPaymentControl defaultControl] handlePaymentResult:url completeBlock:^(NSString *code, NSDictionary *data) {
        
        if (code == nil) {
            NSNotification *notification = [NSNotification notificationWithName:ORDER_PAY_NOTIFICATION object:@"fail" userInfo:[NSDictionary dictionaryWithObjectsAndKeys:UnionpayType,@"payType", [NSDictionary dictionaryWithObjectsAndKeys:code,@"code", data,@"data", nil],@"response", nil]];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            //交易出错
            if (delegate && [delegate respondsToSelector:@selector(paymentDidFailed:responseInfo:payType:)]) {
                [delegate paymentDidFailed:nil responseInfo:[NSDictionary dictionaryWithObjectsAndKeys:UnionpayType,@"payType", [NSDictionary dictionaryWithObjectsAndKeys:code,@"code", data,@"data", nil],@"response", nil] payType:UnionpayType];
            }
        }
        //结果code为成功时，先校验签名，校验成功后做后续处理
        if([code isEqualToString:@"success"]) {
            
            //数据从NSDictionary转换为NSString
            NSData *signData = [NSJSONSerialization dataWithJSONObject:data
                                                               options:0
                                                                 error:nil];
            NSString *sign = [[NSString alloc] initWithData:signData encoding:NSUTF8StringEncoding];
            
            //判断签名数据是否存在
            if(data == nil){
                //如果没有签名数据，建议商户app后台查询交易结果
                NSNotification *notification = [NSNotification notificationWithName:ORDER_PAY_NOTIFICATION object:@"fail" userInfo:[NSDictionary dictionaryWithObjectsAndKeys:UnionpayType,@"payType", [NSDictionary dictionaryWithObjectsAndKeys:code,@"code", data,@"data", nil],@"response", nil]];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
                //交易出错
                if (delegate && [delegate respondsToSelector:@selector(paymentDidFailed:responseInfo:payType:)]) {
                    [delegate paymentDidFailed:nil responseInfo:[NSDictionary dictionaryWithObjectsAndKeys:UnionpayType,@"payType", [NSDictionary dictionaryWithObjectsAndKeys:code,@"code", data,@"data", nil],@"response", nil] payType:UnionpayType];
                }
                return;
            }
            
            //验签证书同后台验签证书
            //此处的verify，商户需送去商户后台做验签
            if([GJSPayUnionpay verify:sign]) {
                //支付成功且验签成功，展示支付成功提示
                NSNotification *notification = [NSNotification notificationWithName:ORDER_PAY_NOTIFICATION object:@"success" userInfo:[NSDictionary dictionaryWithObjectsAndKeys:UnionpayType,@"payType", [NSDictionary dictionaryWithObjectsAndKeys:code,@"code", data,@"data", nil],@"response", nil]];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
                //交易成功
                if (delegate && [delegate respondsToSelector:@selector(paymentDidSuccess:responseInfo:payType:)]) {
                    [delegate paymentDidSuccess:nil responseInfo:[NSDictionary dictionaryWithObjectsAndKeys:UnionpayType,@"payType", [NSDictionary dictionaryWithObjectsAndKeys:code,@"code", data,@"data", nil],@"response", nil] payType:UnionpayType];
                }
            }
            else {
                //验签失败，交易结果数据被篡改，商户app后台查询交易结果
                NSNotification *notification = [NSNotification notificationWithName:ORDER_PAY_NOTIFICATION object:@"fail" userInfo:[NSDictionary dictionaryWithObjectsAndKeys:UnionpayType,@"payType", [NSDictionary dictionaryWithObjectsAndKeys:code,@"code", data,@"data", @"验签失败，交易结果数据被篡改，请后台查询交易结果",@"message", nil],@"response", nil]];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
                //交易出错
                if (delegate && [delegate respondsToSelector:@selector(paymentDidFailed:responseInfo:payType:)]) {
                    [delegate paymentDidFailed:nil responseInfo:[NSDictionary dictionaryWithObjectsAndKeys:UnionpayType,@"payType", [NSDictionary dictionaryWithObjectsAndKeys:code,@"code", data,@"data", nil],@"response", nil] payType:UnionpayType];
                }
            }
        }
        else if([code isEqualToString:@"fail"]) {
            //交易失败
            NSNotification *notification = [NSNotification notificationWithName:ORDER_PAY_NOTIFICATION object:@"fail" userInfo:[NSDictionary dictionaryWithObjectsAndKeys:UnionpayType,@"payType", [NSDictionary dictionaryWithObjectsAndKeys:code,@"code", data,@"data", nil],@"response", nil]];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            //交易失败
            if (delegate && [delegate respondsToSelector:@selector(paymentDidFailed:responseInfo:payType:)]) {
                [delegate paymentDidFailed:nil responseInfo:[NSDictionary dictionaryWithObjectsAndKeys:UnionpayType,@"payType", [NSDictionary dictionaryWithObjectsAndKeys:code,@"code", data,@"data", nil],@"response", nil] payType:UnionpayType];
            }
        }
        else if([code isEqualToString:@"cancel"]) {
            //交易取消
            NSNotification *notification = [NSNotification notificationWithName:ORDER_PAY_NOTIFICATION object:@"cancel" userInfo:[NSDictionary dictionaryWithObjectsAndKeys:UnionpayType,@"payType", [NSDictionary dictionaryWithObjectsAndKeys:code,@"code", data,@"data", nil],@"response", nil]];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            //交易取消
            if (delegate && [delegate respondsToSelector:@selector(paymentDidCanceled:responseInfo:payType:)]) {
                [delegate paymentDidCanceled:nil responseInfo:[NSDictionary dictionaryWithObjectsAndKeys:UnionpayType,@"payType", [NSDictionary dictionaryWithObjectsAndKeys:code,@"code", data,@"data", nil],@"response", nil] payType:UnionpayType];
            }
        }
    }];
    
    return YES;
}

#pragma mark - 通知信息
- (void)getOrderPayResult:(NSNotification *)notification {
    
    if ([notification.object isEqualToString:@"success"])
    {
        //[self alert:@"恭喜" msg:@"您已成功支付啦!"];
        if ([self.delegate respondsToSelector:@selector(paymentDidSuccess:responseInfo:payType:)]) {
            [self.delegate paymentDidSuccess:_order responseInfo:notification.userInfo[@"response"] payType:UnionpayType];
        }
    } else if ([notification.object isEqualToString:@"cancel"]) {
        //[self alert:@"提示" msg:@"用户点击取消并返回"];
        if ([self.delegate respondsToSelector:@selector(paymentDidCanceled:responseInfo:payType:)]) {
            [self.delegate paymentDidCanceled:_order responseInfo:notification.userInfo[@"response"] payType:UnionpayType];
        }
    }
    else
    {
        //[self alert:@"提示" msg:@"支付失败"];
        if ([self.delegate respondsToSelector:@selector(paymentDidFailed:responseInfo:payType:)]) {
            [self.delegate paymentDidFailed:_order responseInfo:notification.userInfo[@"response"] payType:UnionpayType];
        }
    }
}

- (void)UnionPay:(NSString *)tn mode:(NSString *)mode viewController:(UIViewController *)viewController {
    //[UPPayPlugin startPay:tn mode:mode viewController:viewController delegate:self];
    //当获得的tn不为空时，调用支付接口
    if (tn != nil && tn.length > 0)
    {
        //[UPPayPlugin startPay:tn mode:mode viewController:viewController delegate:(id<UPPayPluginDelegate>)viewController];
    }
}

- (void)UnionPay:(NSString *)tn mode:(NSString *)mode fromScheme:(NSString *)scheme viewController:(UIViewController *)viewController  {
    //当获得的tn不为空时，调用支付接口
    if (tn != nil && tn.length > 0)
    {
        [[UPPaymentControl defaultControl]
         startPay:tn
         fromScheme:scheme
         mode:mode
         viewController:viewController];
    }
    
    //
    if([[UPPaymentControl defaultControl] isPaymentAppInstalled])
    {
        //当判断用户手机上已安装银联App，商户客户端可以做相应个性化处理
    } else {
        //
    }
}

- (void)UPPayPluginResult:(NSString*)result {
    //
    if ([result isEqualToString:@"success"]) {//订单支付成功
        if ([self.delegate respondsToSelector:@selector(paymentDidSuccess:responseInfo:payType:)]) {
            [self.delegate paymentDidSuccess:_order responseInfo:result payType:UnionpayType];
        }
    } else if ([result isEqualToString:@"fail"]) {//订单支付失败
        if ([self.delegate respondsToSelector:@selector(paymentDidFailed:responseInfo:payType:)]) {
            [self.delegate paymentDidFailed:_order responseInfo:result payType:UnionpayType];
        }
    } else if ([result isEqualToString:@"cancel"]) {//用户取消支付
        if ([self.delegate respondsToSelector:@selector(paymentDidCanceled:responseInfo:payType:)]) {
            [self.delegate paymentDidCanceled:_order responseInfo:result payType:UnionpayType];
        }
    }
}

/**
 选中商品调用支付宝极简支付,自定义Order
 */
- (void)actionPayOrder:(id<OrderItem>)customOrder viewController:(UIViewController *)viewController {
    
    //获取customOrder实例并初始化订单信息
    //如果是空返回
    if (customOrder == nil) {
        return;
    }
    _order = customOrder;
    
    //[self UnionPay:[customOrder tradeNO] mode:UnionPay_Mode viewController:viewController];
    [self UnionPay:[customOrder tradeNO] mode:UnionPay_Mode fromScheme:FromUrlScheme viewController:viewController];
}

- (NSString *) readPublicKey:(NSString *) keyName
{
    if (keyName == nil || [keyName isEqualToString:@""]) return nil;
    
    NSMutableArray *filenameChunks = [[keyName componentsSeparatedByString:@"."] mutableCopy];
    NSString *extension = filenameChunks[[filenameChunks count] - 1];
    [filenameChunks removeLastObject]; // remove the extension
    NSString *filename = [filenameChunks componentsJoinedByString:@"."]; // reconstruct the filename with no extension
    
    NSString *keyPath = [[NSBundle mainBundle] pathForResource:filename ofType:extension];
    
    NSString *keyStr = [NSString stringWithContentsOfFile:keyPath encoding:NSUTF8StringEncoding error:nil];
    
    return keyStr;
}

+ (BOOL) verify:(NSString *) resultStr {
    
    GJSPayUnionpay *payUnionpay = [[GJSPayUnionpay alloc] init];
    
    //从NSString转化为NSDictionary
    NSData *resultData = [resultStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:nil];
    
    //获取生成签名的数据
    NSString *sign = data[@"sign"];
    NSString *signElements = data[@"data"];
    //NSString *pay_result = signElements[@"pay_result"];
    //NSString *tn = signElements[@"tn"];
    //转换服务器签名数据
    NSData *nsdataFromBase64String = [[NSData alloc]
                                      initWithBase64EncodedString:sign options:0];
    //生成本地签名数据，并生成摘要
    //    NSString *mySignBlock = [NSString stringWithFormat:@"pay_result=%@tn=%@",pay_result,tn];
    NSData *dataOriginal = [[payUnionpay sha1:signElements] dataUsingEncoding:NSUTF8StringEncoding];
    //验证签名
    //TODO：此处如果是正式环境需要换成public_product.key
    NSString *pubkey =[payUnionpay readPublicKey:UnionPay_PublicKey];
    OSStatus result=[RSA_ByUnionPay verifyData:dataOriginal sig:nsdataFromBase64String publicKey:pubkey];
    
    
    
    //签名验证成功，商户app做后续处理
    if(result == 0) {
        //支付成功且验签成功，展示支付成功提示
        return YES;
    }
    else {
        //验签失败，交易结果数据被篡改，商户app后台查询交易结果
        return NO;
    }
    
    return NO;
}


- (NSString*)sha1:(NSString *)string
{
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1_CTX context;
    NSString *description;
    
    CC_SHA1_Init(&context);
    
    memset(digest, 0, sizeof(digest));
    
    description = @"";
    
    
    if (string == nil)
    {
        return nil;
    }
    
    // Convert the given 'NSString *' to 'const char *'.
    const char *str = [string cStringUsingEncoding:NSUTF8StringEncoding];
    
    // Check if the conversion has succeeded.
    if (str == NULL)
    {
        return nil;
    }
    
    // Get the length of the C-string.
    int len = (int)strlen(str);
    
    if (len == 0)
    {
        return nil;
    }
    
    
    if (str == NULL)
    {
        return nil;
    }
    
    CC_SHA1_Update(&context, str, len);
    
    CC_SHA1_Final(digest, &context);
    
    description = [NSString stringWithFormat:
                   @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   digest[ 0], digest[ 1], digest[ 2], digest[ 3],
                   digest[ 4], digest[ 5], digest[ 6], digest[ 7],
                   digest[ 8], digest[ 9], digest[10], digest[11],
                   digest[12], digest[13], digest[14], digest[15],
                   digest[16], digest[17], digest[18], digest[19]];
    
    return description;
}

@end
