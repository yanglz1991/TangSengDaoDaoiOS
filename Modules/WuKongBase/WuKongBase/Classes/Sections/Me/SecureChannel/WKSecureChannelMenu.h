//
//  WKSecureChannelMenu.h
//  WuKongBase
//
//  注册到通用设置 endpoint 的加密通道入口。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKSecureChannelMenu : NSObject

/// 注册到 WKPOINT_CATEGORY_COMMONSETTING(只需调用一次)
+ (void)registerSecureChannelMenu;

@end

NS_ASSUME_NONNULL_END
