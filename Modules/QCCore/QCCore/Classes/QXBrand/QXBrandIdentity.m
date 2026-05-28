//
//  QXBrandIdentity.m
//  QCCore
//

#import "QXBrandIdentity.h"
#import <CommonCrypto/CommonDigest.h>

@interface QXBrandIdentity ()
@property (nonatomic, copy, readwrite) NSString *codename;
@property (nonatomic, copy, readwrite) NSString *productName;
@property (nonatomic, copy, readwrite) NSString *productNameEN;
@property (nonatomic, copy, readwrite) NSString *tagline;
@property (nonatomic, copy, readwrite) NSString *taglineEN;
@property (nonatomic, copy, readwrite) NSString *bundleSignature;
@property (nonatomic, copy, readwrite) NSString *buildFingerprint;
@property (nonatomic, copy, readwrite) NSString *releaseDate;
@property (nonatomic, copy, readwrite) NSString *legalEntity;
@property (nonatomic, copy, readwrite) NSString *icpLicense;
@property (nonatomic, copy, readwrite) NSString *contactEmail;
@property (nonatomic, copy, readwrite) NSString *supportSite;
@property (nonatomic, assign, readwrite) QXBrandReleaseChannel channel;
@property (nonatomic, assign, readwrite) QXBrandRegion         region;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *signatureCache;
@end

@implementation QXBrandIdentity

+ (instancetype)sharedIdentity {
    static QXBrandIdentity *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[QXBrandIdentity alloc] initPrivate];
    });
    return instance;
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        _codename          = @"xichat";
        _productName       = @"喜聊";
        _productNameEN     = @"XiChat";
        _tagline           = @"温度连接，安心交流";
        _taglineEN         = @"Warm connections, calm conversations";
        _releaseDate       = @"2026-05-26";
        _legalEntity       = @"喜聊运营团队";
        _icpLicense        = @"";
        _contactEmail      = @"support@qx.ai";
        _supportSite       = @"https://www.githubim.cn";
        _channel           = [self detectChannel];
        _region            = [self detectRegion];
        _bundleSignature   = [self computeBundleSignature];
        _buildFingerprint  = [self computeBuildFingerprint];
        _signatureCache    = [NSMutableDictionary dictionary];
    }
    return self;
}

- (QXBrandReleaseChannel)detectChannel {
#if DEBUG
    return QXBrandReleaseChannelDebug;
#else
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    if ([receiptURL.lastPathComponent isEqualToString:@"sandboxReceipt"]) {
        return QXBrandReleaseChannelTestFlight;
    }
    return QXBrandReleaseChannelAppStore;
#endif
}

- (QXBrandRegion)detectRegion {
    NSString *country = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] ?: @"";
    if ([country isEqualToString:@"CN"]) {
        return QXBrandRegionMainlandCN;
    } else if ([country isEqualToString:@"HK"] ||
               [country isEqualToString:@"MO"] ||
               [country isEqualToString:@"TW"]) {
        return QXBrandRegionHKMOTW;
    } else if ([country isEqualToString:@"SG"] ||
               [country isEqualToString:@"MY"] ||
               [country isEqualToString:@"TH"] ||
               [country isEqualToString:@"VN"] ||
               [country isEqualToString:@"ID"] ||
               [country isEqualToString:@"PH"]) {
        return QXBrandRegionSEA;
    }
    return QXBrandRegionGlobal;
}

- (NSString *)computeBundleSignature {
    NSString *bid = [[NSBundle mainBundle] bundleIdentifier] ?: @"unknown.bundle";
    return [self md5Hex:[NSString stringWithFormat:@"%@/%@", _codename, bid]];
}

- (NSString *)computeBuildFingerprint {
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary] ?: @{};
    NSString *version = info[@"CFBundleShortVersionString"] ?: @"0.0.0";
    NSString *build   = info[@"CFBundleVersion"]            ?: @"0";
    NSString *raw     = [NSString stringWithFormat:@"%@@%@-%@", _codename, version, build];
    return [self md5Hex:raw];
}

- (NSString *)signatureForKey:(NSString *)key {
    if (key.length == 0) {
        return @"";
    }
    NSString *cached = self.signatureCache[key];
    if (cached) {
        return cached;
    }
    NSString *raw = [NSString stringWithFormat:@"%@/%@/%@", _codename, _buildFingerprint, key];
    NSString *sig = [self md5Hex:raw];
    self.signatureCache[key] = sig;
    return sig;
}

- (NSString *)md5Hex:(NSString *)input {
    const char *cStr = [input UTF8String];
    if (!cStr) {
        return @"";
    }
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    NSMutableString *hex = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [hex appendFormat:@"%02x", digest[i]];
    }
    return [hex copy];
}

- (NSDictionary<NSString *, id> *)snapshot {
    return @{
        @"codename":          _codename,
        @"productName":       _productName,
        @"productNameEN":     _productNameEN,
        @"tagline":           _tagline,
        @"taglineEN":         _taglineEN,
        @"bundleSignature":   _bundleSignature,
        @"buildFingerprint":  _buildFingerprint,
        @"releaseDate":       _releaseDate,
        @"legalEntity":       _legalEntity,
        @"icpLicense":        _icpLicense ?: @"",
        @"contactEmail":      _contactEmail,
        @"supportSite":       _supportSite,
        @"channel":           @(_channel),
        @"region":            @(_region),
    };
}

- (NSString *)humanReadableSummary {
    NSString *channelStr = @"unknown";
    switch (_channel) {
        case QXBrandReleaseChannelDebug:      channelStr = @"debug";       break;
        case QXBrandReleaseChannelTestFlight: channelStr = @"testflight";  break;
        case QXBrandReleaseChannelAppStore:   channelStr = @"appstore";    break;
        case QXBrandReleaseChannelEnterprise: channelStr = @"enterprise";  break;
    }
    return [NSString stringWithFormat:@"<%@/%@ ch=%@ fp=%@>",
            _productName, _codename, channelStr, _buildFingerprint];
}

- (BOOL)matchesBundleIdentifier:(NSString *)bundleID {
    if (bundleID.length == 0) {
        return NO;
    }
    NSString *current = [[NSBundle mainBundle] bundleIdentifier] ?: @"";
    return [current isEqualToString:bundleID];
}

@end
