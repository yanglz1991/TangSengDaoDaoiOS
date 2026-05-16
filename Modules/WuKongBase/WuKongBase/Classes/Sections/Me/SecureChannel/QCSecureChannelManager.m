//
//  QCSecureChannelManager.m
//  WuKongBase
//

#import "QCSecureChannelManager.h"
#import "WuKongBase.h"

static NSString *const kSecureChannelPasswordKey = @"secure_channel_password";

@interface QCSecureChannelManager ()
@property(nonatomic, assign, readwrite) BOOL enabled;
@property(nonatomic, copy, readwrite) NSString *displayName;
@end

@implementation QCSecureChannelManager

+ (instancetype)shared {
    static QCSecureChannelManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _enabled = NO;
        _displayName = @"";
    }
    return self;
}

- (void)refreshConfig:(void (^)(BOOL, NSString * _Nonnull))complete {
    __weak typeof(self) weakSelf = self;
    [[QCAPIClient sharedClient] GET:@"common/secure_channel" parameters:nil].then(^(id result) {
        BOOL enabled = NO;
        NSString *name = @"";
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)result;
            enabled = [dic[@"enabled"] boolValue];
            name = dic[@"name"] ?: @"";
        }
        weakSelf.enabled = enabled;
        weakSelf.displayName = name;
        if (complete) {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(enabled, name);
            });
        }
    }).catch(^(NSError *error) {
        weakSelf.enabled = NO;
        weakSelf.displayName = @"";
        if (complete) {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(NO, @"");
            });
        }
    });
}

- (void)verifyWithPassword:(NSString *)password
                  complete:(void (^)(NSString * _Nullable, NSError * _Nullable))complete {
    NSDictionary *body = @{@"password": password ?: @""};
    [[QCAPIClient sharedClient] POST:@"common/secure_channel/verify" parameters:body].then(^(id result) {
        NSString *url = nil;
        if ([result isKindOfClass:[NSDictionary class]]) {
            url = ((NSDictionary *)result)[@"url"];
        }
        if (complete) {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(url, nil);
            });
        }
    }).catch(^(NSError *error) {
        if (complete) {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, error);
            });
        }
    });
}

- (NSString *)savedPassword {
    NSString *v = [[NSUserDefaults standardUserDefaults] stringForKey:kSecureChannelPasswordKey];
    return v.length > 0 ? v : nil;
}

- (void)setSavedPassword:(NSString *)password {
    if (password.length > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:password forKey:kSecureChannelPasswordKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSecureChannelPasswordKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)clearSavedPassword {
    [self setSavedPassword:nil];
}

@end
