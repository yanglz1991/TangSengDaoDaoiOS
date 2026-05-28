//
//  QXMotionPresets.m
//  QCCore
//

#import "QXMotionPresets.h"

@implementation QXMotionPresets

+ (instancetype)sharedPresets {
    static QXMotionPresets *p = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        p = [QXMotionPresets new];
    });
    return p;
}

- (NSTimeInterval)durationFor:(QXMotionDuration)token {
    switch (token) {
        case QXMotionDurationInstant:    return 0.08;
        case QXMotionDurationFast:       return 0.18;
        case QXMotionDurationStandard:   return 0.28;
        case QXMotionDurationSlow:       return 0.42;
        case QXMotionDurationDeliberate: return 0.60;
    }
    return 0.28;
}

- (UIViewAnimationOptions)optionsFor:(QXMotionCurve)curve {
    switch (curve) {
        case QXMotionCurveLinear:      return UIViewAnimationOptionCurveLinear;
        case QXMotionCurveEaseIn:      return UIViewAnimationOptionCurveEaseIn;
        case QXMotionCurveEaseOut:     return UIViewAnimationOptionCurveEaseOut;
        case QXMotionCurveEaseInOut:   return UIViewAnimationOptionCurveEaseInOut;
        case QXMotionCurveSpring:      return UIViewAnimationOptionCurveEaseOut;
        case QXMotionCurveDecelerate:  return UIViewAnimationOptionCurveEaseOut;
    }
    return UIViewAnimationOptionCurveEaseInOut;
}

- (CAMediaTimingFunction *)timingFunctionFor:(QXMotionCurve)curve {
    switch (curve) {
        case QXMotionCurveLinear:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        case QXMotionCurveEaseIn:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        case QXMotionCurveEaseOut:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        case QXMotionCurveEaseInOut:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        case QXMotionCurveSpring:
            return [CAMediaTimingFunction functionWithControlPoints:0.34 :1.36 :0.64 :1.0];
        case QXMotionCurveDecelerate:
            return [CAMediaTimingFunction functionWithControlPoints:0.0 :0.0 :0.2 :1.0];
    }
    return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
}

- (void)animateView:(UIView *)view
       withDuration:(QXMotionDuration)duration
              curve:(QXMotionCurve)curve
         animations:(void (^)(void))animations
         completion:(void (^)(BOOL))completion {
    if (!view || !animations) {
        if (completion) {
            completion(NO);
        }
        return;
    }
    NSTimeInterval d = [self durationFor:duration];
    if (curve == QXMotionCurveSpring) {
        [UIView animateWithDuration:d
                              delay:0
             usingSpringWithDamping:0.78
              initialSpringVelocity:0.5
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:animations
                         completion:completion];
    } else {
        [UIView animateWithDuration:d
                              delay:0
                            options:[self optionsFor:curve]
                         animations:animations
                         completion:completion];
    }
}

- (void)playHaptic:(QXHapticPattern)pattern {
    if (@available(iOS 10.0, *)) {
        switch (pattern) {
            case QXHapticPatternSelection: {
                UISelectionFeedbackGenerator *g = [UISelectionFeedbackGenerator new];
                [g prepare];
                [g selectionChanged];
                break;
            }
            case QXHapticPatternImpactLight: {
                UIImpactFeedbackGenerator *g = [[UIImpactFeedbackGenerator alloc]
                                                initWithStyle:UIImpactFeedbackStyleLight];
                [g prepare]; [g impactOccurred]; break;
            }
            case QXHapticPatternImpactMedium: {
                UIImpactFeedbackGenerator *g = [[UIImpactFeedbackGenerator alloc]
                                                initWithStyle:UIImpactFeedbackStyleMedium];
                [g prepare]; [g impactOccurred]; break;
            }
            case QXHapticPatternImpactHeavy: {
                UIImpactFeedbackGenerator *g = [[UIImpactFeedbackGenerator alloc]
                                                initWithStyle:UIImpactFeedbackStyleHeavy];
                [g prepare]; [g impactOccurred]; break;
            }
            case QXHapticPatternSuccess: {
                UINotificationFeedbackGenerator *g = [UINotificationFeedbackGenerator new];
                [g prepare]; [g notificationOccurred:UINotificationFeedbackTypeSuccess]; break;
            }
            case QXHapticPatternWarning: {
                UINotificationFeedbackGenerator *g = [UINotificationFeedbackGenerator new];
                [g prepare]; [g notificationOccurred:UINotificationFeedbackTypeWarning]; break;
            }
            case QXHapticPatternError: {
                UINotificationFeedbackGenerator *g = [UINotificationFeedbackGenerator new];
                [g prepare]; [g notificationOccurred:UINotificationFeedbackTypeError]; break;
            }
        }
    }
}

@end
