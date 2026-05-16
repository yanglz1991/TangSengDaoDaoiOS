//
//  QCMatchToken.m
//  QCCore
//
//  Created by tt on 2021/7/27.
//

#import "QCMatchToken.h"

@implementation QCDefaultToken


+(QCDefaultToken*) text:(NSString*)text range:(NSRange)range type:(WKatchTokenType)type {
    QCDefaultToken *token = [[QCDefaultToken alloc] init];
    token.range = range;
    token.text= text;
    token.type = type;
    return token;
}




@synthesize range;
@synthesize text;
@synthesize type;

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    QCDefaultToken *token = [[[self class] allocWithZone:zone] init];
    token.range = self.range;
    token.text = [self.text copy];
    token.type = self.type;
    return token;
}

@end

@implementation QCMetionToken

- (WKatchTokenType)type {
    return WKatchTokenTypeMetion;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    QCMetionToken *token = [[[self class] allocWithZone:zone] init];
    token.range = self.range;
    token.text = [self.text copy];
    token.type = self.type;
    token.uid = [self.uid copy];
    token.index = self.index;
    return token;
}

@end

@implementation QCEmotionToken

- (WKatchTokenType)type {
    return WKatchTokenTypeEmoji;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    QCEmotionToken *token = [[[self class] allocWithZone:zone] init];
    token.range = self.range;
    token.text = [self.text copy];
    token.type = self.type;
    token.imageName = [self.imageName copy];
    return token;
}

@end

@implementation QCLinkToken


- (WKatchTokenType)type {
    return WKatchTokenTypeLink2;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    QCLinkToken *token = [[[self class] allocWithZone:zone] init];
    token.range = self.range;
    token.text = [self.text copy];
    token.type = self.type;
    token.linkText = [self.linkText copy];
    token.linkContent = [self.linkContent copy];
    return token;
}
@end

@implementation QCBoldToken
- (WKatchTokenType)type {
    return WKatchTokenTypeBold;
}

- (NSString *)boldText {
    if(_boldText) {
        return _boldText;
    }
    return self.text;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    QCBoldToken *token = [[[self class] allocWithZone:zone] init];
    token.range = self.range;
    token.text = [self.text copy];
    token.type = self.type;
    token.boldText = [self.boldText copy];
    return token;
}

@end

@implementation QCRemoteImageToken

- (WKatchTokenType)type {
    return WKatchTokenTypeRemoteImage;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    QCRemoteImageToken *token = [[[self class] allocWithZone:zone] init];
    token.range = self.range;
    token.text = [self.text copy];
    token.type = self.type;
    token.size = self.size;
    token.url = [self.url copy];
    
    return token;
}

@end

@implementation QCColorToken

- (WKatchTokenType)type {
    return WKatchTokenTypeColor;
}


@end

@implementation QCUnderlineToken

- (WKatchTokenType)type {
    return WKatchTokenTypeUnderline;
}

@end

@implementation QCItalicToken

- (WKatchTokenType)type {
    return WKatchTokenTypeItalic;
}

@end

@implementation QCStrikethroughToken

- (WKatchTokenType)type {
    return WKatchTokenTypeStrikethrough;
}

@end


@implementation QCFontToken

- (WKatchTokenType)type {
    return WKatchTokenTypeFont;
}

@end
