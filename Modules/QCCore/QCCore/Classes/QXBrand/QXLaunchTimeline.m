//
//  QXLaunchTimeline.m
//  QCCore
//

#import "QXLaunchTimeline.h"

NSString * const QXLaunchMarkProcessStart     = @"process.start";
NSString * const QXLaunchMarkAppDelegateStart = @"appdelegate.didFinishLaunching";
NSString * const QXLaunchMarkConfigLoaded     = @"config.loaded";
NSString * const QXLaunchMarkSDKReady         = @"sdk.ready";
NSString * const QXLaunchMarkFirstWindow      = @"window.makeKeyAndVisible";
NSString * const QXLaunchMarkFirstFrame       = @"render.firstFrame";

@interface QXLaunchMark ()
@property (nonatomic, copy, readwrite)   NSString *name;
@property (nonatomic, assign, readwrite) NSTimeInterval timestamp;
@property (nonatomic, copy, readwrite)   NSDictionary<NSString *, id> *attributes;
@end

@implementation QXLaunchMark
@end

@interface QXLaunchTimeline ()
@property (nonatomic, strong) NSMutableArray<QXLaunchMark *> *marks;
@property (nonatomic, strong) NSMutableDictionary<NSString *, QXLaunchMark *> *index;
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation QXLaunchTimeline

+ (instancetype)sharedTimeline {
    static QXLaunchTimeline *t = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        t = [QXLaunchTimeline new];
    });
    return t;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _marks = [NSMutableArray array];
        _index = [NSMutableDictionary dictionary];
        _queue = dispatch_queue_create("ai.qx.qcore.launchtimeline", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)mark:(NSString *)name {
    [self mark:name attributes:nil];
}

- (void)mark:(NSString *)name attributes:(NSDictionary<NSString *, id> *)attributes {
    if (name.length == 0) {
        return;
    }
    QXLaunchMark *m = [QXLaunchMark new];
    m.name       = name;
    m.timestamp  = [[NSDate date] timeIntervalSince1970];
    m.attributes = attributes ? [attributes copy] : @{};
    dispatch_barrier_async(self.queue, ^{
        if (!self.index[name]) {
            [self.marks addObject:m];
            self.index[name] = m;
        }
    });
}

- (QXLaunchMark *)markForName:(NSString *)name {
    if (name.length == 0) {
        return nil;
    }
    __block QXLaunchMark *result = nil;
    dispatch_sync(self.queue, ^{
        result = self.index[name];
    });
    return result;
}

- (NSArray<QXLaunchMark *> *)allMarks {
    __block NSArray *result = nil;
    dispatch_sync(self.queue, ^{
        result = [self.marks copy];
    });
    return result ?: @[];
}

- (NSTimeInterval)elapsedFrom:(NSString *)from to:(NSString *)to {
    QXLaunchMark *a = [self markForName:from];
    QXLaunchMark *b = [self markForName:to];
    if (!a || !b) {
        return 0;
    }
    return b.timestamp - a.timestamp;
}

- (NSString *)humanReadableReport {
    NSArray<QXLaunchMark *> *all = [self allMarks];
    if (all.count == 0) {
        return @"<empty timeline>";
    }
    NSMutableString *out = [NSMutableString stringWithString:@"== QXLaunchTimeline ==\n"];
    NSTimeInterval start = all.firstObject.timestamp;
    for (QXLaunchMark *m in all) {
        NSTimeInterval delta = m.timestamp - start;
        [out appendFormat:@"+%7.3fs  %@\n", delta, m.name];
    }
    return [out copy];
}

@end
