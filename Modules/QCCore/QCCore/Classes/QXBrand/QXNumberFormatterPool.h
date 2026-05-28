//
//  QXNumberFormatterPool.h
//  QCCore
//
//  线程安全的 NSNumberFormatter 池，避免每次格式化重新构造。
//  支持百分比、千分位、紧凑数（如 1.2k / 3.4w）等常见样式。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, QXNumberStyle) {
    QXNumberStyleDecimal     = 0,
    QXNumberStylePercent      = 1,
    QXNumberStyleCurrencyCNY  = 2,
    QXNumberStyleCurrencyUSD  = 3,
    QXNumberStyleScientific   = 4,
    QXNumberStyleSpellout     = 5,
};

@interface QXNumberFormatterPool : NSObject

+ (instancetype)sharedPool;

- (NSString *)stringFromNumber:(NSNumber *)number style:(QXNumberStyle)style;
- (NSString *)compactStringFromNumber:(NSNumber *)number;
- (NSString *)compactCNStringFromNumber:(NSNumber *)number;
- (NSString *)thousandsSeparatedStringFromNumber:(NSNumber *)number;
- (NSString *)fileSizeStringFromBytes:(int64_t)bytes;

@end

NS_ASSUME_NONNULL_END
