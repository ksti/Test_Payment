//
//  UnionPayPartnerConfig.h
//  Test_payment
//
//  Created by forp on 15/12/4.
//  Copyright © 2015年 forp. All rights reserved.
//

#ifndef UnionPayPartnerConfig_h
#define UnionPayPartnerConfig_h

// 商户相关参数
/**
 *  接入模式设定，两个值：
     @"00":代表接入生产环境（正式版本需要）；
     @"01"：代表接入开发测试环境（测试版本需要）；
 */
#ifdef DEBUG
#define UnionPay_Mode @"01"//开发测试环境（测试版本需要）
#else
#define UnionPay_Mode @"00"//生产环境（正式版本需要）
#endif


#endif /* UnionPayPartnerConfig_h */
