//
//  NSMutableAttributedString+WK.h
//  WuKongBase
//
//  Created by tt on 2021/7/27.
//

#import <Foundation/Foundation.h>
#import "QCApp.h"
#import "QCRichTextParseService.h"
NS_ASSUME_NONNULL_BEGIN

@interface NSMutableAttributedString (WK)

@property(nonatomic,strong) UIFont *font;
@property(nonatomic,strong) UIColor *textColor;
@property(nonatomic,strong) UIColor *metionColor;
@property(nonatomic,strong) UIColor *linkColor; // 链接颜色
@property(nonatomic,assign) BOOL metionUnderline; //是否显示下划线


@property(nonatomic,strong) NSArray<id<QCMatchToken>> *tokens;

- (void)lim_parse:(NSString *)text;
- (void)lim_parse:(NSString *)text mentionInfo:(QCMentionedInfo* __nullable)mentionInfo;
- (void)lim_parse:(NSString *)text mentionInfo:(QCMentionedInfo *__nullable)mentionInfo options:(QCRichTextParseOptions*__nullable)options;

-(void) lim_render:(NSString *)text tokens:(NSArray<id<QCMatchToken>>*)tokens;


// 最后一行的宽度
-(CGFloat)lastlineWidth:(CGFloat)maxWidth;

-(CGSize) size:(CGFloat)maxWidth;

@end

NS_ASSUME_NONNULL_END
