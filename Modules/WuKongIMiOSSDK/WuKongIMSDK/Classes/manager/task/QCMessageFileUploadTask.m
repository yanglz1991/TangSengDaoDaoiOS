//
//  QCMessageFileUploadTask.m
//  WuKongIMSDK
//
//  Created by tt on 2020/1/15.
//

#import "QCMessageFileUploadTask.h"

@implementation QCMessageFileUploadTask

-(instancetype) initWithMessage:(QCMessage*)message; {
    self = [super init];
    if(self) {
        self.message = message;
    }
    return self;
}

- (NSString *)taskId {
   return  [NSString stringWithFormat:@"%u",self.message.clientSeq];
}


@end
