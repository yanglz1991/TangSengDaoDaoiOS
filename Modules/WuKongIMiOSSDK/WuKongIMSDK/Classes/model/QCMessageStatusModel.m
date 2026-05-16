//
//  QCMessageStatusModel.m
//  WuKongIMBase
//
//  Created by tt on 2019/12/29.
//

#import "QCMessageStatusModel.h"

@implementation QCMessageStatusModel

-(instancetype) initWithClientSeq:(uint32_t)clientSeq status:(QCMessageStatus)status {
    self = [super init];
    if(self) {
        self.clientSeq = clientSeq;
        self.status = status;
    }
    return self;
}

@end
