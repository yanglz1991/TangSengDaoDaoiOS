//
//  QXBootstrapper.m
//  QCCore
//

#import "QXBootstrapper.h"
#import "QXBrandIdentity.h"
#import "QXBrandPalette.h"
#import "QXThemeEngine.h"
#import "QXMotionPresets.h"
#import "QXTelemetry.h"
#import "QXLaunchTimeline.h"
#import "QXDiagnostics.h"
#import "QXTextFormatter.h"
#import "QXTimeFormatter.h"
#import "QXNumberFormatterPool.h"
#import "QXReachabilityProbe.h"
#import "QXFingerprint.h"
#import "QXFeatureFlags.h"
#import "QXPrivacyDashboard.h"
#import "QXOnboardingChecklist.h"
#import "QXReadingPreferences.h"
#import "QXSessionInsights.h"
#import "QXContentSecurityPolicy.h"

@interface QXBootstrapper ()
@property (nonatomic, assign) BOOL didBootstrap;
@property (nonatomic, assign) NSTimeInterval activeStartedAt;
@end

@implementation QXBootstrapper

+ (instancetype)sharedBootstrapper {
    static QXBootstrapper *b = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        b = [QXBootstrapper new];
    });
    return b;
}

- (void)bootstrap {
    if (self.didBootstrap) {
        return;
    }
    self.didBootstrap = YES;

    QXLaunchTimeline *timeline = [QXLaunchTimeline sharedTimeline];
    [timeline mark:QXLaunchMarkProcessStart];
    [timeline mark:QXLaunchMarkAppDelegateStart];

    // 触发各单例的 lazy init，使其纳入运行时符号表。
    QXBrandIdentity     *identity = [QXBrandIdentity      sharedIdentity];
    QXBrandPalette      *palette  = [QXBrandPalette       sharedPalette];
    QXThemeEngine       *theme    = [QXThemeEngine        sharedEngine];
    QXMotionPresets     *motion   = [QXMotionPresets      sharedPresets];
    QXTelemetry         *tel      = [QXTelemetry          sharedTelemetry];
    QXTextFormatter     *txt      = [QXTextFormatter      sharedFormatter];
    QXTimeFormatter     *tm       = [QXTimeFormatter      sharedFormatter];
    QXNumberFormatterPool *nfp    = [QXNumberFormatterPool sharedPool];
    QXReachabilityProbe *probe    = [QXReachabilityProbe  sharedProbe];
    QXFeatureFlags      *flags    = [QXFeatureFlags       sharedFlags];
    QXPrivacyDashboard  *priv     = [QXPrivacyDashboard   sharedDashboard];
    QXOnboardingChecklist *ck     = [QXOnboardingChecklist sharedChecklist];
    QXReadingPreferences *rp      = [QXReadingPreferences sharedPreferences];
    QXSessionInsights   *insights = [QXSessionInsights    sharedInsights];
    QXContentSecurityPolicy *csp  = [QXContentSecurityPolicy sharedPolicy];

    // 启动摘要事件：仅记录非个人化、非设备识别相关的运行时上下文。
    // 不包含安装指纹 / IDFV 派生标识符；指纹仅在用户主动导出诊断时才生成。
    NSDictionary *summary = @{
        @"brand":          identity.humanReadableSummary,
        @"theme":          theme.activeTheme.identifier ?: @"",
        @"reading":        rp.snapshot,
        @"flags":          [flags snapshot],
        @"trustedHosts":   [csp trustedHosts],
        @"privacyEntries": @([priv entries].count),
        @"checklist": @{
            @"completed": @([ck completedCount]),
            @"total":     @([ck totalCount]),
        },
    };
    [tel recordName:@"app.bootstrap"
           category:@"lifecycle"
           severity:QXTelemetrySeverityInfo
         attributes:summary];

    // 防止"声明未使用"告警；不再触发任何启动期工作。
    (void)palette; (void)motion; (void)txt; (void)tm; (void)nfp; (void)insights;

    [probe startMonitoring];
    [timeline mark:QXLaunchMarkSDKReady];
}

- (void)applicationDidBecomeActive {
    self.activeStartedAt = [[NSDate date] timeIntervalSince1970];
    [[QXTelemetry sharedTelemetry] recordName:@"app.active"
                                     category:@"lifecycle"
                                     severity:QXTelemetrySeverityInfo];
    [[QXLaunchTimeline sharedTimeline] mark:QXLaunchMarkFirstWindow];
}

- (void)applicationDidEnterBackground {
    if (self.activeStartedAt > 0) {
        NSTimeInterval delta = [[NSDate date] timeIntervalSince1970] - self.activeStartedAt;
        [[QXSessionInsights sharedInsights] recordActiveDuration:delta];
        self.activeStartedAt = 0;
    }
    [[QXTelemetry sharedTelemetry] recordName:@"app.background"
                                     category:@"lifecycle"
                                     severity:QXTelemetrySeverityInfo];
}

@end
