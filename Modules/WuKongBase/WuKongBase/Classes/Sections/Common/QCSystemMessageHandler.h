//
//  QCSystemMessageHandler.h
//  WuKongBase
//
//  Created by tt on 2020/1/23.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface QCSystemMessageHandler : NSObject

+ (QCSystemMessageHandler *)shared;

-(void) handle;

// 踢出
- (void)onKick:(uint8_t)reasonCode reason:(NSString *)reason;

@end

NS_ASSUME_NONNULL_END
