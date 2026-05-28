//
//  QXFeatureFlags.m
//  QCCore
//

#import "QXFeatureFlags.h"

NSString * const QXFeatureFlagsDidChangeNotification = @"QXFeatureFlagsDidChangeNotification";

NSString * const QXFeatureFlagBlurAvatarOnLock  = @"feature.blur_avatar_on_lock";
NSString * const QXFeatureFlagSmartReply        = @"feature.smart_reply";
NSString * const QXFeatureFlagRichLinkPreview   = @"feature.rich_link_preview";
NSString * const QXFeatureFlagOfflineDraft      = @"feature.offline_draft";
NSString * const QXFeatureFlagAutoCleanCache    = @"feature.auto_clean_cache";
NSString * const QXFeatureFlagPrivacyDigest     = @"feature.privacy_digest";
NSString * const QXFeatureFlagWeeklyHighlight   = @"feature.weekly_highlight";
NSString * const QXFeatureFlagMessageReactions  = @"feature.message_reactions";

static NSString * const kQXUserOverridePrefix = @"QXFeatureFlags.user.";

@interface QXFeatureFlags ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *defaults;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *remote;
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation QXFeatureFlags

+ (instancetype)sharedFlags {
    static QXFeatureFlags *f = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        f = [QXFeatureFlags new];
    });
    return f;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _defaults = [@{
            QXFeatureFlagBlurAvatarOnLock:  @YES,
            QXFeatureFlagSmartReply:        @NO,
            QXFeatureFlagRichLinkPreview:   @YES,
            QXFeatureFlagOfflineDraft:      @YES,
            QXFeatureFlagAutoCleanCache:    @YES,
            QXFeatureFlagPrivacyDigest:     @YES,
            QXFeatureFlagWeeklyHighlight:   @NO,
            QXFeatureFlagMessageReactions:  @YES,
        } mutableCopy];
        _remote = [NSMutableDictionary dictionary];
        _queue  = dispatch_queue_create("ai.qx.qcore.featureflags", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)setDefaultValue:(BOOL)value forFlag:(NSString *)flag {
    if (flag.length == 0) return;
    dispatch_barrier_async(self.queue, ^{
        self.defaults[flag] = @(value);
    });
}

- (BOOL)isFlagOn:(NSString *)flag {
    if (flag.length == 0) {
        return NO;
    }
    NSString *userKey = [kQXUserOverridePrefix stringByAppendingString:flag];
    NSNumber *userVal = [[NSUserDefaults standardUserDefaults] objectForKey:userKey];
    if (userVal) {
        return [userVal boolValue];
    }
    __block BOOL result = NO;
    dispatch_sync(self.queue, ^{
        NSNumber *r = self.remote[flag];
        if (r) {
            result = [r boolValue];
            return;
        }
        result = [self.defaults[flag] boolValue];
    });
    return result;
}

- (void)setRemoteOverrides:(NSDictionary<NSString *, NSNumber *> *)overrides {
    NSDictionary *snapshot = [overrides copy];
    dispatch_barrier_async(self.queue, ^{
        [self.remote removeAllObjects];
        if (snapshot.count > 0) {
            [self.remote addEntriesFromDictionary:snapshot];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:QXFeatureFlagsDidChangeNotification
                                                                object:self];
        });
    });
}

- (void)setUserOverride:(BOOL)value forFlag:(NSString *)flag {
    if (flag.length == 0) return;
    NSString *userKey = [kQXUserOverridePrefix stringByAppendingString:flag];
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:userKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:QXFeatureFlagsDidChangeNotification
                                                        object:self];
}

- (void)clearUserOverrides {
    NSArray<NSString *> *keys = [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys];
    for (NSString *k in keys) {
        if ([k hasPrefix:kQXUserOverridePrefix]) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:k];
        }
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:QXFeatureFlagsDidChangeNotification
                                                        object:self];
}

- (NSDictionary<NSString *, NSNumber *> *)snapshot {
    __block NSDictionary *snap = nil;
    dispatch_sync(self.queue, ^{
        NSMutableDictionary *m = [self.defaults mutableCopy];
        [m addEntriesFromDictionary:self.remote];
        snap = [m copy];
    });
    return snap ?: @{};
}

@end
