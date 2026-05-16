//
//  QCScreenshotCell.m
//  WuKongBase
//
//  Created by tt on 2020/10/16.
//

#import "QCScreenshotCell.h"
#import "QCScreenshotContent.h"
#import "QCTipLabel.h"
@interface QCScreenshotCell ()
@property(nonatomic,strong) QCTipLabel *tipTextLbl;
@property(nonatomic,strong) QCMessageModel *messageModel;

@end

@implementation QCScreenshotCell

+ (CGSize)sizeForMessage:(QCMessageModel *)model {
    // 已禁用「在聊天中截屏了」通知：返回零尺寸，使历史该类型消息不再占用布局。
    return CGSizeZero;
}


-(void) initUI {
    [super initUI];
    [self setBackgroundColor:[UIColor clearColor]];

    
    self.tipTextLbl = [[QCTipLabel alloc] init];
    [self.tipTextLbl setTextAlignment:NSTextAlignmentCenter];
    [self.tipTextLbl setFont:[UIFont systemFontOfSize:[QCApp shared].config.messageTipTimeFontSize]];
    [self.tipTextLbl setTextColor:[UIColor grayColor]];
    [self.tipTextLbl setBackgroundColor:[UIColor whiteColor]];
    self.tipTextLbl.layer.masksToBounds = YES;
    self.tipTextLbl.layer.cornerRadius = 10.0f;
    [self addSubview:self.tipTextLbl];
    
    
}

- (void)refresh:(QCMessageModel *)model {
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
    NSAttributedString *string = [[NSAttributedString alloc]initWithString:text attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[QCApp shared].config.messageTipTimeFontSize], NSParagraphStyleAttributeName:style}];
    CGSize size =  [string boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    return size;
}

@end
