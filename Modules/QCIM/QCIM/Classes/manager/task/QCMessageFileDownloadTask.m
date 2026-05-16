//
//  QCMessageFileDownloadTask.m
//  QCIMBase
//
//  Created by tt on 2020/1/16.
//

#import "QCMessageFileDownloadTask.h"

@implementation QCMessageFileDownloadTask

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
