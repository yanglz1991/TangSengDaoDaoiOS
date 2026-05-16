//
//  QCWebViewService.h
//  WuKongBase
//
//  Created by tt on 2023/9/11.
//

#import <Foundation/Foundation.h>
#import <WuKongIMSDK/WuKongIMSDK.h>
NS_ASSUME_NONNULL_BEGIN

@class QCWebViewJavascriptBridge;

@interface QCWebViewService : NSObject

@property (nonatomic, strong) QCWebViewJavascriptBridge *bridge;
@property(nonatomic,strong,nullable) QCChannel *channel;

-(void) registerHandlers;

@end

NS_ASSUME_NONNULL_END
