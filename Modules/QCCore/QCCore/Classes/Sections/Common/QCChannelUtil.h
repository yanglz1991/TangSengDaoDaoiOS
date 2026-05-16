//
//  QCChannelUtil.h
//  QCCore
//
//  Created by tt on 2021/8/4.
//

#import <Foundation/Foundation.h>
#import <QCIM/QCIM.h>
#import "QCConstant.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCChannelUtil : NSObject

+ (QCChannelInfo *)toChannelInfo2:(NSDictionary*)resultDict;

+(QCChannelInfo*) toChannelInfo:(NSDictionary*)channelDic;

+(QCGroupType) groupType:(QCChannelInfo*)channelInfo;

@end

NS_ASSUME_NONNULL_END
