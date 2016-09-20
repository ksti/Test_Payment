//
//  WXpayPartnerConfig.h
//  Test_payment
//
//  Created by forp on 15/12/3.
//  Copyright © 2015年 forp. All rights reserved.
//

#ifndef WXpayPartnerConfig_h
#define WXpayPartnerConfig_h

// 账号帐户资料
// 更改商户把相关参数后可测试
#define WXpay_APP_ID          @"wxd930ea5d5a258f4f"        //这里填写你获取的微信AppID
#define WXpay_APP_SECRET      @""                          //这里填写你获取的微信AppSecret,看起来好像没用
//商户号，填写商户对应参数
#define WXpay_MCH_ID          @"10000098"
//商户API密钥，填写相应参数
#define WXpay_PARTNER_ID      @"12345678901234567890123456789012"
//预支付网关url地址
#define WXpay_PREPAY_URL      @"https://api.mch.weixin.qq.com/pay/unifiedorder"
//支付结果回调页面 //这里填写后台给你的微信支付的后台接口网址
#define WXpay_NOTIFY_URL      @"http://wxpay.weixin.qq.com/pub_v2/pay/notify.v2.php"
//获取服务器端支付数据地址（商户自定义）(如果签名算法直接放在APP端(不建议)，则不需要自定义)
#define WXpay_SP_URL          @"http://wxpay.weixin.qq.com/pub_v2/app/app_pay.php"


#endif /* WXpayPartnerConfig_h */
