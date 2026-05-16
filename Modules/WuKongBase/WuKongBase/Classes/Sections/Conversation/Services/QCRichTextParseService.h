//
//  QCRichTextParseService.h
//  WuKongBase
//
//  Created by tt on 2021/7/27.
//

#import <Foundation/Foundation.h>
#import "QCMatchToken.h"
#import <WuKongIMSDK/WuKongIMSDK.h>
NS_ASSUME_NONNULL_BEGIN

@interface QCRichTextParseOptions : NSObject

@property(nonatomic,assign) BOOL disableLink; // 禁止解析链接

@end

@interface QCRichTextParseService : NSObject

+ (QCRichTextParseService *)shared;

-(NSArray<id<QCMatchToken>>*) parse:(NSString*)text mentionInfo:(QCMentionedInfo* __nullable)mentionInfo options:(QCRichTextParseOptions* __nullable)options;

// 链接解析
-(NSArray<id<QCMatchToken>>*) parseLink:(NSString*)text;
@end

NS_ASSUME_NONNULL_END
