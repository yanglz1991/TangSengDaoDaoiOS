//
//  QCBaseModule.h
//  QCCore
//
//  Created by tt on 2019/12/1.
//

#import <Foundation/Foundation.h>
#import "QCModuleProtocol.h"
#import "QCEndpoint.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCBaseModule : NSObject<QCModuleProtocol>

+(NSString*) globalID;

-(void) setMethod:(NSString*)sid handler:(id) handler category:(NSString * __nullable)category;

-(void) setMethod:(NSString*)sid handler:(id) handler category:(NSString* __nullable)category sort:(int)sort;

-(void) setMethod:(NSString*)sid handler:(id) handler;

@end

NS_ASSUME_NONNULL_END
