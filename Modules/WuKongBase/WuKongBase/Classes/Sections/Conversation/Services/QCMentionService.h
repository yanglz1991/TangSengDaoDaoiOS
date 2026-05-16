//
//  QCMentionService.h
//  WuKongBase
//
//  Created by tt on 2020/7/16.
//

#import <Foundation/Foundation.h>
#import "QCMatchToken.h"
#import <WuKongIMSDK/WuKongIMSDK.h>
NS_ASSUME_NONNULL_BEGIN


@interface QCMentionService : NSObject

+ (QCMentionService *)shared;

/**
 替换字符串的@占位符
 
 @param str 需要替换的字符串
 @return 返回替换好的字符串
 */
-(NSArray<id<QCMatchToken>>*)parseMention:(NSString *)str mentionInfo:(QCMentionedInfo * __nullable)mentionInfo;
@end

NS_ASSUME_NONNULL_END
