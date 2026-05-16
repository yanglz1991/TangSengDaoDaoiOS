//
//  QCBaseTask.h
//  QCIM
//
//  Created by tt on 2020/1/16.
//

#import <Foundation/Foundation.h>
#import "QCTaskProto.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCBaseTask : NSObject<QCTaskProto>

/**
 错误 如果任务下载失败，则有值
 */
@property(nullable,nonatomic,strong) NSError *error;

/**
 下载进度
 */
@property(nonatomic,assign) CGFloat progress;

@end

NS_ASSUME_NONNULL_END
