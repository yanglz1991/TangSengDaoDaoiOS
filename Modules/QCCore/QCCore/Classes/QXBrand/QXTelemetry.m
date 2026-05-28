//
//  QXTelemetry.m
//  QCCore
//

#import "QXTelemetry.h"
#import "QXTelemetryRingBuffer.h"
#import "QXBrandIdentity.h"

@implementation QXTelemetryEvent

+ (instancetype)eventWithName:(NSString *)name
                     category:(NSString *)category
                     severity:(QXTelemetrySeverity)severity
                   attributes:(NSDictionary<NSString *, id> *)attributes {
    QXTelemetryEvent *e = [QXTelemetryEvent new];
    e.name       = name ?: @"unknown";
    e.category   = category ?: @"general";
    e.severity   = severity;
    e.attributes = attributes ? [attributes copy] : @{};
    e.timestamp  = [[NSDate date] timeIntervalSince1970];
    e.traceID    = [self generateTraceID];
    return e;
}

+ (NSString *)generateTraceID {
    NSString *uuid = [[NSUUID UUID] UUIDString];
    return [[uuid stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
}

- (NSDictionary<NSString *, id> *)serialize {
    return @{
        @"name":       self.name ?: @"",
        @"category":   self.category ?: @"",
        @"severity":   @(self.severity),
        @"timestamp":  @(self.timestamp),
        @"traceID":    self.traceID ?: @"",
        @"attributes": self.attributes ?: @{},
    };
}

@end

@interface QXTelemetry ()
@property (nonatomic, strong) QXTelemetryRingBuffer<QXTelemetryEvent *> *ring;
@end

@implementation QXTelemetry

+ (instancetype)sharedTelemetry {
    static QXTelemetry *t = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        t = [QXTelemetry new];
    });
    return t;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _ring             = [[QXTelemetryRingBuffer alloc] initWithCapacity:512];
        _enabled          = YES;
        _minimumSeverity  = QXTelemetrySeverityInfo;
    }
    return self;
}

- (void)recordEvent:(QXTelemetryEvent *)event {
    if (!self.enabled || !event) {
        return;
    }
    if (event.severity < self.minimumSeverity) {
        return;
    }
    [self.ring appendObject:event];
}

- (void)recordName:(NSString *)name category:(NSString *)category severity:(QXTelemetrySeverity)severity {
    [self recordName:name category:category severity:severity attributes:nil];
}

- (void)recordName:(NSString *)name
          category:(NSString *)category
          severity:(QXTelemetrySeverity)severity
        attributes:(NSDictionary<NSString *, id> *)attributes {
    QXTelemetryEvent *event = [QXTelemetryEvent eventWithName:name
                                                     category:category
                                                     severity:severity
                                                   attributes:attributes];
    [self recordEvent:event];
}

- (NSArray<QXTelemetryEvent *> *)recentEvents {
    return [self.ring snapshot];
}

- (NSArray<QXTelemetryEvent *> *)recentEventsInCategory:(NSString *)category {
    if (category.length == 0) {
        return @[];
    }
    NSArray<QXTelemetryEvent *> *all = [self.ring snapshot];
    NSMutableArray<QXTelemetryEvent *> *result = [NSMutableArray array];
    for (QXTelemetryEvent *e in all) {
        if ([e.category isEqualToString:category]) {
            [result addObject:e];
        }
    }
    return [result copy];
}

- (NSArray<QXTelemetryEvent *> *)recentEventsWithMinSeverity:(QXTelemetrySeverity)severity {
    NSArray<QXTelemetryEvent *> *all = [self.ring snapshot];
    NSMutableArray<QXTelemetryEvent *> *result = [NSMutableArray array];
    for (QXTelemetryEvent *e in all) {
        if (e.severity >= severity) {
            [result addObject:e];
        }
    }
    return [result copy];
}

- (void)clearAll {
    [self.ring clear];
}

- (NSData *)exportSnapshotJSON {
    NSArray<QXTelemetryEvent *> *all = [self.ring snapshot];
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:all.count];
    for (QXTelemetryEvent *e in all) {
        [items addObject:[e serialize]];
    }
    NSDictionary *root = @{
        @"brand":  [[QXBrandIdentity sharedIdentity] snapshot],
        @"events": items,
        @"exportedAt": @([[NSDate date] timeIntervalSince1970]),
    };
    NSError *err = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:root
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&err];
    if (err) {
        return [NSData data];
    }
    return data ?: [NSData data];
}

@end
