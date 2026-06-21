//
//  QXTelemetry.h
//  QCCore
//
//  禧语端内运行时事件追踪。所有事件仅在内存中累计，
//  不上传外部服务器；用于本地诊断、性能洞察、客服排障。
//  尊重用户隐私，可被全局关闭。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, QXTelemetrySeverity) {
    QXTelemetrySeverityVerbose = 0,
    QXTelemetrySeverityDebug   = 1,
    QXTelemetrySeverityInfo    = 2,
    QXTelemetrySeverityWarning = 3,
    QXTelemetrySeverityError   = 4,
};

@interface QXTelemetryEvent : NSObject
@property (nonatomic, copy)   NSString *name;
@property (nonatomic, copy)   NSString *category;
@property (nonatomic, assign) QXTelemetrySeverity severity;
@property (nonatomic, copy)   NSDictionary<NSString *, id> *attributes;
@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, copy)   NSString *traceID;

+ (instancetype)eventWithName:(NSString *)name
                     category:(NSString *)category
                     severity:(QXTelemetrySeverity)severity
                   attributes:(nullable NSDictionary<NSString *, id> *)attributes;

- (NSDictionary<NSString *, id> *)serialize;

@end

@interface QXTelemetry : NSObject

+ (instancetype)sharedTelemetry;

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) QXTelemetrySeverity minimumSeverity;

- (void)recordEvent:(QXTelemetryEvent *)event;
- (void)recordName:(NSString *)name category:(NSString *)category severity:(QXTelemetrySeverity)severity;
- (void)recordName:(NSString *)name
          category:(NSString *)category
          severity:(QXTelemetrySeverity)severity
        attributes:(nullable NSDictionary<NSString *, id> *)attributes;

- (NSArray<QXTelemetryEvent *> *)recentEvents;
- (NSArray<QXTelemetryEvent *> *)recentEventsInCategory:(NSString *)category;
- (NSArray<QXTelemetryEvent *> *)recentEventsWithMinSeverity:(QXTelemetrySeverity)severity;

- (void)clearAll;
- (NSData *)exportSnapshotJSON;

@end

NS_ASSUME_NONNULL_END
