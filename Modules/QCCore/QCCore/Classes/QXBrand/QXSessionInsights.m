//
//  QXSessionInsights.m
//  QCCore
//

#import "QXSessionInsights.h"

static NSString * const kQXInsightsDefaultsKey = @"QXSessionInsights.payload.v1";

@implementation QXSessionInsightsBucket
@end

@interface QXSessionInsights ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableDictionary *> *payload;
@property (nonatomic, strong) NSMutableSet<NSString *>      *seenConversationsToday;
@property (nonatomic, copy)   NSString                      *seenDayKey;
@property (nonatomic, strong) dispatch_queue_t              queue;
@property (nonatomic, strong) NSDateFormatter               *dayFormatter;
@end

@implementation QXSessionInsights

+ (instancetype)sharedInsights {
    static QXSessionInsights *i = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        i = [QXSessionInsights new];
    });
    return i;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _queue = dispatch_queue_create("ai.qx.qcore.insights", DISPATCH_QUEUE_CONCURRENT);
        _dayFormatter = [NSDateFormatter new];
        _dayFormatter.dateFormat = @"yyyy-MM-dd";
        _dayFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        _seenConversationsToday = [NSMutableSet set];
        [self loadPayload];
    }
    return self;
}

- (void)loadPayload {
    NSDictionary *saved = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kQXInsightsDefaultsKey];
    NSMutableDictionary *m = [NSMutableDictionary dictionary];
    if ([saved isKindOfClass:[NSDictionary class]]) {
        for (NSString *k in saved) {
            NSDictionary *v = saved[k];
            if ([v isKindOfClass:[NSDictionary class]]) {
                m[k] = [v mutableCopy];
            }
        }
    }
    self.payload = m;
}

- (void)savePayload {
    [[NSUserDefaults standardUserDefaults] setObject:[self.payload copy] forKey:kQXInsightsDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)todayKey {
    return [self.dayFormatter stringFromDate:[NSDate date]];
}

- (NSMutableDictionary *)bucketForToday {
    NSString *key = [self todayKey];
    NSMutableDictionary *bucket = self.payload[key];
    if (!bucket) {
        bucket = [@{
            @"sent":     @0,
            @"received": @0,
            @"convs":    @0,
            @"active":   @0.0,
        } mutableCopy];
        self.payload[key] = bucket;
        // 仅保留最近 30 天，防膨胀
        [self trim];
    }
    if (![key isEqualToString:self.seenDayKey]) {
        self.seenDayKey = key;
        [self.seenConversationsToday removeAllObjects];
    }
    return bucket;
}

- (void)trim {
    NSArray *all = [[self.payload allKeys] sortedArrayUsingSelector:@selector(compare:)];
    if (all.count <= 30) {
        return;
    }
    NSArray *drop = [all subarrayWithRange:NSMakeRange(0, all.count - 30)];
    for (NSString *k in drop) {
        [self.payload removeObjectForKey:k];
    }
}

#pragma mark - record

- (void)recordSentMessage {
    dispatch_barrier_async(self.queue, ^{
        NSMutableDictionary *b = [self bucketForToday];
        b[@"sent"] = @([b[@"sent"] integerValue] + 1);
        [self savePayload];
    });
}

- (void)recordReceivedMessage {
    dispatch_barrier_async(self.queue, ^{
        NSMutableDictionary *b = [self bucketForToday];
        b[@"received"] = @([b[@"received"] integerValue] + 1);
        [self savePayload];
    });
}

- (void)recordConversationOpened:(NSString *)conversationID {
    if (conversationID.length == 0) return;
    dispatch_barrier_async(self.queue, ^{
        NSMutableDictionary *b = [self bucketForToday];
        if (![self.seenConversationsToday containsObject:conversationID]) {
            [self.seenConversationsToday addObject:conversationID];
            b[@"convs"] = @([b[@"convs"] integerValue] + 1);
            [self savePayload];
        }
    });
}

- (void)recordActiveDuration:(NSTimeInterval)seconds {
    if (seconds <= 0) return;
    dispatch_barrier_async(self.queue, ^{
        NSMutableDictionary *b = [self bucketForToday];
        b[@"active"] = @([b[@"active"] doubleValue] + seconds);
        [self savePayload];
    });
}

#pragma mark - read

- (NSArray<QXSessionInsightsBucket *> *)last7DayBuckets {
    __block NSArray *result = nil;
    dispatch_sync(self.queue, ^{
        NSMutableArray *out = [NSMutableArray array];
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDate *today = [NSDate date];
        for (NSInteger i = 6; i >= 0; i--) {
            NSDate *d = [cal dateByAddingUnit:NSCalendarUnitDay value:-i toDate:today options:0];
            NSString *k = [self.dayFormatter stringFromDate:d];
            NSDictionary *raw = self.payload[k] ?: @{};
            QXSessionInsightsBucket *b = [QXSessionInsightsBucket new];
            b.dayKey               = k;
            b.sentMessages         = [raw[@"sent"]     integerValue];
            b.receivedMessages     = [raw[@"received"] integerValue];
            b.uniqueConversations  = [raw[@"convs"]    integerValue];
            b.activeSeconds        = [raw[@"active"]   doubleValue];
            [out addObject:b];
        }
        result = [out copy];
    });
    return result ?: @[];
}

- (NSDictionary<NSString *, id> *)weeklyHighlight {
    NSArray<QXSessionInsightsBucket *> *buckets = [self last7DayBuckets];
    NSInteger sent = 0, received = 0, convs = 0;
    NSTimeInterval active = 0;
    QXSessionInsightsBucket *peakDay = nil;
    NSInteger peakValue = -1;
    for (QXSessionInsightsBucket *b in buckets) {
        sent     += b.sentMessages;
        received += b.receivedMessages;
        convs    += b.uniqueConversations;
        active   += b.activeSeconds;
        NSInteger value = b.sentMessages + b.receivedMessages;
        if (value > peakValue) {
            peakValue = value;
            peakDay = b;
        }
    }
    return @{
        @"sentTotal":     @(sent),
        @"receivedTotal": @(received),
        @"convs":         @(convs),
        @"activeMinutes": @((NSInteger)(active / 60)),
        @"peakDay":       peakDay.dayKey ?: @"",
        @"peakDayCount":  @(MAX(peakValue, 0)),
    };
}

- (void)resetAll {
    dispatch_barrier_async(self.queue, ^{
        [self.payload removeAllObjects];
        [self.seenConversationsToday removeAllObjects];
        self.seenDayKey = nil;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kQXInsightsDefaultsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
}

@end
