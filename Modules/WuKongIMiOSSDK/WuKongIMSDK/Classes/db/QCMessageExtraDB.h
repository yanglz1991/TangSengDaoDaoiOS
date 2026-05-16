//
//  QCMessageExtraDB.h
//  WuKongIMSDK
//
//  Created by tt on 2022/4/12.
//

#import <Foundation/Foundation.h>
#import "QCMessageExtra.h"
#import "QCChannel.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCMessageExtraDB : NSObject

+ (QCMessageExtraDB *)shared;


-(void) addOrUpdateMessageExtras:(NSArray<QCMessageExtra*>*)messageExtras;

-(void) addOrUpdateMessageExtra:(QCMessageExtra*)messageExtra db:(FMDatabase*)db;


-(long long) getMessageExtraMaxVersion:(QCChannel*)channel;

// 添加或更新正文编辑的内容
-(void) addOrUpdateContentEdit:(QCMessageExtra*)messageExtra;

// 通过消息ID获取消息扩展
-(QCMessageExtra*) getMessageExtraWithMessageID:(uint64_t)messageID;

// 获取等待上传的正文编辑内容
-(NSArray<QCMessageExtra*>*) getContentEditWaitUpload;

// 更新正文上传状态为失败
-(void) updateContentEditUploadStatusToFailStatus;

// 更新消息状态
-(void) updateUploadStatus:(QCContentEditUploadStatus)status withMessageID:(uint64_t)messageID;

@end

NS_ASSUME_NONNULL_END
