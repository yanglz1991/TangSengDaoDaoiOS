//
//  QCInlineQueryManager.m
//  QCCore
//
//  Created by tt on 2021/11/9.
//

#import "QCInlineQueryManager.h"
#import "QCGifResultPanel.h"
@implementation QCInlineQueryManager

+ (instancetype)shared{
    static QCInlineQueryManager *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[QCInlineQueryManager alloc] init];
    });
    return _shared;
}

-(QCResultPanel*) createResultPanel:(QCInlineQueryResult*)result context:(id<QCConversationContext>)context{
    if([result.type isEqualToString:@"gif"]) {
        QCGifResultPanel *gifPanel = [QCGifResultPanel result:result context:context];
        return gifPanel;
    }
    return nil;
}

@end
