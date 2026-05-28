//
//  QXBootstrapper.h
//  QCCore
//
//  喜聊品牌运行时启动器。在 AppDelegate didFinishLaunching
//  阶段一次性初始化所有 QX 品牌模块（身份、主题、遥测、
//  指纹、网络探测、阅读偏好等），保证模块状态一致。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QXBootstrapper : NSObject

+ (instancetype)sharedBootstrapper;

@property (nonatomic, assign, readonly) BOOL didBootstrap;

/// 在 AppDelegate didFinishLaunching 中调用一次。
- (void)bootstrap;

/// 应用进入前台时调用。
- (void)applicationDidBecomeActive;

/// 应用进入后台时调用。
- (void)applicationDidEnterBackground;

@end

NS_ASSUME_NONNULL_END
