//
//  QCSystemContent.h
//  WuKongIMSDK
//
//  Created by tt on 2020/1/4.
//

#import <Foundation/Foundation.h>
#import "QCMessageContent.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCSystemContent : QCMessageContent

@property(nonatomic,strong) NSDictionary *content;
@property(nonatomic,copy) NSString *displayContent;

@end

NS_ASSUME_NONNULL_END
