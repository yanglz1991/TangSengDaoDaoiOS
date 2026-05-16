//
//  QCMatchToken.h
//  QCCore
//
//  Created by tt on 2021/7/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    WKatchTokenTypeText, // 普通文本
    WKatchTokenTypeLink, // 普通链接
    WKatchTokenTypeMetion, // @
    WKatchTokenTypeEmoji, // emoji
    WKatchTokenTypeLink2, // 文本链接 必入 (百度)[http://baidu.com] // 显示为 百度
    WKatchTokenTypeBold, // 加粗
    WKatchTokenTypeRemoteImage, // 远程图片
    WKatchTokenTypeColor, // 颜色
    WKatchTokenTypeUnderline, // 下划线
    WKatchTokenTypeItalic, // 斜体
    WKatchTokenTypeStrikethrough, // 中划线
    WKatchTokenTypeFont, // 字体
} WKatchTokenType;

@protocol QCMatchToken <NSObject,NSCopying>

@property (nonatomic,copy) NSString *text;
@property (assign, nonatomic) NSRange  range;
@property(assign,nonatomic) WKatchTokenType type;

@end

@interface QCDefaultToken : NSObject<QCMatchToken>

+(QCDefaultToken*) text:(NSString*)text range:(NSRange)range type:(WKatchTokenType)type;

@end

@interface QCMetionToken : QCDefaultToken

@property(nonatomic,copy) NSString *uid;
@property(assign,nonatomic) NSInteger index; // 第几个@位

@end

@interface QCEmotionToken :QCDefaultToken

@property (copy, nonatomic) NSString *imageName;

@end

@interface QCLinkToken : QCDefaultToken
@property (nonatomic,copy) NSString *linkText;
@property (nonatomic,copy) NSString *linkContent;
@end

@interface QCBoldToken : QCDefaultToken

@property (nonatomic,copy) NSString *boldText; // 加粗的文本

@end

@interface QCRemoteImageToken : QCDefaultToken

@property(nonatomic,copy) NSString *url; // 图片下载地址
@property(nonatomic,assign) CGSize size; // 图片大小

@end

@interface QCColorToken : QCDefaultToken

@property(nonatomic,strong) UIColor *color;

@end

@interface QCUnderlineToken : QCDefaultToken

@end

@interface QCItalicToken : QCDefaultToken

@end

@interface QCStrikethroughToken : QCDefaultToken

@end

@interface QCFontToken : QCDefaultToken

@property(nonatomic,assign) CGFloat fontSize;

@end

NS_ASSUME_NONNULL_END
