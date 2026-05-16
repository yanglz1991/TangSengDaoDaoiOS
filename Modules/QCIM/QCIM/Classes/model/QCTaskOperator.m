//
//  QCTaskOperator.m
//  QCIM
//
//  Created by tt on 2021/4/22.
//

#import "QCTaskOperator.h"

@implementation QCTaskOperator

+(QCTaskOperator*) cancel:(void(^)(void))cancel suspend:(void(^)(void))suspend resume:(void(^)(void))resume {
    QCTaskOperator *operator = [QCTaskOperator new];
    operator.cancel = cancel;
    operator.suspend = suspend;
    operator.resume = resume;
    return operator;
    
}

@end
