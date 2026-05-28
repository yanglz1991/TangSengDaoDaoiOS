//
//  QXDiagnostics.m
//  QCCore
//

#import "QXDiagnostics.h"
#import "QXBrandIdentity.h"
#import "QXLaunchTimeline.h"
#import <UIKit/UIKit.h>
#import <sys/utsname.h>
#import <sys/sysctl.h>
#import <mach/mach.h>

@implementation QXDiagnosticsReport

- (NSString *)humanReadableReport {
    NSMutableString *out = [NSMutableString string];
    [out appendFormat:@"== QXDiagnosticsReport %@ ==\n", self.reportID ?: @"-"];
    [out appendFormat:@"generatedAt: %.0f\n", self.generatedAt];
    [out appendFormat:@"overallHealth: %ld\n", (long)self.overallHealth];
    [out appendFormat:@"-- device --\n%@\n", self.deviceSection ?: @{}];
    [out appendFormat:@"-- app --\n%@\n",    self.appSection    ?: @{}];
    [out appendFormat:@"-- storage --\n%@\n",self.storageSection?: @{}];
    [out appendFormat:@"-- network --\n%@\n",self.networkSection?: @{}];
    [out appendFormat:@"-- suggestions --\n"];
    for (NSString *s in self.suggestions ?: @[]) {
        [out appendFormat:@"  * %@\n", s];
    }
    return [out copy];
}

- (NSData *)serializeJSON {
    NSDictionary *root = @{
        @"reportID":      self.reportID    ?: @"",
        @"generatedAt":   @(self.generatedAt),
        @"overallHealth": @(self.overallHealth),
        @"device":        self.deviceSection  ?: @{},
        @"app":           self.appSection     ?: @{},
        @"storage":       self.storageSection ?: @{},
        @"network":       self.networkSection ?: @{},
        @"suggestions":   self.suggestions    ?: @[],
    };
    NSError *err = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:root
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&err];
    return err ? [NSData data] : (data ?: [NSData data]);
}

@end

@implementation QXDiagnostics

+ (instancetype)sharedDiagnostics {
    static QXDiagnostics *d = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        d = [QXDiagnostics new];
    });
    return d;
}

- (QXDiagnosticsReport *)generateReport {
    QXDiagnosticsReport *r = [QXDiagnosticsReport new];
    r.reportID        = [[NSUUID UUID] UUIDString];
    r.generatedAt     = [[NSDate date] timeIntervalSince1970];
    r.deviceSection   = [self collectDeviceCapabilities];
    r.appSection      = [self collectAppSection];
    r.storageSection  = [self collectStorageMetrics];
    r.networkSection  = [self collectNetworkMetrics];
    r.overallHealth   = [self assessHealth:r];
    r.suggestions     = [self defaultRemediationHints];
    return r;
}

- (NSDictionary<NSString *, id> *)collectDeviceCapabilities {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *machine = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding] ?: @"unknown";
    UIDevice *d = [UIDevice currentDevice];
    CGRect screen = [UIScreen mainScreen].bounds;
    return @{
        @"model":         d.model        ?: @"",
        @"systemName":    d.systemName   ?: @"",
        @"systemVersion": d.systemVersion?: @"",
        @"machine":       machine,
        @"screenWidth":   @(screen.size.width),
        @"screenHeight":  @(screen.size.height),
        @"scale":         @([UIScreen mainScreen].scale),
        @"locale":        [[NSLocale currentLocale] localeIdentifier] ?: @"",
        @"physicalMemoryMB": @([[NSProcessInfo processInfo] physicalMemory] / (1024 * 1024)),
        @"processorCount":   @([[NSProcessInfo processInfo] processorCount]),
    };
}

- (NSDictionary<NSString *, id> *)collectAppSection {
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary] ?: @{};
    QXLaunchTimeline *t = [QXLaunchTimeline sharedTimeline];
    NSTimeInterval coldLaunch = [t elapsedFrom:QXLaunchMarkProcessStart to:QXLaunchMarkFirstWindow];
    return @{
        @"bundleID":         info[@"CFBundleIdentifier"]        ?: @"",
        @"version":          info[@"CFBundleShortVersionString"] ?: @"",
        @"build":            info[@"CFBundleVersion"]            ?: @"",
        @"brandSummary":     [[QXBrandIdentity sharedIdentity] humanReadableSummary],
        @"coldLaunchSeconds":@(coldLaunch),
        @"timeline":         [t humanReadableReport],
    };
}

