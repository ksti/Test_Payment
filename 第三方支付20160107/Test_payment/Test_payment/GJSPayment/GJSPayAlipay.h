//
//  GJSPayAlipay.h
//  Test_payment
//
//  Created by forp on 15/11/27.
//  Copyright © 2015年 forp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GJSPayProtocol.h"

@interface GJSPayAlipay : NSObject

@property (nonatomic, weak) id<GJSPayProtocol> delegate;
/**
 *  商户的唯一的parnter和seller
 */

/** 合作身份者id，以2088开头的16位纯数字 */
@property (nonatomic, copy) NSString *partner;
/** 收款支付宝账号 */
@property (nonatomic, copy) NSString *seller;
/** 商户私钥，自助生成 */
@property (nonatomic, copy) NSString *partnerPrivKey;
/** 支付宝公钥 */
@property (nonatomic, copy) NSString *alipayPubKey;
/** 安全校验码（MD5）密钥，以数字和字母组成的32位字符 */
@property (nonatomic, copy) NSString *md5_key;//iOS似乎不用此参数
/** 回调URL */
@property (nonatomic, copy) NSString *notifyURL;
/** 应用注册scheme(即本app的注册URLScheme) */
@property (nonatomic, copy) NSString *appURLScheme;

/**
 选中商品调用支付宝极简支付,自定义Product
 */
- (void)actionPayProduct:(id<ProductItem>)product;//自助签名

/*============================================================================*/
/*====================订单由服务器端生成并进行加密签名，推荐方式=====================*/
/*============================================================================*/

/**
 选中商品调用支付宝极简支付,自定义Order
 */
- (void)actionPayOrder:(id<OrderItem>)customOrder;//需要由服务器端生成的加密签名signedString

@end
