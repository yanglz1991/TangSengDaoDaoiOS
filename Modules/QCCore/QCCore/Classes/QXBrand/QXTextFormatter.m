//
//  QXTextFormatter.m
//  QCCore
//

#import "QXTextFormatter.h"

@implementation QXTextFormatter

+ (instancetype)sharedFormatter {
    static QXTextFormatter *f = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        f = [QXTextFormatter new];
    });
    return f;
}

- (NSString *)maskedText:(NSString *)text
                keepHead:(NSUInteger)keepHead
                keepTail:(NSUInteger)keepTail
                  symbol:(NSString *)symbol {
    if (text.length == 0) {
        return @"";
    }
    NSString *sym = symbol.length == 0 ? @"*" : symbol;
    NSUInteger len = text.length;
    if (keepHead + keepTail >= len) {
        return text;
    }
    NSString *head = [text substringToIndex:keepHead];
    NSString *tail = [text substringFromIndex:len - keepTail];
    NSUInteger dotCount = len - keepHead - keepTail;
    NSMutableString *dots = [NSMutableString stringWithCapacity:dotCount];
    for (NSUInteger i = 0; i < dotCount; i++) {
        [dots appendString:sym];
    }
    return [NSString stringWithFormat:@"%@%@%@", head, dots, tail];
}

- (NSString *)maskedPhone:(NSString *)phone {
    NSString *trim = [phone stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trim.length < 7) {
        return trim ?: @"";
    }
    return [self maskedText:trim keepHead:3 keepTail:4 symbol:@"*"];
}

- (NSString *)maskedEmail:(NSString *)email {
    NSRange at = [email rangeOfString:@"@"];
    if (at.location == NSNotFound || email.length == 0) {
        return email ?: @"";
    }
    NSString *local  = [email substringToIndex:at.location];
    NSString *domain = [email substringFromIndex:at.location];
    if (local.length <= 1) {
        return [NSString stringWithFormat:@"%@%@", local, domain];
    }
    NSString *masked = [self maskedText:local keepHead:1 keepTail:0 symbol:@"*"];
    return [NSString stringWithFormat:@"%@%@", masked, domain];
}

- (NSString *)maskedIDCard:(NSString *)idCard {
    if (idCard.length < 8) {
        return idCard ?: @"";
    }
    return [self maskedText:idCard keepHead:4 keepTail:4 symbol:@"*"];
}

- (NSString *)truncateText:(NSString *)text toMaxDisplayWidth:(CGFloat)width {
    if (text.length == 0 || width <= 0) {
        return @"";
    }
    NSDictionary *attrs = @{NSFontAttributeName: [UIFont systemFontOfSize:14]};
    CGSize size = [text sizeWithAttributes:attrs];
    if (size.width <= width) {
        return text;
    }
    NSUInteger lo = 0, hi = text.length;
    while (lo + 1 < hi) {
        NSUInteger mid = (lo + hi) / 2;
        NSString *prefix = [text substringToIndex:mid];
        NSString *probe  = [prefix stringByAppendingString:@"…"];
        CGSize probeSize = [probe sizeWithAttributes:attrs];
        if (probeSize.width <= width) {
            lo = mid;
        } else {
            hi = mid;
        }
    }
    return [[text substringToIndex:lo] stringByAppendingString:@"…"];
}

- (NSString *)normalizeURL:(NSString *)urlString {
    NSString *trim = [urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trim.length == 0) {
        return @"";
    }
    if (![trim hasPrefix:@"http://"] && ![trim hasPrefix:@"https://"]) {
        trim = [@"https://" stringByAppendingString:trim];
    }
    NSURLComponents *comps = [NSURLComponents componentsWithString:trim];
    if (!comps) {
        return trim;
    }
    NSArray<NSURLQueryItem *> *items = comps.queryItems;
    if (items.count > 0) {
        NSMutableArray<NSURLQueryItem *> *kept = [NSMutableArray array];
        for (NSURLQueryItem *it in items) {
            if (![it.name hasPrefix:@"utm_"] && ![it.name isEqualToString:@"fbclid"]) {
                [kept addObject:it];
            }
        }
        comps.queryItems = kept.count > 0 ? kept : nil;
    }
    return comps.URL.absoluteString ?: trim;
}

- (NSString *)redactSensitiveWords:(NSString *)text words:(NSArray<NSString *> *)words {
    if (text.length == 0 || words.count == 0) {
        return text ?: @"";
    }
    NSMutableString *out = [text mutableCopy];
    for (NSString *w in words) {
        if (w.length == 0) continue;
        NSString *replacement = [@"" stringByPaddingToLength:w.length withString:@"*" startingAtIndex:0];
        [out replaceOccurrencesOfString:w
                             withString:replacement
                                options:NSCaseInsensitiveSearch
                                  range:NSMakeRange(0, out.length)];
    }
    return [out copy];
}

@end
