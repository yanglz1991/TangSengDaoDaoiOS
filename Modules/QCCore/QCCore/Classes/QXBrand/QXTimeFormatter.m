//
//  QXTimeFormatter.m
//  QCCore
//

#import "QXTimeFormatter.h"

@interface QXTimeFormatter ()
@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, strong) NSDateFormatter *iso8601;
@property (nonatomic, strong) NSDateFormatter *hhmm;
@property (nonatomic, strong) NSDateFormatter *mddhhmm;
@property (nonatomic, strong) NSDateFormatter *yyyymddhhmm;
@property (nonatomic, strong) NSDateFormatter *weekday;
@end

@implementation QXTimeFormatter

+ (instancetype)sharedFormatter {
    static QXTimeFormatter *f = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        f = [QXTimeFormatter new];
    });
    return f;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _calendar = [NSCalendar currentCalendar];
        _iso8601  = [NSDateFormatter new];
        _iso8601.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
        _iso8601.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];

        _hhmm = [NSDateFormatter new];
        _hhmm.dateFormat = @"HH:mm";

        _mddhhmm = [NSDateFormatter new];
        _mddhhmm.dateFormat = @"MM-dd HH:mm";

        _yyyymddhhmm = [NSDateFormatter new];
        _yyyymddhhmm.dateFormat = @"yyyy-MM-dd HH:mm";

        _weekday = [NSDateFormatter new];
        _weekday.dateFormat = @"EEEE";
    }
    return self;
}

- (NSString *)conversationListStringFromTimestamp:(NSTimeInterval)timestamp {
    if (timestamp <= 0) {
        return @"";
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDate *now  = [NSDate date];

    NSDateComponents *dc = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                            fromDate:date];
    NSDateComponents *nc = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                            fromDate:now];
    if (dc.year == nc.year && dc.month == nc.month && dc.day == nc.day) {
        return [self.hhmm stringFromDate:date];
    }
    NSDate *yesterday = [self.calendar dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:now options:0];
    NSDateComponents *yc = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                            fromDate:yesterday];
    if (dc.year == yc.year && dc.month == yc.month && dc.day == yc.day) {
        return @"昨天";
    }
    NSDateComponents *diff = [self.calendar components:NSCalendarUnitDay
                                              fromDate:date toDate:now options:0];
    if (diff.day < 7) {
        return [self.weekday stringFromDate:date];
    }
    if (dc.year == nc.year) {
        return [self.mddhhmm stringFromDate:date];
    }
    return [self.yyyymddhhmm stringFromDate:date];
}

- (NSString *)messageBucketStringFromTimestamp:(NSTimeInterval)timestamp {
    if (timestamp <= 0) {
        return @"";
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDate *now  = [NSDate date];
    NSTimeInterval delta = [now timeIntervalSinceDate:date];
    if (delta < 60) {
        return @"刚刚";
    }
    if (delta < 60 * 5) {
        return [NSString stringWithFormat:@"%d 分钟前", (int)(delta / 60)];
    }
    return [self conversationListStringFromTimestamp:timestamp];
}

- (QXTimeBucket)bucketFromTimestamp:(NSTimeInterval)timestamp {
    if (timestamp <= 0) {
        return QXTimeBucketEarlier;
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSTimeInterval delta = [[NSDate date] timeIntervalSinceDate:date];
    if (delta < 60)               return QXTimeBucketJustNow;
    if (delta < 60 * 60)          return QXTimeBucketMinutesAgo;
    if (delta < 60 * 60 * 24)     return QXTimeBucketHoursAgo;
    if (delta < 60 * 60 * 24 * 2) return QXTimeBucketYesterday;
    if (delta < 60 * 60 * 24 * 7) return QXTimeBucketThisWeek;
    if (delta < 60 * 60 * 24 * 365) return QXTimeBucketThisYear;
    return QXTimeBucketEarlier;
}

- (NSString *)iso8601StringFromTimestamp:(NSTimeInterval)timestamp {
    if (timestamp <= 0) {
        return @"";
    }
    return [self.iso8601 stringFromDate:[NSDate dateWithTimeIntervalSince1970:timestamp]];
}

- (NSString *)durationStringFromSeconds:(NSTimeInterval)seconds {
    if (seconds < 0) seconds = 0;
    NSInteger total = (NSInteger)seconds;
    NSInteger h = total / 3600;
    NSInteger m = (total % 3600) / 60;
    NSInteger s = total % 60;
    if (h > 0) {
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)h, (long)m, (long)s];
    }
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)m, (long)s];
}

@end
