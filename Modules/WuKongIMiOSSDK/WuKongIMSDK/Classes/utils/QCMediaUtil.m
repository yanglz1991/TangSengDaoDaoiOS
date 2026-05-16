//
//  QCMediaUtils.m
//  WuKongIMSDK
//
//  Created by tt on 2020/1/13.
//

#import "QCMediaUtil.h"

@implementation QCMediaUtil

+(NSString*) getLocalPath:(id<QCMediaProto>)media {
   QCChannel *channel =  media.message.channel;
    return [NSString stringWithFormat:@"%@/%@%@",[self getChannelDir:channel],media.message.clientMsgNo,media.extension?:@""];
}

+(NSString*) getThumbLocalPath:(id<QCMediaProto>)media {
    QCChannel *channel =  media.message.channel;
    return [NSString stringWithFormat:@"%@/%@_thumb%@",[self getChannelDir:channel],media.message.clientMsgNo,media.thumbExtension?:@""];
}

+(NSString*) getChannelDir:(QCChannel*) channel {
    return [NSString stringWithFormat:@"%d/%@",channel.channelType,channel.channelId];
}
@end
