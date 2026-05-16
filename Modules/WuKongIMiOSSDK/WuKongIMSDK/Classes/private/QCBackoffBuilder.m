//
//  QCBackoffBuilder.m
//  WuKongIMSDK
//
//  Created by tt on 2019/11/30.
//

#import "QCBackoffBuilder.h"

@interface QCBackoffBuilder ()
@end

@implementation QCBackoffBuilder

+ (instancetype)builderWithBlock:(QCBackoffBuilderBlock)block; {
    return [[self alloc] initWithBlock:block];
}

- (id)initWithBlock:(QCBackoffBuilderBlock)block; {
    NSParameterAssert(block);
    
    self = [super init];
    if (self) {
        _base = 100;
        _factor = 2;
        _jitter = 0;
        _cap = LONG_MAX;
        block(self);
    }
    
    return self;
}

@end
