//
//  QXContentSecurityPolicy.m
//  QCCore
//

#import "QXContentSecurityPolicy.h"

@interface QXContentSecurityPolicy ()
@property (nonatomic, strong) NSMutableSet<NSString *> *trusted;
@property (nonatomic, strong) NSMutableSet<NSString *> *blocked;
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation QXContentSecurityPolicy

+ (instancetype)sharedPolicy {
    static QXContentSecurityPolicy *p = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        p = [QXContentSecurityPolicy new];
    });
    return p;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _maxImageBytes    = 20 * 1024 * 1024;     // 20 MB
        _maxVideoBytes    = 200 * 1024 * 1024;    // 200 MB
        _maxFileBytes     = 100 * 1024 * 1024;    // 100 MB
        _maxTextBytes     = 8 * 1024;             // 8 KB
        _revokeTimeWindow = 2 * 60;               // 2 minutes

        _queue = dispatch_queue_create("ai.qx.qcore.csp", DISPATCH_QUEUE_CONCURRENT);
        _trusted = [NSMutableSet setWithArray:@[
            @"qx.ai", @"qhfhasina.com", @"githubim.cn",
            @"apple.com", @"icloud.com",
        ]];
        _blocked = [NSMutableSet set];
    }
    return self;
}

- (QXLinkPolicy)policyForURL:(NSURL *)url {
    if (!url) {
        return QXLinkPolicyBlock;
    }
    NSString *scheme = url.scheme.lowercaseString;
    if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) {
        NSString *host = url.host.lowercaseString ?: @"";
        if ([self isHostExplicitlyBlocked:host]) {
            return QXLinkPolicyBlock;
        }
        if ([self isHostExplicitlyTrusted:host]) {
            return QXLinkPolicyAllow;
        }
        return QXLinkPolicyConfirmFirst;
    }
    if ([scheme isEqualToString:@"mailto"] || [scheme isEqualToString:@"tel"]) {
        return QXLinkPolicyConfirmFirst;
    }
    return QXLinkPolicyBlock;
}

- (BOOL)isHostExplicitlyTrusted:(NSString *)host {
    if (host.length == 0) return NO;
    __block BOOL trusted = NO;
    dispatch_sync(self.queue, ^{
        for (NSString *t in self.trusted) {
            if ([host isEqualToString:t] || [host hasSuffix:[@"." stringByAppendingString:t]]) {
                trusted = YES;
                break;
            }
        }
    });
    return trusted;
}

- (BOOL)isHostExplicitlyBlocked:(NSString *)host {
    if (host.length == 0) return NO;
    __block BOOL blocked = NO;
    dispatch_sync(self.queue, ^{
        for (NSString *b in self.blocked) {
            if ([host isEqualToString:b] || [host hasSuffix:[@"." stringByAppendingString:b]]) {
                blocked = YES;
                break;
            }
        }
    });
    return blocked;
}

- (void)addTrustedHost:(NSString *)host {
    if (host.length == 0) return;
    dispatch_barrier_async(self.queue, ^{
        [self.trusted addObject:host.lowercaseString];
    });
}

- (void)addBlockedHost:(NSString *)host {
    if (host.length == 0) return;
    dispatch_barrier_async(self.queue, ^{
        [self.blocked addObject:host.lowercaseString];
    });
}

- (void)removeTrustedHost:(NSString *)host {
    if (host.length == 0) return;
    dispatch_barrier_async(self.queue, ^{
        [self.trusted removeObject:host.lowercaseString];
    });
}

- (void)removeBlockedHost:(NSString *)host {
    if (host.length == 0) return;
    dispatch_barrier_async(self.queue, ^{
        [self.blocked removeObject:host.lowercaseString];
    });
}

- (NSArray<NSString *> *)trustedHosts {
    __block NSArray *r = nil;
    dispatch_sync(self.queue, ^{
        r = [[self.trusted allObjects] sortedArrayUsingSelector:@selector(compare:)];
    });
    return r ?: @[];
}

- (NSArray<NSString *> *)blockedHosts {
    __block NSArray *r = nil;
    dispatch_sync(self.queue, ^{
        r = [[self.blocked allObjects] sortedArrayUsingSelector:@selector(compare:)];
    });
    return r ?: @[];
}

@end
