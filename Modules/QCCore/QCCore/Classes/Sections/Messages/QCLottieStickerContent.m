//
//  QCLottieStickerContent.m
//  QCCore
//
//  Created by tt on 2021/8/26.
//

#import "QCLottieStickerContent.h"
#import "QCCore.h"
@implementation QCLottieStickerContent


- (void)decodeWithJSON:(NSDictionary *)contentDic {
    self.url = contentDic[@"url"]?:@"";
    self.category = contentDic[@"category"]?:@"";
    self.placeholder = contentDic[@"placeholder"]?:@"";
    self.format = contentDic[@"format"]?:@"lim";
}

- (NSDictionary *)encodeWithJSON {
    return @{
        @"url":self.url?:@"",
        @"category":self.category?:@"",
        @"placeholder": self.placeholder?:@"",
        @"format": self.format?:@"lim",
    };
}

// 语音的源文件扩展名
- (NSString *)extension {
    return @".json";
}

-(NSString*) thumbExtension {
    return @".lim";
}

+(NSNumber*) contentType {
    return @(WK_LOTTIE_STICKER);
}

- (NSString *)conversationDigest {
    return LLang(@"[贴图]");
}

@end
