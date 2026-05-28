//
//  QXReadingPreferences.h
//  QCCore
//
//  喜聊阅读偏好。集中管理消息字号、行距、气泡圆角、消息密度。
//  支持动态广播变更，让所有 cell 实时刷新。
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const QXReadingPreferencesDidChangeNotification;

typedef NS_ENUM(NSInteger, QXReadingDensity) {
    QXReadingDensityCompact   = 0,
    QXReadingDensityRegular   = 1,
    QXReadingDensityComfort   = 2,
    QXReadingDensitySpacious  = 3,
};

@interface QXReadingPreferences : NSObject

+ (instancetype)sharedPreferences;

@property (nonatomic, assign) CGFloat fontScale;       // 0.85 ~ 1.4
@property (nonatomic, assign) CGFloat lineSpacing;     // 0 ~ 8 pt
@property (nonatomic, assign) CGFloat bubbleCornerRadius;
@property (nonatomic, assign) QXReadingDensity density;
@property (nonatomic, assign) BOOL    monoTimestamps;
@property (nonatomic, assign) BOOL    boldNicknames;

- (UIFont *)scaledFontFromBaseSize:(CGFloat)baseSize;
- (UIFont *)scaledFontFromBaseSize:(CGFloat)baseSize weight:(UIFontWeight)weight;

- (void)resetToDefaults;
- (NSDictionary<NSString *, id> *)snapshot;

@end

NS_ASSUME_NONNULL_END
