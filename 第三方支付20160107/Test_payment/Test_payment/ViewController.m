//
//  ViewController.m
//  Test_payment
//
//  Created by forp on 15/11/27.
//  Copyright © 2015年 forp. All rights reserved.
//

#import "ViewController.h"
#import "GJSUtils.h"
#import "APViewController.h"
#import "GJSPay.h"
#import "ProductForAlipay.h"
#import "ProductForWXpay.h"
#import "OrderForUnionPay.h"

@interface ViewController () <UIAlertViewDelegate, GJSPayProtocol, UPPayPluginDelegate> {
    //
    GJSPay *pay;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //[self testURLScheme:@"alipay://test"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)testAlipay:(id)sender {
    PaySDK = AlipayType;
    //GJSPay *pay = [[GJSPay alloc] init];
    pay = [[GJSPay alloc] init];
    pay.delegate = self;
    ProductForAlipay *product = [[ProductForAlipay alloc] initWithDictionary:@{@"Price": @"0.01", @"Subject": @"测试商品名称", @"Body": @"测试商品描述", @"OrderId": @"201512020126", @"NotifyURL": @"www.xxx.com"}];
    [pay payByAlipayProduct:(id)product partner:Alipay_PartnerID seller:Alipay_SellerID partnerPrivKey:Alipay_PartnerPrivKey appURLScheme:@"paymentDemo" md5_key:nil];
}
- (IBAction)testWXpay:(id)sender {
    PaySDK = WXpayType;
    //GJSPay *pay = [[GJSPay alloc] init];
    pay = [[GJSPay alloc] init];
    pay.delegate = self;
    ProductForWXpay *product = [[ProductForWXpay alloc] initWithDictionary:@{@"Price": @"0.01", @"Subject": @"测试商品名称", @"Body": @"测试商品描述", @"OrderId": @"201512020126", @"NotifyURL": @"www.xxx.com"}];
    [pay payByWXpayProduct:(id)product appId:WXpay_APP_ID partner:WXpay_PARTNER_ID mchId:WXpay_MCH_ID];
}
- (IBAction)testUnionPay:(id)sender {
    PaySDK = UnionpayType;
    //GJSPay *pay = [[GJSPay alloc] init];
    pay = [[GJSPay alloc] init];
    pay.delegate = self;
    OrderForUnionPay *order = [[OrderForUnionPay alloc] initWithDictionary:@{@"TradeNO": @"201512020126", @"ProductName": @"测试商品名称", @"ProductDescription": @"测试商品描述", @"Amount": @"0.01", @"NotifyURL": @"www.xxx.com"}];
    [pay payByUnionPayOrder:(id)order viewController:self];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSLog(@"hello!");
    }
}

