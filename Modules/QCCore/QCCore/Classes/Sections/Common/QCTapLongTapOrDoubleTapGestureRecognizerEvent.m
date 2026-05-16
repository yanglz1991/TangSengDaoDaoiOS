//
//  QCTapLongTapOrDoubleTapGestureRecognizerEvent.m
//  QCCore
//
//  Created by tt on 2022/6/21.
//

#import <Foundation/Foundation.h>

#import "QCTapLongTapOrDoubleTapGestureRecognizerEvent.h"

@implementation QCTapLongTapOrDoubleTapGestureRecognizerEvent

+ (instancetype)action:(QCTapLongTapOrDoubleTapGestureRecognizerAction)action {
    QCTapLongTapOrDoubleTapGestureRecognizerEvent *event = [[QCTapLongTapOrDoubleTapGestureRecognizerEvent alloc] init];
    event.action = action;
    return event;
}

@end
