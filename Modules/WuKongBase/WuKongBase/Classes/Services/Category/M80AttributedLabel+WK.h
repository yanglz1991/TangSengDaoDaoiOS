//
//  M80AttributedLabel+WK.h
//  WuKongBase
//
//  Created by tt on 2020/1/11.
//

#import <M80AttributedLabel/M80AttributedLabel.h>
#import "QCApp.h"
@interface M80AttributedLabel (WK)
- (void)lim_setText:(NSString *)text;
- (void)lim_setText:(NSString *)text mentionInfo:(QCMentionedInfo*)mentionInfo;
@end

