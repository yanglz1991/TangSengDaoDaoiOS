//
//  QCMergeForwardDetailVM.m
//  QCCore
//
//  Created by tt on 2020/10/12.
//

#import "QCMergeForwardDetailVM.h"

#import "QCMergeForwardDetailCell.h"

@implementation QCMergeForwardDetailVM

- (NSArray<NSDictionary *> *)tableSectionMaps {
    
    NSMutableArray *items = [NSMutableArray array];
    NSString *title = @"";
    if(self.mergeForwardContent.msgs && self.mergeForwardContent.msgs.count>0) {
        NSInteger firstTime = self.mergeForwardContent.msgs[0].timestamp;
        NSInteger lastTime = self.mergeForwardContent.msgs[self.mergeForwardContent.msgs.count-1].timestamp;
        
        NSDateFormatter * formatter=[[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"YYYY-MM-dd"];
        
        NSString *firstDateStr=[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:firstTime]];
        NSString *lastDateStr=[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:lastTime]];
        if(![firstDateStr isEqualToString:lastDateStr]) {
            title = [NSString stringWithFormat:@"%@ ~ %@",firstDateStr,lastDateStr];
        }else{
            title = [NSString stringWithFormat:@"%@",firstDateStr];
        }
        
        QCMessage *preMessage;
        for (QCMessage *message in self.mergeForwardContent.msgs) {
            
            Class modelCls;
            BOOL hideAvatar;
            if(preMessage && [message.fromUid isEqualToString:preMessage.fromUid]) {
                hideAvatar = YES;
            }else{
                hideAvatar = NO;
            }
            
            switch (message.contentType) {
                case WK_TEXT:
                    modelCls = QCMergeForwardDetailTextModel.class;
                    break;
                case WK_IMAGE:
                    modelCls = QCMergeForwardDetailImageModel.class;
                    break;
                default:
                    modelCls = [QCApp.shared.endpointManager mergeForwardItem:message.contentType];
                    if(!modelCls) {
                        modelCls = QCMergeForwardDetailOtherModel.class;
                    }
                    break;
            }
            [items addObject:@{
                @"class":modelCls,
                @"message": message,
                @"hideAvatar": @(hideAvatar),
            }];
            preMessage = message;
        }
    }
    
    return @[
        @{
            @"height":@(30.0f),
            @"headView": [[QCMergeForwardDetailHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, QCScreenWidth, 20.0f) title:title],
            @"items":items,
            
        }
    ];
}

@end
