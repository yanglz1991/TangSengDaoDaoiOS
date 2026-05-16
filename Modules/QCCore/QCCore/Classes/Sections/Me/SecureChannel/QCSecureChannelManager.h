//
//  QCSecureChannelManager.h
//  QCCore
//
//  加密通道管理:封装拉取配置、密码验证与本地免密缓存。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCSecureChannelManager : NSObject

+ (instancetype)shared;

/// 缓存:是否启用
@property(nonatomic, assign, readonly) BOOL enabled;
/// 缓存:按钮名称
@property(nonatomic, copy, readonly) NSString *displayName;

/// 拉取配置(更新 enabled 与 displayName);complete 在主线程回调
- (void)refreshConfig:(void (^_Nullable)(BOOL enabled, NSString *name))complete;

/// 用密码验证,通过则下发 url
- (void)verifyWithPassword:(NSString *)password
                  complete:(void (^)(NSString *_Nullable url, NSError *_Nullable error))complete;

/// 本地保存的密码(免密自动验证用)
- (nullable NSString *)savedPassword;
- (void)setSavedPassword:(nullable NSString *)password;
- (void)clearSavedPassword;

@end

NS_ASSUME_NONNULL_END
