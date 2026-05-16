//
//  QCRTCIceServer.m
//  WuKongBase
//
//  Created by tt on 2023/12/18.
//

#import "QCRTCIceServer.h"

@interface QCRTCIceServer ()



@end

@implementation QCRTCIceServer

- (instancetype)initWithURLStrings:(NSArray<NSString *> *)urlStrings
                          username:(nullable NSString *)username
                        credential:(nullable NSString *)credential {
    self = [super init];
    if(self) {
        self.urlStrings = urlStrings;
        self.username = username;
        self.credential = credential;
    }
    return self;
}

- (instancetype)initWithURLStrings:(NSArray<NSString *> *)urlStrings {
    self = [super init];
    if(self) {
        self.urlStrings = urlStrings;
    }
    return self;
}

@end
