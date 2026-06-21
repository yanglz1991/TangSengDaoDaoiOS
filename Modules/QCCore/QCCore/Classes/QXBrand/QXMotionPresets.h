//
//  QXMotionPresets.h
//  QCCore
//
//  禧语动效预设。集中提供 spring/timing 动画曲线、过渡时长、
//  反馈震动等参数，确保全 App 动效一致。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, QXMotionDuration) {
    QXMotionDurationInstant = 0,    // 0.08s
    QXMotionDurationFast    = 1,    // 0.18s
    QXMotionDurationStandard= 2,    // 0.28s
    QXMotionDurationSlow    = 3,    // 0.42s
    QXMotionDurationDeliberate = 4, // 0.6s
};

typedef NS_ENUM(NSInteger, QXMotionCurve) {
    QXMotionCurveLinear      = 0,
    QXMotionCurveEaseIn      = 1,
    QXMotionCurveEaseOut     = 2,
    QXMotionCurveEaseInOut   = 3,
    QXMotionCurveSpring      = 4,
    QXMotionCurveDecelerate  = 5,
};

typedef NS_ENUM(NSInteger, QXHapticPattern) {
    QXHapticPatternSelection = 0,
    QXHapticPatternImpactLight,
    QXHapticPatternImpactMedium,
    QXHapticPatternImpactHeavy,
    QXHapticPatternSuccess,
    QXHapticPatternWarning,
    QXHapticPatternError,
};

@interface QXMotionPresets : NSObject

+ (instancetype)sharedPresets;

- (NSTimeInterval)durationFor:(QXMotionDuration)token;
- (UIViewAnimationOptions)optionsFor:(QXMotionCurve)curve;
- (CAMediaTimingFunction *)timingFunctionFor:(QXMotionCurve)curve;

- (void)animateView:(UIView *)view
       withDuration:(QXMotionDuration)duration
              curve:(QXMotionCurve)curve
         animations:(void (^)(void))animations
         completion:(nullable void (^)(BOOL finished))completion;

- (void)playHaptic:(QXHapticPattern)pattern;

@end

NS_ASSUME_NONNULL_END
