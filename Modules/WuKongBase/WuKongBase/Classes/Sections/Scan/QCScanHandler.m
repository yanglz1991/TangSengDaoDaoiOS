//
//  QCScanHandler.m
//  WuKongBase
//
//  Created by tt on 2020/4/3.
//

#import "QCScanHandler.h"

@implementation QCScanResult

+ (QCModel *)fromMap:(NSDictionary *)dictory type:(ModelMapType)type {
    QCScanResult *result = [QCScanResult new];
    result.forward = dictory[@"forward"];
    result.type = dictory[@"type"];
    result.data = dictory[@"data"];
    return result;
}

@end

@interface QCScanHandler ()

@property(nonatomic,copy) BOOL(^scanHandleCallback)(QCScanResult *result,void(^reScanBlock)(void));


@end

@implementation QCScanHandler

+(QCScanHandler*) handle:(BOOL(^)(QCScanResult *result,void(^reScanBlock)(void)))callback{
    QCScanHandler *handler = [QCScanHandler new];
    handler.scanHandleCallback = callback;
    return handler;
}

-(BOOL) handle:(QCScanResult*)result reScan:(void(^)(void))reScanBlock {
    if(self.scanHandleCallback) {
        return self.scanHandleCallback(result,reScanBlock);
    }
    return false;
}
@end
