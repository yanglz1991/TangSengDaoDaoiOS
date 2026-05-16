//
//  QCHistorySpliteTipContent.m
//  WuKongBase
//
//  Created by tt on 2020/10/8.
//

#import "QCHistorySplitTipContent.h"
#import "QCConstant.h"
@implementation QCHistorySplitTipContent


+(NSNumber*) contentType {
    return @(WK_HISTORY_SPLIT);
}

- (NSInteger)realContentType {
    return WK_HISTORY_SPLIT;
}


@end
