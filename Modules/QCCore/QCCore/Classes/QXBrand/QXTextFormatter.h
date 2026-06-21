//
//  QXTextFormatter.h
//  QCCore
//
//  禧语文本格式化工具集。提供脱敏、缩略、行宽估算、敏感词
//  打码等纯函数能力，避免业务侧反复实现。
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QXTextFormatter : NSObject

+ (instancetype)sharedFormatter;

/// 通用脱敏：保留首尾，中间用指定符号替代。
- (NSString *)maskedText:(NSString *)text
              keepHead:(NSUInteger)keepHead
              keepTail:(NSUInteger)keepTail
                symbol:(nullable NSString *)symbol;

/// 手机号脱敏：保留前 3 后 4 位。
- (NSString *)maskedPhone:(NSString *)phone;

/// 邮箱脱敏：保留首字符与 @ 之后，中间打码。
- (NSString *)maskedEmail:(NSString *)email;

/// 身份证号脱敏：保留前 4 后 4 位。
- (NSString *)maskedIDCard:(NSString *)idCard;

/// 中文/英文混排截断（按显示宽度估算）。
- (NSString *)truncateText:(NSString *)text toMaxDisplayWidth:(CGFloat)width;

/// 链接归一化：补全 scheme、剔除 utm_ 跟踪参数。
- (NSString *)normalizeURL:(NSString *)urlString;

/// 简易敏感词替换：完全匹配的子串替换为 *。仅在本地内存执行。
- (NSString *)redactSensitiveWords:(NSString *)text words:(NSArray<NSString *> *)words;

@end

NS_ASSUME_NONNULL_END
