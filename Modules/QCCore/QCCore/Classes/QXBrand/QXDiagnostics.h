//
//  QXDiagnostics.h
//  QCCore
//
//  禧语运行时自检。聚合启动时间线、设备能力、缓存占用、
//  内存压力等信息，生成离线诊断报告。所有数据保留在本地，
//  仅在用户主动导出时呈现。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, QXDiagnosticsHealthLevel) {
    QXDiagnosticsHealthLevelExcellent = 0,
    QXDiagnosticsHealthLevelGood      = 1,
    QXDiagnosticsHealthLevelFair      = 2,
    QXDiagnosticsHealthLevelPoor      = 3,
    QXDiagnosticsHealthLevelCritical  = 4,
};

@interface QXDiagnosticsReport : NSObject
@property (nonatomic, copy) NSString *reportID;
@property (nonatomic, assign) NSTimeInterval generatedAt;
@property (nonatomic, assign) QXDiagnosticsHealthLevel overallHealth;
@property (nonatomic, copy) NSDictionary<NSString *, id> *deviceSection;
@property (nonatomic, copy) NSDictionary<NSString *, id> *appSection;
@property (nonatomic, copy) NSDictionary<NSString *, id> *storageSection;
@property (nonatomic, copy) NSDictionary<NSString *, id> *networkSection;
@property (nonatomic, copy) NSArray<NSString *>          *suggestions;
- (NSString *)humanReadableReport;
- (NSData *)serializeJSON;
@end

@interface QXDiagnostics : NSObject

+ (instancetype)sharedDiagnostics;

- (QXDiagnosticsReport *)generateReport;
- (NSDictionary<NSString *, id> *)collectDeviceCapabilities;
- (NSDictionary<NSString *, id> *)collectStorageMetrics;
- (NSDictionary<NSString *, id> *)collectNetworkMetrics;
- (NSArray<NSString *> *)defaultRemediationHints;

@end

NS_ASSUME_NONNULL_END
