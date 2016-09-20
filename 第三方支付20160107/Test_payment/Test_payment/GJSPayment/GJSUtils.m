//
//  GJSUtils.m
//  Test_payment
//
//  Created by forp on 15/11/30.
//  Copyright © 2015年 forp. All rights reserved.
//

#import "GJSUtils.h"
#import <objc/runtime.h>
#import <MobileCoreServices/MobileCoreServices.h>

static actionBlock alertViewblock;
@interface GJSUtils () <UIAlertViewDelegate>
@end

@implementation GJSUtils


#pragma mark utils
+ (void)getClassMethods:(id)aClass {
    if (aClass == nil) {
        return;
    }
    NSString *className = NSStringFromClass(aClass);
    
    const char *cClassName = [className UTF8String];
    
    id theClass = objc_getClass(cClassName);
    
    unsigned int outCount = 0;
    
    
    Method *m =  class_copyMethodList(theClass,&outCount);
    
    NSLog(@"%@ methods count:%d",className,outCount);
    for (int i = 0; i<outCount; i++) {
        SEL a = method_getName(*(m+i));
        NSString *sn = NSStringFromSelector(a);
        NSLog(@"method-->%@\n",sn);
    }
}

+ (UIAlertView *)showMessage:(NSString*)msg WithTitle:(NSString *)title cancelTitle:(NSString *)cancelTitle otherTitles:(nullable NSString *)otherButtonTitles, ... {
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:title message:msg delegate:NULL cancelButtonTitle:nil otherButtonTitles:nil];
    // 获取可变参数的值
    if (![self isEmptyString:cancelTitle]) {
        [av addButtonWithTitle:cancelTitle];
    }
    NSString *str;
    va_list list;
    if(otherButtonTitles)
    {
        // 1.取得第一个参数的值
        [av addButtonWithTitle:otherButtonTitles];
        // 2.从第2个参数开始，依次取得所有参数的值
        va_start(list, otherButtonTitles);
        while ((str = va_arg(list, NSString *))){
            [av addButtonWithTitle:str];
        }
        va_end(list);
    }
    
    [av show];
    return av;
}
+ (UIAlertView *)showMessage:(NSString*)msg WithTitle:(NSString *)title cancelTitle:(NSString *)cancelButtonTitle otherButtonTitles:(nullable NSArray *)otherButtonTitles {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:NULL cancelButtonTitle:nil otherButtonTitles:nil];
    for( NSString *title in otherButtonTitles)  {
        [alert addButtonWithTitle:title];
    }
    
    [alert addButtonWithTitle:cancelButtonTitle];
    alert.cancelButtonIndex = [otherButtonTitles count];
    return alert;
}

+ (void)alertInViewController:(UIViewController *)viewController alertTitle:(NSString *)title message:(NSString *)msg actionTitle:(NSString *)actionTitle actionHandler:(void (^ __nullable)(UIAlertAction *action))actionHandler cancelActionTitle:(NSString *)cancelTitle {
    //iOS8下使用UIAlertController
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if([[UIDevice currentDevice].systemVersion floatValue] >= 8.0){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDefault handler:actionHandler];
        [alertController addAction:alertAction];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertController addAction:cancelAction];
        [viewController presentViewController:alertController animated:YES completion:nil];
    } else {
#endif
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:viewController cancelButtonTitle:cancelTitle otherButtonTitles:actionTitle, nil];
        [alertView show];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    }
#endif
}

+ (void)alertInViewController:(UIViewController *)viewController alertTitle:(NSString *)title message:(NSString *)msg actionTitle:(NSString *)actionTitle actionHandler:(void (^ __nullable)(UIAlertAction *action))actionHandler otherActionTitle:(NSString *)cancelTitle otherActionHandler:(void (^ __nullable)(UIAlertAction *action))otherActionHandler {
    //iOS8下使用UIAlertController
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if([[UIDevice currentDevice].systemVersion floatValue] >= 8.0){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDefault handler:actionHandler];
        [alertController addAction:alertAction];
        UIAlertAction *otherAlertAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleDefault handler:otherActionHandler];
        [alertController addAction:otherAlertAction];
        [viewController presentViewController:alertController animated:YES completion:nil];
    } else {
#endif
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:viewController cancelButtonTitle:nil otherButtonTitles:actionTitle, cancelTitle,  nil];
        [alertView show];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    }
#endif
}

+ (void)showMessage:(NSString*)msg {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:NULL cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [av show];
}

+ (NSString *)getValidStringWithObject:(id)obj {
    /**
     *  nil->(null)
     *  NSNull-><null>
     */
    if ([obj isKindOfClass:[NSString class]]) {
        NSString *strValue = obj;
        if (strValue && ![strValue isEqualToString:@"<null>"] && ![strValue isEqualToString:@"(null)"] && ![strValue isEqualToString:@""]) {
            return strValue;
        } else {
            return @"";
        }
    } else if ([obj isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"%@", obj];
    } else {
        return @"";
    }
}

+ (BOOL)isEmptyString:(NSString *)string {
    return [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0?YES:NO;
    //return [string isEqualToString:@""];
}

+ (NSString *)jsonStringWithNSDictionary:(NSDictionary *)dict{
    NSData *dataJson = [GJSUtils jsonDataWithNSDictionary:dict];
    NSString *strJson = [[NSString alloc] initWithData:dataJson encoding:NSUTF8StringEncoding];
    return strJson;
}
+ (NSData *)jsonDataWithNSDictionary:(NSDictionary *)dict{
    NSError *error = nil;
    NSData *dataJson = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    if(error) {
        NSAssert(0>1, @"解析JSONObject出错");
        return nil;
    } else {
        //QLLog(@"Serialization body: %@",dict);
        return dataJson;
    }
}

@end
