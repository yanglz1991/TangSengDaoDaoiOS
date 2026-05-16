//
//  QCCardContent.m
//  QCCore
//
//  Created by tt on 2020/5/5.
//

#import "QCCardContent.h"
#import "QCCore.h"

@implementation QCCardContent


+(QCCardContent*) cardContent:(NSString*)vercode uid:(NSString*)uid name:(NSString*)name avatar:(NSString*)avatar {
    QCCardContent *content = [QCCardContent new];
    content.uid = uid;
    content.name = name;
    content.avatar = avatar;
    content.vercode = vercode;
    return content;
}

- (NSDictionary *)encodeWithJSON {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[@"uid"] = self.uid?:@"";
    dict[@"name"] = self.name?:@"";
    dict[@"avatar"] = self.avatar?:@"";
    dict[@"vercode"] = self.vercode?:@"";
    return dict;
}

- (void)decodeWithJSON:(NSDictionary *)contentDic {
    self.uid = contentDic[@"uid"];
    self.name = contentDic[@"name"];
    self.avatar = contentDic[@"avatar"];
    self.vercode = contentDic[@"vercode"]?:@"";
}


+(NSNumber*) contentType {
    return @(WK_CARD);
}


- (NSString *)conversationDigest {
    return LLang(@"[名片]");
}

- (NSString *)searchableWord {
    return @"[名片]";
}
@end
