//
//  QCScreenshotContent.m
//  QCCore
//
//  Created by tt on 2020/10/16.
//

#import "QCScreenshotContent.h"
#import "QCApp.h"
#import "QCCore.h"

@interface QCScreenshotContent ()


@end

@implementation QCScreenshotContent


- (NSString *)tip {
    if(_tip) {
        return _tip;
    }
    QCUserInfo *userInfo = self.senderUserInfo;
    NSString *name = LLang(@"你");
    if([userInfo.uid isEqualToString:[QCApp shared].loginInfo.uid]) {
        name = LLang(@"你");
    }else{
       QCChannelInfo *channelInfo = [[QCSDK shared].channelManager getChannelInfo:[QCChannel personWithChannelID:userInfo.uid]];
        if(channelInfo) {
            name = channelInfo.displayName;
        }else{
            name = userInfo.name;
        }
    }
    _tip =  [NSString stringWithFormat:LLang(@"%@在聊天中截屏了"),name];
    return _tip;
}

- (NSDictionary *)encodeWithJSON {
    return @{@"from_uid":[QCApp shared].loginInfo.uid?:@"",@"from_name":[QCApp shared].loginInfo.extra[@"name"]?:@""};
}

- (NSString *)conversationDigest {
    // 已禁用「在聊天中截屏了」通知：会话列表里不再展示该 digest
    return @"";
}

+ (NSNumber*)contentType {
    return @(WK_SCREENSHOT);
}
@end
