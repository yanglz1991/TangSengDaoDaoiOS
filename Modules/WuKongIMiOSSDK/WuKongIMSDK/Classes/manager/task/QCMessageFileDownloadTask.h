//
//  QCMessageFileDownloadTask.h
//  WuKongIMBase
//
//  Created by tt on 2020/1/16.
//

#import <Foundation/Foundation.h>
#import "QCBaseTask.h"
#import "QCMessage.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCMessageFileDownloadTask : QCBaseTask
-(instancetype) initWithMessage:(QCMessage*)message;


// 消息
@property(nonatomic,strong) QCMessage *message;




@end

NS_ASSUME_NONNULL_END
