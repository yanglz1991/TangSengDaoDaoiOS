//
//  QCEndpoint.m
//  QCCore
//
//  Created by tt on 2019/12/1.
//

#import "QCEndpoint.h"

@implementation QCEndpoint

+(QCEndpoint*) initWithSid:(NSString*)sid handler:(id)handler category:(NSString* __nullable)category sort:(NSNumber* __nullable)sort {
    QCEndpoint *point = [[QCEndpoint alloc] init];
    point.sid = sid;
    point.handler = handler;
    point.category = category;
    point.sort = sort;
    return point;
}
+(QCEndpoint*) initWithSid:(NSString*)sid handler:(id)handler category:(NSString *)category {
    return [self initWithSid:sid handler:handler category:category sort:nil];
}

+(QCEndpoint*) initWithSid:(NSString*)sid handler:(id)handler {
    return [self initWithSid:sid handler:handler category:nil];
}

@end
