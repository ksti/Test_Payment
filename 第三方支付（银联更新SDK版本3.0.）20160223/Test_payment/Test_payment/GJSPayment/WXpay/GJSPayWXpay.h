//
//  GJSWXpay.h
//  Test_payment
//
//  Created by forp on 15/11/27.
//  Copyright © 2015年 forp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GJSPayProtocol.h"
#import "WechatPayManager.h"

@interface GJSPayWXpay : NSObject

@property (nonatomic, weak) id<GJSPayProtocol> delegate;

/*! @brief 处理微信支付通过URL启动App时传递的数据
 *
 * 需要在 application:openURL:sourceApplication:annotation:或者application:handleOpenURL中调用。
 * @param url 微信支付启动第三方应用(即本应用)时传递过来的URL
 * @param delegate  GJSPayProtocol对象，用来接收微信支付触发的消息。
 * @return 成功返回YES，失败返回NO。
 */
+(BOOL) handleOpenURL:(NSURL *) url delegate:(id<GJSPayProtocol>) delegate;

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
 *  回调url地址
 */
@property (nonatomic,strong) NSString* notifyURL;
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

/**
 选中商品调用微信支付,自定义Product,与自定义Order二选一,否则代理无法确定该值(微信支付SDK不提供回调block)
 */
- (void)actionPayProduct:(id<ProductItem>)product;//自助签名
/**
 选中商品调用微信支付,由服务器端生成预支付订单
 */
-(void)weiXinPayAction:(NSString*)partner_idStr prepay_id:(NSString*)prepay_idStr;//自助签名
/**
 *  选中商品调用微信支付,由服务器端生成预支付订单 自助签名
 */
-(void)weiXinPayAction:(NSString*)partner_idStr prepay_id:(NSString*)prepay_idStr nonceStr:(NSString *)nonceStr selfSign:(NSString *)signedString;

/*============================================================================*/
/*====================订单由服务器端生成并进行加密签名，推荐方式=====================*/
/*============================================================================*/

/**
 选中商品调用微信支付,自定义Order,与自定义Product二选一,否则代理无法确定该值(微信支付SDK不提供回调block)
 */
- (void)actionPayOrder:(id<OrderItem>)customOrder;//需要由服务器端生成的加密签名signedString
/**
 选中商品调用微信支付,由服务器端生成预支付订单、加密签名
 */
- (void)weiXinPayAction:(NSString*)partner_idStr prepay_id:(NSString*)prepay_idStr nonceStr:(NSString *)nonceStr sign:(NSString *)signedString;//需要由服务器端生成的加密签名signedString

@end