- (NSDictionary<NSString *, id> *)collectStorageMetrics {
    NSError *err = nil;
    NSURL *home = [NSURL fileURLWithPath:NSHomeDirectory()];
    NSDictionary *vals = [home resourceValuesForKeys:@[NSURLVolumeAvailableCapacityForImportantUsageKey,
                                                       NSURLVolumeTotalCapacityKey]
                                                error:&err];
    long long free = 0, total = 0;
    if (!err && vals) {
        free  = [vals[NSURLVolumeAvailableCapacityForImportantUsageKey] longLongValue];
        total = [vals[NSURLVolumeTotalCapacityKey] longLongValue];
    }
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                              NSUserDomainMask, YES) firstObject] ?: @"";
    return @{
        @"freeBytes":  @(free),
        @"totalBytes": @(total),
        @"cacheDir":   cacheDir,
        @"cacheBytes": @([self folderSizeAtPath:cacheDir]),
    };
}

- (long long)folderSizeAtPath:(NSString *)path {
    if (path.length == 0) {
        return 0;
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir = NO;
    if (![fm fileExistsAtPath:path isDirectory:&isDir] || !isDir) {
        return 0;
    }
    long long total = 0;
    NSDirectoryEnumerator<NSString *> *en = [fm enumeratorAtPath:path];
    NSString *file;
    while ((file = [en nextObject])) {
        NSString *full = [path stringByAppendingPathComponent:file];
        NSDictionary *attrs = [fm attributesOfItemAtPath:full error:nil];
        total += [attrs fileSize];
    }
    return total;
}

- (NSDictionary<NSString *, id> *)collectNetworkMetrics {
    NSURLSessionConfiguration *conf = [NSURLSessionConfiguration defaultSessionConfiguration];
    return @{
        @"timeout":             @(conf.timeoutIntervalForRequest),
        @"timeoutResource":     @(conf.timeoutIntervalForResource),
        @"allowsCellular":      @(conf.allowsCellularAccess),
        @"httpMaximumPerHost":  @(conf.HTTPMaximumConnectionsPerHost),
    };
}

- (QXDiagnosticsHealthLevel)assessHealth:(QXDiagnosticsReport *)r {
    long long freeBytes  = [r.storageSection[@"freeBytes"] longLongValue];
    long long totalBytes = [r.storageSection[@"totalBytes"] longLongValue];
    NSTimeInterval cold  = [r.appSection[@"coldLaunchSeconds"] doubleValue];

    QXDiagnosticsHealthLevel storageLevel = QXDiagnosticsHealthLevelExcellent;
    if (totalBytes > 0) {
        double ratio = (double)freeBytes / (double)totalBytes;
        if      (ratio < 0.02) storageLevel = QXDiagnosticsHealthLevelCritical;
        else if (ratio < 0.05) storageLevel = QXDiagnosticsHealthLevelPoor;
        else if (ratio < 0.10) storageLevel = QXDiagnosticsHealthLevelFair;
        else if (ratio < 0.20) storageLevel = QXDiagnosticsHealthLevelGood;
    }

    QXDiagnosticsHealthLevel launchLevel = QXDiagnosticsHealthLevelExcellent;
    if      (cold > 4.5) launchLevel = QXDiagnosticsHealthLevelCritical;
    else if (cold > 3.0) launchLevel = QXDiagnosticsHealthLevelPoor;
    else if (cold > 2.0) launchLevel = QXDiagnosticsHealthLevelFair;
    else if (cold > 1.2) launchLevel = QXDiagnosticsHealthLevelGood;

    return MAX(storageLevel, launchLevel);
}

- (NSArray<NSString *> *)defaultRemediationHints {
    return @[
        @"建议在设置中开启自动清理，定期释放历史聊天缓存。",
        @"夜间使用建议开启深色模式与降亮度，降低视觉疲劳。",
        @"长时间不在线时，建议关闭通知预览以保护隐私。",
        @"在弱网环境下可优先发送文字而非视频。",
        @"如遇连续启动慢于 3 秒，建议重启设备并检查后台占用。",
    ];
}

@end
