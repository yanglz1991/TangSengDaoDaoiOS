//
//  QCUnkownMessageCell.m
//  WuKongBase
//
//  Created by tt on 2020/1/11.
//

#import "QCUnkownMessageCell.h"
#import "QCApp.h"
#import "QCTimeTool.h"
#define tipFontSize 15.0f

@interface QCUnkownMessageCell()

@property(nonatomic,strong) UILabel *textLbl;

@end

@implementation QCUnkownMessageCell

+ (CGSize) contentSizeForMessage:(QCMessageModel *)model {
    
    return CGSizeMake([QCApp shared].config.messageContentMaxWidth, 44.0f);
}

-(void) initUI {
    [super initUI];
    self.textLbl = [[UILabel alloc] init];
    self.textLbl.numberOfLines = 0;
    self.textLbl.font = [[QCApp shared].config appFontOfSize:[QCApp shared].config.messageTextFontSize];
    self.textLbl.lineBreakMode = NSLineBreakByWordWrapping;
    [self.messageContentView addSubview:self.textLbl];
}

- (void)refresh:(QCMessageModel *)model {
    [super refresh:model];
//    self.trailingView.hidden = YES;
    self.textLbl.text =[QCApp shared].config.unkownMessageText;
    [self.textLbl sizeToFit];
    
    if(model.isSend) {
        self.textLbl.textColor =  [QCApp shared].config.messageSendTextColor;
    }else {
        self.textLbl.textColor = [QCApp shared].config.messageRecvTextColor;
    }
   
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textLbl.lim_width = self.messageContentView.lim_width;
    [self.textLbl sizeToFit];

}

@end
