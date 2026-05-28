//
//  QXContentSecurityPolicy.h
//  QCCore
//
//  喜聊内容安全策略。集中维护"允许打开的链接域名白名单"、
//  "敏感关键词关键长度规则"、"附件大小限制"、"消息撤回时间窗"
//  等，便于在多个业务模块共享。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, QXLinkPolicy) {
    QXLinkPolicyAllow         = 0,
    QXLinkPolicyConfirmFirst  = 1,
    QXLinkPolicyBlock         = 2,
};

@interface QXContentSecurityPolicy : NSObject

+ (instancetype)sharedPolicy;

@property (nonatomic, assign) NSUInteger maxImageBytes;
@property (nonatomic, assign) NSUInteger maxVideoBytes;
@property (nonatomic, assign) NSUInteger maxFileBytes;
@property (nonatomic, assign) NSUInteger maxTextBytes;
@property (nonatomic, assign) NSTimeInterval revokeTimeWindow;

- (QXLinkPolicy)policyForURL:(nullable NSURL *)url;
- (BOOL)isHostExplicitlyTrusted:(NSString *)host;
- (BOOL)isHostExplicitlyBlocked:(NSString *)host;

- (void)addTrustedHost:(NSString *)host;
- (void)addBlockedHost:(NSString *)host;
- (void)removeTrustedHost:(NSString *)host;
- (void)removeBlockedHost:(NSString *)host;

- (NSArray<NSString *> *)trustedHosts;
- (NSArray<NSString *> *)blockedHosts;

@end

NS_ASSUME_NONNULL_END
