//
//  QCCore.h
//  QCCore
//
//  Created by tt on 2019/12/1.
//

#import <Foundation/Foundation.h>
#import "QCEndpoint.h"
#import "QCEndpointManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCCore : NSObject

/**
 注册端点
 @param endpoint 端点对象
 */
-(void) registerEndpoint:(QCEndpoint*)endpoint;

@end

NS_ASSUME_NONNULL_END
