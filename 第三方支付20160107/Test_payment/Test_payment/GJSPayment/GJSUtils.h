//
//  GJSUtils.h
//  Test_payment
//
//  Created by forp on 15/11/30.
//  Copyright © 2015年 forp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^actionBlock)();

@interface GJSUtils : NSObject
/**
 *  获取某个类的所有方法
 */
+ (void)getClassMethods:(nonnull id)aClass;
/**
 *  格式化字符串
 */
+ (nullable NSString *)getValidStringWithObject:(nonnull id)obj;
/**
 *  判断字符串是否为空
 */
+ (BOOL)isEmptyString:(nullable NSString *)string;
/**
 *  解析json字典成NSString
 */
+ (nullable NSString *)jsonStringWithNSDictionary:(nonnull NSDictionary *)dict;
/**
 *  解析json字典成NSdata
 */
+ (nullable NSData *)jsonDataWithNSDictionary:(nonnull NSDictionary *)dict;
/**
 *  弹出UIalertView
 */
+ (void)showMessage:(nullable NSString *)msg;
/**
 *  弹出UIalertView1
 */
+ (nullable UIAlertView *)showMessage:(nullable NSString *)msg WithTitle:(nullable NSString *)title cancelTitle:(nullable NSString *)cancelTitle otherTitles:(nullable NSString *)otherButtonTitles, ... ;
/**
 *  弹出UIalertView2
 */
+ (nullable UIAlertView *)showMessage:(nonnull NSString *)msg WithTitle:(nullable NSString *)title cancelTitle:(nullable NSString *)cancelButtonTitle otherButtonTitles:(nullable NSArray *)otherButtonTitles;
/**
 *  弹出UIalertView3，使用IOS8新特性，兼容IOS7
 */
+ (void)alertInViewController:(UIViewController * _Nonnull)viewController alertTitle:(NSString * _Nullable)title message:(NSString * _Nullable)msg actionTitle:(NSString * _Nullable)actionTitle actionHandler:(void (^ __nullable)(UIAlertAction * _Nullable action))actionHandler cancelActionTitle:(NSString * _Nullable)cancelTitle;
/**
 *  弹出UIalertView4，使用IOS8新特性，兼容IOS7
 */
+ (void)alertInViewController:(UIViewController * _Nonnull)viewController alertTitle:(NSString * _Nullable)title message:(NSString * _Nullable)msg actionTitle:(NSString * _Nullable)actionTitle actionHandler:(void (^ __nullable)(UIAlertAction * _Nullable action))actionHandler otherActionTitle:(NSString * _Nullable)cancelTitle otherActionHandler:(void (^ __nullable)(UIAlertAction * _Nullable action))otherActionHandler;
@end
