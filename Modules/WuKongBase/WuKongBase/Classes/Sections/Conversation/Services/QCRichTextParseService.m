//
//  QCRichTextParseService.m
//  WuKongBase
//
//  Created by tt on 2021/7/27.
//

#import "QCRichTextParseService.h"
#import "QCEmoticonService.h"
#import "QCMentionService.h"

@implementation QCRichTextParseOptions



@end

@implementation QCRichTextParseService

static QCRichTextParseService *_instance;
+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
+ (QCRichTextParseService *)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        
    });
    return _instance;
}

-(NSArray<id<QCMatchToken>>*) parse:(NSString*)text mentionInfo:(QCMentionedInfo*)mentionInfo options:(QCRichTextParseOptions*)options{
    NSMutableArray<id<QCMatchToken>> *tokens = [NSMutableArray array];
    NSArray<id<QCMatchToken>> *linkTokens;
    if(options && options.disableLink) {
        linkTokens = @[ [QCDefaultToken text:text range:NSMakeRange(0, text.length) type:WKatchTokenTypeText]];
    }else{
        linkTokens =  [self parseLink:text];
    }
    if(linkTokens && linkTokens.count>0) {
        for (id<QCMatchToken> matchToken in linkTokens) {
            if(matchToken.type == WKatchTokenTypeLink) {
                [tokens addObject:matchToken];
            }else {
                NSArray<id<QCMatchToken>> *emojiTokens = [[QCEmoticonService shared] parseEmotion:matchToken.text];
                for(id<QCMatchToken> token in emojiTokens){
                    if (token.type == WKatchTokenTypeEmoji){
                        [tokens addObject:token];
                    }else  {
                        if(mentionInfo) {
                            NSArray<id<QCMatchToken>> *mentions = [[QCMentionService shared] parseMention:token.text mentionInfo:mentionInfo];
                            if(mentions && mentions.count>0) {
                                [tokens addObjectsFromArray:mentions];
                            }
                        }else{
                            [tokens addObject:token];
                        }
                    }
                }
            }
        }
    }
    return tokens;
}

-(NSArray<id<QCMatchToken>>*) parseLink:(NSString*)text {
    NSDataDetector *detector = [self linkDetector];
    NSMutableArray *links = [NSMutableArray array];
    __block NSInteger index = 0;
    [detector enumerateMatchesInString:text
                               options:0
                                 range:NSMakeRange(0, [text length])
                            usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        NSRange range = result.range;
        if (range.location > index){
            NSRange rawRange = NSMakeRange(index, result.range.location - index);
            NSString *rawText = [text substringWithRange:rawRange];
            [links addObject:[QCDefaultToken text:rawText range:rawRange type:WKatchTokenTypeText]];
        }
        NSString *lk = [text substringWithRange:range];
        [links addObject: [QCDefaultToken text:lk range:range type:WKatchTokenTypeLink]];
        index = result.range.location + result.range.length;
    }];
    if (index < [text length])
    {
        NSRange range = NSMakeRange(index, [text length] - index);
        NSString *rawText = [text substringWithRange:range];
        [links addObject:[QCDefaultToken text:rawText range:range type:WKatchTokenTypeText]];
    }
    return links;
}

- (NSDataDetector *)linkDetector
{
    static NSString *QCLinkDetectorKey = @"QCLinkDetectorKey";
    
    NSMutableDictionary *dict = [[NSThread currentThread] threadDictionary];
    NSDataDetector *detector = dict[QCLinkDetectorKey];
    if (detector == nil)
    {
        detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink | NSTextCheckingTypePhoneNumber
                                                   error:nil];
        if (detector)
        {
            dict[QCLinkDetectorKey] = detector;
        }
    }
    return detector;
}


@end
