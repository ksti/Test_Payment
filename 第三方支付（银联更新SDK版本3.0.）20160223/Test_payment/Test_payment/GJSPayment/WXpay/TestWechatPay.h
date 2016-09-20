//
//  TestWechatPay.h
//  Test_payment
//
//  Created by forp on 15/12/3.
//  Copyright © 2015年 forp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestWechatPay : NSObject

//商户关键信息
/**
 *  公众账号ID
 */
@property (nonatomic, copy) NSString *appId;
/**
 *  商户API密钥，填写相应参数
 */
@property (nonatomic, copy) NSString *partnerId;
/**
 *  商户号，填写商户对应参数
 */
@property (nonatomic,strong) NSString *mchId;
/**
 *  预支付网关url地址
 */
@property (nonatomic,strong) NSString* payUrl;
/**
 *  商户的密钥
 */
@property (nonatomic,strong) NSString *spKey;

//debug信息
@property (nonatomic,strong) NSMutableString *debugInfo;
@property (nonatomic,assign) NSInteger lastErrCode;//返回的错误码

//初始化函数
-(id)initWithAppID:(NSString*)appID
             mchID:(NSString*)mchID
             spKey:(NSString*)key;

//获取当前的debug信息
-(NSString *) getDebugInfo;

//获取预支付订单信息（核心是一个prepayID）
- (NSMutableDictionary*)getPrepayWithOrderName:(NSString*)name
                                         price:(NSString*)price
                                        device:(NSString*)device;

@end