- (IBAction)testAlipaySDK:(id)sender {
    APViewController *apVC = [[APViewController alloc] initWithNibName:@"APViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:apVC animated:YES];
}

#pragma mark --
#pragma mark GJSPayProtocol
/**
 *  支付成功代理
 */
- (void)paymentDidSuccess:(id)payment responseInfo:(id)response payType:(NSString *)type {
    if ([type isEqualToString:AlipayType]) {//支付宝支付
        if ([response isKindOfClass:[NSDictionary class]]) {
            response = (NSDictionary *)response;
        } else {
            return;
        }
        /**
         *  推荐使用服务器验证而非本地验证,从服务器请求支付结果比较妥!
         NSString *memo = response[@"memo"];
         NSString *result = response[@"result"];
         GJSPay *aliPay = [[GJSPay alloc] init];
         aliPay.alipayPubKey = @"partner=\"2088101568358171\"&seller_id=\"xxx@alipay.com\"&out_trade_no=\"0819145412-6177\"&subject=\"测试\"&body=\"测试测试\"&total_fee=\"0.01\"&notify_url=\"http://notify.msp.hk/notify.htm\"&service=\"mobile.securitypay.pay\"&payment_type=\"1\"&_input_charset=\"utf-8\"&it_b_pay=\"30m\"&success=\"true\"&sign_type=\"RSA\"&sign=\"hkFZr+zE9499nuqDNLZEF7W75RFFPsly876QuRSeN8WMaUgcdR00IKy5ZyBJ4eldhoJ/2zghqrD4E2G2mNjs3aE+HCLiBXrPDNdLKCZgSOIqmv46TfPTEqopYfhs+o5fZzXxt34fwdrzN4mX6S13cr3UwmEV4L3Ffir/02RBVtU=\"";
         if ([aliPay verify:result]) {
         //验证通过
         NSLog(@"验证通过");
         } else {
         //验证不通过
         NSLog(@"验证不通过");
         }
         }
         */
    } else if ([type isEqualToString:WXpayType]) {//微信支付
        //
    } else if ([type isEqualToString:UnionpayType]) {//银联支付
        //
    }
}
/**
 *  支付失败代理
 */
- (void)paymentDidFailed:(id)payment responseInfo:(id)response payType:(NSString *)type {
    if ([type isEqualToString:AlipayType]) {//支付宝支付
        //
    } else if ([type isEqualToString:WXpayType]) {//微信支付
        //
    } else if ([type isEqualToString:UnionpayType]) {//银联支付
        //
    }
}
/**
 *  支付取消代理
 */
- (void)paymentDidCanceled:(id)payment responseInfo:(id)response payType:(NSString *)type {
    if ([type isEqualToString:AlipayType]) {//支付宝支付
        //
    } else if ([type isEqualToString:WXpayType]) {//微信支付
        //
    } else if ([type isEqualToString:UnionpayType]) {//银联支付
        //
    }
}
/**
 *  支付状态代理
 */
- (void)paymentStatus:(id)payment statusInfo:(id)info payType:(NSString *)type {
    if ([type isEqualToString:AlipayType]) {//支付宝支付
        //
    } else if ([type isEqualToString:WXpayType]) {//微信支付
        //
    } else if ([type isEqualToString:UnionpayType]) {//银联支付
        //
    }
}

#pragma mark -- 银联支付回调代理
#pragma mark UPPayPluginDelegate
- (void)UPPayPluginResult:(NSString*)result {
    //
    if ([result isEqualToString:@"success"]) {//订单支付成功
        
        
    } else if ([result isEqualToString:@"fail"]) {//订单支付失败
        
        
    } else if ([result isEqualToString:@"cancel"]) {//用户取消支付
        
        
    }
}

#pragma mark custom
#pragma mark utils
- (void)testURLScheme:(NSString *)customURL {
    NSString *urlScheme = [customURL copy];
    NSRange range = [urlScheme rangeOfString:@"://"];
    if (range.location != NSNotFound) {
        urlScheme = [urlScheme substringToIndex:range.location];
    }
    Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
    NSObject *workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
    NSLog(@"openURL: %@",[workspace performSelector:@selector(applicationsAvailableForHandlingURLScheme:)withObject:urlScheme]);
    NSArray *arrOpenURLs = [workspace performSelector:@selector(applicationsAvailableForHandlingURLScheme:)withObject:urlScheme];
    if ([arrOpenURLs isKindOfClass:[NSArray class]]) {
        if (arrOpenURLs.count>0) {
            [GJSUtils getClassMethods:[[arrOpenURLs lastObject] class]];
        }
        for (id object in arrOpenURLs) {
            NSLog(@"object class: %@",[object class]);
            NSLog(@"%@",[object description]);
            NSLog(@"%@",[object performSelector:@selector(applicationIdentifier)]);
            NSString *applicationIdentifier = [object performSelector:@selector(applicationIdentifier)];
            if ([applicationIdentifier isKindOfClass:[NSString class]] && [applicationIdentifier isEqualToString:@"orp.westerasoft.com.TestURLScheme3"]) {
                break;
            }
        }
    }
    
    if ([arrOpenURLs isKindOfClass:[NSArray class]] && arrOpenURLs.count>0)
    {
        //[GJSUtils showMessage:[NSString stringWithFormat:@"将要打开的应用不确定！因为该设备上有多个注册了相同链接的app，请确保链接安全，或卸载非目标的app"] WithTitle:@"警告！" cancelTitle:@"取消" otherTitles:@"继续访问", nil];
        UIAlertView *alert = [GJSUtils showMessage:[NSString stringWithFormat:@"将要打开的应用不确定！因为该设备上有多个注册了相同链接的app，请确保链接安全，或卸载非目标的app"] WithTitle:@"警告！" cancelTitle:@"取消" otherTitles:@"继续访问", nil];
        alert.delegate = self;
        return;
    }
    [self openURLScheme:customURL];
}

- (void)openURLScheme:(NSString *)customURL
{
    if ([[UIApplication sharedApplication]
         canOpenURL:[NSURL URLWithString:customURL]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:customURL]];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"URL error" message:[NSString stringWithFormat:@"No custom URL defined for %@", customURL] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}
@end
