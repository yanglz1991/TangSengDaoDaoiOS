//
//  QXFingerprint.m
//  QCCore
//

#import "QXFingerprint.h"

static NSString * const kQXDiagnosticsTagKey = @"QXDiagnostics.localTag.v1";

@interface QXFingerprint ()
@property (nonatomic, copy) NSString *cachedTag;
@property (nonatomic, copy) NSString *cachedSessionTag;
@end

@implementation QXFingerprint

+ (instancetype)sharedFingerprint {
    static QXFingerprint *f = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        f = [QXFingerprint new];
    });
    return f;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _cachedSessionTag = [[NSUUID UUID] UUIDString];
    }
    return self;
}

- (NSString *)diagnosticsTag {
    if (self.cachedTag) {
        return self.cachedTag;
    }
    NSString *saved = [[NSUserDefaults standardUserDefaults] stringForKey:kQXDiagnosticsTagKey];
    if (saved.length > 0) {
        self.cachedTag = saved;
        return saved;
    }
    NSString *tag = [[NSUUID UUID] UUIDString];
    self.cachedTag = tag;
    [[NSUserDefaults standardUserDefaults] setObject:tag forKey:kQXDiagnosticsTagKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return tag;
}

- (void)resetTag {
    self.cachedTag = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kQXDiagnosticsTagKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)sessionTag {
    return self.cachedSessionTag ?: @"";
}

@end
