//
//  M80AttributedLabel+NIMKit
//  NIM
//
//  Created by chris.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "M80AttributedLabel+WK.h"
#import "QCEmoticonService.h"
#import "QCMentionService.h"


@implementation M80AttributedLabel (WK)


- (void)lim_setText:(NSString *)text mentionInfo:(QCMentionedInfo*)mentionInfo {
    [self setText:@""];
    if(!text || [text isEqualToString:@""]) {
        return;
    }
    
       
    NSArray<id<QCMatchToken>> *tokens = [ [QCEmoticonService shared] parseEmotion:text];
    for(id<QCMatchToken> token in tokens){
           if (token.type == WKatchTokenTypeEmoji){
               QCEmotionToken *emojiToken = (QCEmotionToken*)token;
               UIImage *image = [[QCEmoticonService shared] emojiImageNamed:emojiToken.imageName];
               if(image){
                   [self appendImage:image maxSize:CGSizeMake(24.0f, 24.0f)];
               }
           }else{
               if(mentionInfo) {
                   NSString *text = token.text;
                   NSArray<id<QCMatchToken>> *mentions = [[QCMentionService shared] parseMention:text mentionInfo:mentionInfo];
                   if(mentions && mentions.count>0) {
                       for(id<QCMatchToken> token in mentions) {
                           if(token.type == WKatchTokenTypeMetion) {
                               QCMetionToken *mentionToken = (QCMetionToken*)token;
                                if(mentionToken.index < mentionInfo.uids.count) {
                                    [self addCustomLink:mentionToken forRange:mentionToken.range linkColor:[UIColor colorWithRed:86.0/255.0f green:169.0f/255.0f blue:60.0f/255.0f alpha:1.0f]];
                                }
                               [self appendText:mentionToken.text];
                               
                           }else{
                               [self appendText:token.text];
                           }
                       }
                   }
               }else {
                    [self appendText:token.text];
               }
               
               
           }
       }
}

- (void)lim_setText:(NSString *)text
{
    [self lim_setText:text mentionInfo:nil];
   
}

@end
