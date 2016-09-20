//
//  ApplePayCUPPartnerConfig.h
//  Test_payment
//
//  Created by forp on 16/2/18.
//  Copyright © 2016年 forp. All rights reserved.
//

#ifndef ApplePayCUPPartnerConfig_h
#define ApplePayCUPPartnerConfig_h

// 商户相关参数
/**
 *  接入模式设定，两个值：
 @"00":代表接入生产环境（正式版本需要）；
 @"01"：代表接入开发测试环境（测试版本需要）；
 */
#ifdef DEBUG
#define ApplePayCUP_Mode @"01"//开发测试环境（测试版本需要）
#else
#define ApplePayCUP_Mode @"00"//生产环境（正式版本需要）
#endif

//#define kAppleMechantID        @"merchant.com.am.gu"
//#define kAppleMechantID        @"merchant.com.ctrip.test"
#define kAppleMechantID        @"merchant.com.example.Test-payment"

#endif /* ApplePayCUPPartnerConfig_h */
