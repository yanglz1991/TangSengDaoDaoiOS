//
//  TapLongTapOrDoubleTapGestureRecognizerAction.h
//  QCCore
//
//  Created by tt on 2022/6/21.
//

#import <Foundation/Foundation.h>


typedef enum : NSUInteger {
    QCTapLongTapOrDoubleTapGestureRecognizerActionNone,
    QCTapLongTapOrDoubleTapGestureRecognizerActionWaitForDoubleTap,
    QCTapLongTapOrDoubleTapGestureRecognizerActionWaitForSingleTap,
    QCTapLongTapOrDoubleTapGestureRecognizerActionFail,
    QCTapLongTapOrDoubleTapGestureRecognizerActionKeepWithSingleTap
} QCTapLongTapOrDoubleTapGestureRecognizerAction;

typedef enum : NSUInteger {
    QCTapLongTapOrDoubleTapGestureTap,
    QCTapLongTapOrDoubleTapGestureDoubleTap,
    QCTapLongTapOrDoubleTapGestureLongTap,
    QCTapLongTapOrDoubleTapGestureHold,
} QCTapLongTapOrDoubleTapGesture;


@interface QCTapLongTapOrDoubleTapGestureRecognizerEvent : NSObject

+(instancetype) action:(QCTapLongTapOrDoubleTapGestureRecognizerAction)action;

@property(nonatomic,assign) QCTapLongTapOrDoubleTapGestureRecognizerAction action;


@end
