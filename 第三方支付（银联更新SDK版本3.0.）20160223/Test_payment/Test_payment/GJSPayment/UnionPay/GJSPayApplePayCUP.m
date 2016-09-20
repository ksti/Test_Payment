//
//  GJSPayApplePayCUP.m
//  Test_payment
//
//  Created by forp on 16/2/18.
//  Copyright © 2016年 forp. All rights reserved.
//

#import "GJSPayApplePayCUP.h"
#import "ApplePayCUPPartnerConfig.h"

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <PassKit/PassKit.h>


//#define KBtn_width        200
//#define KBtn_height       80
//#define KXOffSet          (self.view.frame.size.width - KBtn_width) / 2
//#define KYOffSet          80
//#define kCellHeight_Normal  50
//#define kCellHeight_Manual  145

#define kVCTitle          @"商户测试"
#define kBtnFirstTitle    @"获取订单，开始测试"
#define kWaiting          @"正在获取TN,请稍后..."
#define kNote             @"提示"
#define kConfirm          @"确定"
#define kErrorNet         @"网络错误"
#define kResult           @"支付结果：%@"

#define KBtn_width       80
#define KBtn_height      40
#define KXOffSet         (self.view.frame.size.width - KBtn_width) / 2
#define KYOffSet         120
#define kWithNavigation  44

@interface GJSPayApplePayCUP () <UPAPayPluginDelegate, UIAlertViewDelegate>
{
    id<OrderItem>_order;
    
    UIAlertView* _alertView;
    NSMutableData* _responseData;
    CGFloat _maxWidth;
    CGFloat _maxHeight;
    
    UITextField *_urlField;
    UITextField *_modeField;
    UITextField *_curField;
}

- (void)showAlertWait;
- (void)showAlertMessage:(NSString*)msg;
- (void)hideAlert;

@end

@implementation GJSPayApplePayCUP

/**
 选中商品调用银联支持的 Apple Pay 支付,自定义Order
 */
- (void)actionPayOrder:(id<OrderItem>)customOrder viewController:(UIViewController *)viewController {
    
    //获取customOrder实例并初始化订单信息
    //如果是空返回
    if (customOrder == nil) {
        return;
    }
    _order = customOrder;
    
    [self ApplePayCUP:[customOrder tradeNO] mode:ApplePayCUP_Mode viewController:viewController];
}

- (void)ApplePayCUP:(NSString *)tn mode:(NSString *)mode viewController:(UIViewController *)viewController
{
    
    /*
    //正式环境
    self.tnMode = @"00";
    //固定1分订单
    //NSURL* url = [NSURL URLWithString:@"http://101.231.114.216:1725/sim/getacptn"];
    NSURL* url = [NSURL URLWithString:@"http://101.231.114.216:1725/sim/app.jsp?user=admin"];
    
    
    NSMutableURLRequest * urlRequest=[NSMutableURLRequest requestWithURL:url];
    NSURLConnection* urlConn = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    [urlConn start];
    [self showAlertWait];
    
    
    
    //    //直接写死tn(商户可以自己写死订单）
    //    self.tnMode = @"00";
    //    [UPAPayPlugin startPay:@"201511181055564938258" mode:self.tnMode viewController:self delegate:self andAPMechantID:kAppleMechantID];
    */
    
    //当获得的tn不为空时,调用支付接口
    if (tn != nil && tn.length > 0) {
        if (![PKPaymentAuthorizationViewController canMakePayments]) {
            [self showAlertMessage:@"该设备不支持或未开启 Apple Pay !"];
            return;
        }
        if([PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:@[PKPaymentNetworkChinaUnionPay]] )
        {
            //调用银联支付控件
            //[UPAPayPlugin startPay:tn mode:mode viewController:viewController delegate:self andAPMechantID:kAppleMechantID];
            [UPAPayPlugin startPay:tn mode:mode viewController:viewController delegate:(id<UPAPayPluginDelegate>)viewController andAPMechantID:kAppleMechantID];
        } else {
            [self showAlertMessage:@"该设备 Apple Pay 当前不支持通过中国银联!"];
        }
    }
}

- (void)UPAPayPluginResult:(UPPayResult *)payResult {
    if(payResult.paymentResultStatus == UPPaymentResultStatusSuccess) {
        NSString *otherInfo = payResult.otherInfo?payResult.otherInfo:@"";
        NSString *successInfo = [NSString stringWithFormat:@"支付成功\n%@",otherInfo];
        //[self showAlertMessage:successInfo];
        if ([self.delegate respondsToSelector:@selector(paymentDidSuccess:responseInfo:payType:)]) {
            [self.delegate paymentDidSuccess:_order responseInfo:payResult payType:ApplePayCUPType];
        }
    }
    else if (payResult.paymentResultStatus == UPPaymentResultStatusFailure) {
        NSString *errorInfo = [NSString stringWithFormat:@"%@",payResult.errorDescription];
        //[self showAlertMessage:errorInfo];
        if ([self.delegate respondsToSelector:@selector(paymentDidFailed:responseInfo:payType:)]) {
            [self.delegate paymentDidFailed:_order responseInfo:payResult payType:ApplePayCUPType];
        }
    }
    else if(payResult.paymentResultStatus == UPPaymentResultStatusCancel){
        //[self showAlertMessage:@"支付取消"];
        if ([self.delegate respondsToSelector:@selector(paymentDidCanceled:responseInfo:payType:)]) {
            [self.delegate paymentDidCanceled:_order responseInfo:payResult payType:ApplePayCUPType];
        }
    }
    else if (payResult.paymentResultStatus == UPPaymentResultStatusUnknownCancel) {
        //TODO UPPAymentResultStatusUnknownCancel表示发起支付以后用户取消,导致支付状态不确认,需 要查询商户后台确认真实的支付结果
        NSString *errorInfo = [NSString stringWithFormat:@"支付过程中用户取消了,请查询后台确认订单"];
        //[self showAlertMessage:errorInfo];
        if ([self.delegate respondsToSelector:@selector(paymentDidCanceled:responseInfo:payType:)]) {
            [self.delegate paymentDidCanceled:_order responseInfo:payResult payType:ApplePayCUPType];
        }
    }
    
}

#pragma mark - Alert

- (void)showAlertWait
{
    [self hideAlert];
    _alertView = [[UIAlertView alloc] initWithTitle:kWaiting message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    [_alertView show];
    UIActivityIndicatorView* aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    aiv.center = CGPointMake(_alertView.frame.size.width / 2.0f - 15, _alertView.frame.size.height / 2.0f + 10 );
    [aiv startAnimating];
    [_alertView addSubview:aiv];
    //[aiv release];
    //[_alertView release];
}

- (void)showAlertMessage:(NSString*)msg
{
    [self hideAlert];
    _alertView = [[UIAlertView alloc] initWithTitle:kNote message:msg delegate:self cancelButtonTitle:kConfirm otherButtonTitles:nil, nil];
    [_alertView show];
    //[_alertView release];
}
- (void)hideAlert
{
    if (_alertView != nil)
    {
        [_alertView dismissWithClickedButtonIndex:0 animated:NO];
        _alertView = nil;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    _alertView = nil;
}

@end
