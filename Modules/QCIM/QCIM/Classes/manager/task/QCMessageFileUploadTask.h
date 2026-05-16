//
//  QCMessageFileUploadTask.h
//  QCIM
//
//  Created by tt on 2020/1/15.
//

#import <Foundation/Foundation.h>
#import "QCTaskProto.h"
#import "QCMessage.h"
#import "QCBaseTask.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCMessageFileUploadTask : QCBaseTask

-(instancetype) initWithMessage:(QCMessage*)message;

// 消息
@property(nonatomic,strong) QCMessage *message;


/**
 上传后返回的路径
 */
@property(nullable,nonatomic,strong) NSString *remoteUrl;




@end

NS_ASSUME_NONNULL_END
