//
//  QCSchemaManager.h
//  WuKongBase
//
//  Created by tt on 2022/4/29.
//

#import <Foundation/Foundation.h>
@class QCSchemaRequest;
NS_ASSUME_NONNULL_BEGIN

typedef BOOL(^QCSchemaHandler)(QCSchemaRequest *request);

@interface QCSchemaRequest : NSObject

@property(nonatomic,strong) NSURL *url;

+(QCSchemaRequest*) url:(NSURL*)url;

-(BOOL) isAppSchema;

-(NSDictionary<NSString*,NSString*>*)queryItems;

@end

@interface QCSchemaManager : NSObject

+ (instancetype)shared;

-(void) registerHandler:(NSString*)sid handler:(QCSchemaHandler)handler;

-(void) handle:(QCSchemaRequest*)request;

-(void) handleURL:(NSURL*)url;

@end

NS_ASSUME_NONNULL_END
