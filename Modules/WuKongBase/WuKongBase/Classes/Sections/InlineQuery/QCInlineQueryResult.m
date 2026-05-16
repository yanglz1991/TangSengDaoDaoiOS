//
//  QCInlineQueryResult.m
//  WuKongBase
//
//  Created by tt on 2021/11/9.
//

#import "QCInlineQueryResult.h"

@implementation QCInlineQueryResult

+ (QCModel *)fromMap:(NSDictionary *)dictory type:(ModelMapType)type {
    QCInlineQueryResult *result = [QCInlineQueryResult new];
    result.type = dictory[@"type"]?:@"";
    result.id = dictory[@"id"]?:@"";
    result.inlineQuerySid = dictory[@"inline_query_sid"];
    result.nextOffset = dictory[@"next_offset"]?:@"";
    if([result.type isEqualToString:@"gif"]) {
        
        if(dictory[@"results"]) {
            NSMutableArray *newResults = [NSMutableArray array];
            for (NSDictionary *resultDict in dictory[@"results"]) {
                QCGifResult *gifResult = (QCGifResult*)[QCGifResult fromMap:resultDict type:type];
                [newResults addObject:gifResult];
            }
            result.results = newResults;
        }
    }
    return result;
}

@end

@implementation QCGifResult

+ (QCModel *)fromMap:(NSDictionary *)dictory type:(ModelMapType)type {
    QCGifResult *result = [QCGifResult new];
    result.url = dictory[@"url"]?:@"";
    result.width = dictory[@"width"]?[dictory[@"width"] integerValue]:270;
    result.height = dictory[@"height"]?[dictory[@"height"] integerValue]:270;
    return result;
}

@end
