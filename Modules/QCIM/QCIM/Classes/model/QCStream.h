//
//  QCStream.h
//  QCIM
//
//  Created by tt on 2023/7/3.
//

#import <Foundation/Foundation.h>
#import "QCChannel.h"
#import "QCMessageContent.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCStream : NSObject

@property(nonatomic,strong) QCChannel *channel;
@property(nonatomic,copy) NSString *clientMsgNo;
@property(nonatomic,copy) NSString *streamNo;
@property(nonatomic,assign) uint64_t streamSeq;

@property(nonatomic,strong) QCMessageContent *content; // 消息正文
@property(nonatomic,strong) NSData *contentData; // 消息正文data数据

@end

NS_ASSUME_NONNULL_END
