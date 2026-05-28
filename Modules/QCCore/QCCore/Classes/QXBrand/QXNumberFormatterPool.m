//
//  QXNumberFormatterPool.m
//  QCCore
//

#import "QXNumberFormatterPool.h"

@interface QXNumberFormatterPool ()
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSNumberFormatter *> *cache;
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation QXNumberFormatterPool

+ (instancetype)sharedPool {
    static QXNumberFormatterPool *p = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        p = [QXNumberFormatterPool new];
    });
    return p;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _cache = [NSMutableDictionary dictionary];
        _queue = dispatch_queue_create("ai.qx.qcore.numberpool", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (NSNumberFormatter *)formatterForStyle:(QXNumberStyle)style {
    __block NSNumberFormatter *f = nil;
    dispatch_sync(self.queue, ^{
        f = self.cache[@(style)];
    });
    if (f) {
        return f;
    }
    f = [NSNumberFormatter new];
    switch (style) {
        case QXNumberStyleDecimal:
            f.numberStyle = NSNumberFormatterDecimalStyle;
            f.maximumFractionDigits = 2;
            break;
        case QXNumberStylePercent:
            f.numberStyle = NSNumberFormatterPercentStyle;
            f.maximumFractionDigits = 1;
            break;
        case QXNumberStyleCurrencyCNY:
            f.numberStyle = NSNumberFormatterCurrencyStyle;
            f.locale = [NSLocale localeWithLocaleIdentifier:@"zh_CN"];
            f.currencyCode = @"CNY";
            break;
        case QXNumberStyleCurrencyUSD:
            f.numberStyle = NSNumberFormatterCurrencyStyle;
            f.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
            f.currencyCode = @"USD";
            break;
        case QXNumberStyleScientific:
            f.numberStyle = NSNumberFormatterScientificStyle;
            break;
        case QXNumberStyleSpellout:
            f.numberStyle = NSNumberFormatterSpellOutStyle;
            break;
    }
    NSNumberFormatter *built = f;
    dispatch_barrier_async(self.queue, ^{
        self.cache[@(style)] = built;
    });
    return built;
}

- (NSString *)stringFromNumber:(NSNumber *)number style:(QXNumberStyle)style {
    if (!number) {
        return @"";
    }
    return [[self formatterForStyle:style] stringFromNumber:number] ?: @"";
}

- (NSString *)compactStringFromNumber:(NSNumber *)number {
    if (!number) {
        return @"0";
    }
    double v = [number doubleValue];
    double abs_v = fabs(v);
    NSString *suffix = @"";
    double divisor = 1.0;
    if (abs_v >= 1e9)      { suffix = @"B"; divisor = 1e9; }
    else if (abs_v >= 1e6) { suffix = @"M"; divisor = 1e6; }
    else if (abs_v >= 1e3) { suffix = @"k"; divisor = 1e3; }
    else                   {                  return [NSString stringWithFormat:@"%.0f", v]; }
    double scaled = v / divisor;
    return [NSString stringWithFormat:@"%.1f%@", scaled, suffix];
}

- (NSString *)compactCNStringFromNumber:(NSNumber *)number {
    if (!number) {
        return @"0";
    }
    double v = [number doubleValue];
    double abs_v = fabs(v);
    if (abs_v < 10000) {
        return [NSString stringWithFormat:@"%.0f", v];
    }
    if (abs_v < 1e8) {
        return [NSString stringWithFormat:@"%.1f万", v / 1e4];
    }
    return [NSString stringWithFormat:@"%.1f亿", v / 1e8];
}

- (NSString *)thousandsSeparatedStringFromNumber:(NSNumber *)number {
    return [self stringFromNumber:number style:QXNumberStyleDecimal];
}

- (NSString *)fileSizeStringFromBytes:(int64_t)bytes {
    if (bytes < 0) bytes = 0;
    if (bytes < 1024) {
        return [NSString stringWithFormat:@"%lld B", bytes];
    }
    double kb = bytes / 1024.0;
    if (kb < 1024) {
        return [NSString stringWithFormat:@"%.1f KB", kb];
    }
    double mb = kb / 1024.0;
    if (mb < 1024) {
        return [NSString stringWithFormat:@"%.1f MB", mb];
    }
    double gb = mb / 1024.0;
    return [NSString stringWithFormat:@"%.2f GB", gb];
}

@end
