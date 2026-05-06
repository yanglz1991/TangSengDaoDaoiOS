//
//  WKScreenshotCell.m
//  WuKongBase
//
//  Created by tt on 2020/10/16.
//

#import "WKScreenshotCell.h"
#import "WKScreenshotContent.h"
#import "WKTipLabel.h"
@interface WKScreenshotCell ()
@property(nonatomic,strong) WKTipLabel *tipTextLbl;
@property(nonatomic,strong) WKMessageModel *messageModel;

@end

@implementation WKScreenshotCell

+ (CGSize)sizeForMessage:(WKMessageModel *)model {
    // 已禁用「在聊天中截屏了」通知：返回零尺寸，使历史该类型消息不再占用布局。
    return CGSizeZero;
}


-(void) initUI {
    [super initUI];
    [self setBackgroundColor:[UIColor clearColor]];

    
    self.tipTextLbl = [[WKTipLabel alloc] init];
    [self.tipTextLbl setTextAlignment:NSTextAlignmentCenter];
    [self.tipTextLbl setFont:[UIFont systemFontOfSize:[WKApp shared].config.messageTipTimeFontSize]];
    [self.tipTextLbl setTextColor:[UIColor grayColor]];
    [self.tipTextLbl setBackgroundColor:[UIColor whiteColor]];
    self.tipTextLbl.layer.masksToBounds = YES;
    self.tipTextLbl.layer.cornerRadius = 10.0f;
    [self addSubview:self.tipTextLbl];
    
    
}

- (void)refresh:(WKMessageModel *)model {
    [super refresh:model];
    self.messageModel = model;
    // 已禁用「在聊天中截屏了」通知：隐藏提示文本，不再在消息列表里呈现。
    self.tipTextLbl.text = @"";
    self.tipTextLbl.hidden = YES;
    [self.tipTextLbl setBackgroundColor:[UIColor clearColor]];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    if(!self.messageModel) {
        return;
    }
    CGSize contentSize = [[self class] sizeForMessage:self.messageModel];
    self.tipTextLbl.lim_size = CGSizeMake(contentSize.width-10.0f, contentSize.height-10.0f);
    self.tipTextLbl.lim_left = self.lim_width/2.0f - self.tipTextLbl.lim_width/2.0f;
}

+ (CGSize) getTextSize:(NSString*) text maxWidth:(CGFloat)maxWidth{
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineBreakMode = NSLineBreakByWordWrapping;
    style.alignment = NSTextAlignmentCenter;
    NSAttributedString *string = [[NSAttributedString alloc]initWithString:text attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[WKApp shared].config.messageTipTimeFontSize], NSParagraphStyleAttributeName:style}];
    CGSize size =  [string boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    return size;
}

@end
