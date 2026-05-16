//
//  QCScanHandler.h
//  WuKongBase
//
//  Created by tt on 2020/4/3.
//

#import <Foundation/Foundation.h>
#import "QCModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCScanResult : QCModel

@property(nonatomic,copy) NSString *forward; // 扫码类型

@property(nonatomic,copy) NSString *type; // 扫码类型

@property(nonatomic,strong) NSDictionary *data; // 扫码数据

@end

@interface QCScanHandler : NSObject

+(QCScanHandler*) handle:(BOOL(^)(QCScanResult *result,void(^reScanBlock)(void)))callback;

-(BOOL) handle:(QCScanResult*)result reScan:(void(^)(void))reScanBlock;

@end

NS_ASSUME_NONNULL_END
