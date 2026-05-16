//
//  QCChatDataProvider.h
//  Pods
//
//  Created by tt on 2022/5/27.
//
#import "QCSyncChannelMessageModel.h"
#ifndef QCChatDataProvider_h
#define QCChatDataProvider_h


#endif /* QCChatDataProvider_h */


NS_ASSUME_NONNULL_BEGIN
// 同步频道消息
typedef void(^QCSyncChannelMessageCallback)(QCSyncChannelMessageModel* __nullable syncChannelMessageModel,NSError * __nullable error);
typedef void (^QCSyncChannelMessageProvider)(QCChannel *channel,uint32_t startMessageSeq,uint32_t endMessageSeq,NSInteger limit,QCPullMode pullMode,QCSyncChannelMessageCallback callback);

// 扩展消息
typedef void(^QCSyncMessageExtraCallback)(NSArray<QCMessageExtra*>* __nullable results,NSError * __nullable error);
typedef void(^QCSyncMessageExtraProvider)(QCChannel *channel,long long extraVersion,NSInteger limit,QCSyncMessageExtraCallback callback);
typedef void(^QCUpdateMessageExtraCallback)(NSError *error);
typedef void(^QCUpdateMessageExtraProvider) (QCMessageExtra *newExtra,QCMessageExtra *oldExtra,QCUpdateMessageExtraCallback callback);

// 消息编辑
typedef void(^QCMessageEditCallback)(NSError * __nullable error);
typedef void(^QCMessageEditProvider)(QCMessageExtra *extra,QCMessageEditCallback callback);

NS_ASSUME_NONNULL_END
