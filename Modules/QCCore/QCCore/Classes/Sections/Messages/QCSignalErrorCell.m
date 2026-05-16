//
//  QCSignalErrorCell.m
//  QCCore
//
//  Created by tt on 2021/9/11.
//

#import "QCSignalErrorCell.h"

@interface QCSignalErrorCell ()
@property(nonatomic,strong) UILabel *textLbl;
@end

@implementation QCSignalErrorCell

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
    self.textLbl.text =[QCApp shared].config.signalErrorMessageText;
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
