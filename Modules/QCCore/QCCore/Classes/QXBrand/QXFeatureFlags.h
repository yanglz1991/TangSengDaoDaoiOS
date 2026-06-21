//
//  QXFeatureFlags.h
//  QCCore
//
//  禧语功能开关。集中管理实验性功能、灰度功能、风险功能。
//  支持本地默认值 + 远端配置覆盖（远端配置由调用方注入）。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const QXFeatureFlagsDidChangeNotification;

extern NSString * const QXFeatureFlagBlurAvatarOnLock;
extern NSString * const QXFeatureFlagSmartReply;
extern NSString * const QXFeatureFlagRichLinkPreview;
extern NSString * const QXFeatureFlagOfflineDraft;
extern NSString * const QXFeatureFlagAutoCleanCache;
extern NSString * const QXFeatureFlagPrivacyDigest;
extern NSString * const QXFeatureFlagWeeklyHighlight;
extern NSString * const QXFeatureFlagMessageReactions;

@interface QXFeatureFlags : NSObject

+ (instancetype)sharedFlags;

- (void)setDefaultValue:(BOOL)value forFlag:(NSString *)flag;
- (BOOL)isFlagOn:(NSString *)flag;
- (void)setRemoteOverrides:(nullable NSDictionary<NSString *, NSNumber *> *)overrides;
- (void)setUserOverride:(BOOL)value forFlag:(NSString *)flag;
- (void)clearUserOverrides;

- (NSDictionary<NSString *, NSNumber *> *)snapshot;

@end

NS_ASSUME_NONNULL_END
