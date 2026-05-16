//
//  QCMentionService.m
//  QCCore
//
//  Created by tt on 2020/7/16.
//

#import "QCMentionService.h"



@implementation QCMentionService
static QCMentionService *_instance;
+ (QCMentionService *)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        
    });
    return _instance;
}

-(NSArray<id<QCMatchToken>>*)parseMention:(NSString *)str mentionInfo:(QCMentionedInfo *)mentionInfo{
    static NSRegularExpression *atExp; // @正则表达式
    if(!atExp) {
        atExp = [NSRegularExpression regularExpressionWithPattern:@"@\\S+\\b"
        options:NSRegularExpressionCaseInsensitive
          error:nil];
    }
     __block NSInteger index = 0;
     __block NSInteger mentionIndex = 0;
      NSMutableArray<id<QCMatchToken>> *tokens = [NSMutableArray array];
    [atExp enumerateMatchesInString:str
       options:0
         range:NSMakeRange(0, [str length])
    usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        if (result.range.location > index){
            NSRange rawRange = NSMakeRange(index, result.range.location - index);
            NSString *rawText = [str substringWithRange:rawRange];
            
            [tokens addObject:[QCDefaultToken text:rawText range:rawRange type:WKatchTokenTypeText]];
        }
        NSString *atUID;
        if(mentionInfo && mentionInfo.uids && mentionInfo.uids.count>mentionIndex) {
            atUID = mentionInfo.uids[mentionIndex];
        }
        NSString *rangeText = [str substringWithRange:result.range];
        if(atUID) {
           
            QCMetionToken *token = [QCMetionToken new];
            token.text = rangeText;
            token.range = result.range;
            token.index = mentionIndex;
            token.uid = atUID;
            [tokens addObject:token];
            mentionIndex++;
        }else {
            [tokens addObject:[QCDefaultToken text:rangeText range:result.range type:WKatchTokenTypeText]];
        }
      
        index = result.range.location + result.range.length;
    }];
    if (index < [str length])
    {
        NSRange range = NSMakeRange(index, [str length] - index);
        NSString *rawText = [str substringWithRange:range];
        [tokens addObject:[QCDefaultToken text:rawText range:range type:WKatchTokenTypeText]];
    }
    return tokens;
}
@end
