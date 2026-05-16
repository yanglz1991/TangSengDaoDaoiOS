//
//  QCBackoffBuilder.h
//  QCIM
//
//  Created by tt on 2019/11/30.
//

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>

/** Fluent API to construct instances of SEGBacko. */
@class QCBackoffBuilder;

typedef void(^QCBackoffBuilderBlock)(QCBackoffBuilder *builder);

@interface QCBackoffBuilder : NSObject

@property(nonatomic, readwrite) long base;
@property(nonatomic, readwrite) int factor;
@property(nonatomic, readwrite) double jitter;
@property(nonatomic, readwrite) long cap;

+ (instancetype)builderWithBlock:(QCBackoffBuilderBlock)block;

- (id)initWithBlock:(QCBackoffBuilderBlock)block NS_DESIGNATED_INITIALIZER;

@end
