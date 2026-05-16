//
//  QCMergeForwardCell.m
//  WuKongBase
//
//  Created by tt on 2020/10/12.
//

#import "QCMergeForwardCell.h"
#import "QCMergeForwardContent.h"
#import "QCMergeForwardDetailVC.h"
#import "WuKongBase.h"
@interface QCMergeForwardCell ()

@property(nonatomic,strong) UILabel *titleLbl;
@property(nonatomic,strong) UIView *messageBox;
@property(nonatomic,strong) UIView *lineView;
@property(nonatomic,strong) UILabel *descLbl;

@end

#define titleHeight 18.0f
#define titleTop 10.0f
#define messageBoxTop 4.0f
#define messageHeight 13.0f

#define lineTop 4.0f

#define descHeight 26.0f


@implementation QCMergeForwardCell

+ (CGSize)contentSizeForMessage:(QCMessageModel *)model {
    QCMergeForwardContent *content = (QCMergeForwardContent*)model.content;
    return CGSizeMake([QCApp shared].config.messageContentMaxWidth, titleTop + titleHeight + messageBoxTop + messageHeight*(content.msgs.count>4?4:content.msgs.count)+ lineTop+1.0f + descHeight);
}

- (void)initUI {
    [super initUI];
    self.messageContentView.layer.masksToBounds = YES;
    self.messageContentView.layer.cornerRadius = 4.0f;
    [self.messageContentView addSubview:self.titleLbl];
    [self.messageContentView addSubview:self.messageBox];
    [self.messageContentView addSubview:self.lineView];
    [self.messageContentView addSubview:self.descLbl];
    
}

- (void)refresh:(QCMessageModel *)model {
    [super refresh:model];
    QCMergeForwardContent *content = (QCMergeForwardContent*)model.content;
    
    self.titleLbl.text = content.title;
    
    [[self.messageBox subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if(content.msgs && content.msgs.count>0) {
        for (NSInteger i=0; i<content.msgs.count; i++) {
            QCMessage *message = content.msgs[i];
            UILabel *textLbl = [self messageTextLbl];
            NSString *fromName = @"";
            if(message.from) {
                fromName = message.from.displayName;
            }else{
                [[QCSDK shared].channelManager fetchChannelInfo:[[QCChannel alloc] initWith:message.fromUid channelType:WK_PERSON]];
            }
            textLbl.text = [NSString stringWithFormat:@"%@：%@",fromName,[message.content conversationDigest]];
            [self.messageBox addSubview:textLbl];
            
            if(i+1==4) {
                break;
            }
        }
    }
    
    [self.messageContentView setBackgroundColor:[QCApp shared].config.cellBackgroundColor];
    self.titleLbl.textColor = [QCApp shared].config.defaultTextColor;
    self.lineView.backgroundColor = [QCApp shared].config.lineColor;
    
    self.trailingView.timeLbl.textColor = [QCApp shared].config.tipColor;
    self.trailingView.statusImgView.tintColor = [QCApp shared].config.tipColor;
}

- (void)onTap {
    QCMergeForwardDetailVC *vc = QCMergeForwardDetailVC.new;
    vc.mergeForwardContent = (QCMergeForwardContent*)self.messageModel.content;
    [[QCNavigationManager shared] pushViewController:vc animated:YES];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat leftSpace = 10.0f;
    self.titleLbl.lim_top = titleTop;
    self.titleLbl.lim_left = 10.0f;
    self.titleLbl.lim_width = self.messageContentView.lim_width - leftSpace*2;
    
    self.messageBox.lim_top = self.titleLbl.lim_bottom + messageBoxTop;
    self.messageBox.lim_width = self.messageContentView.lim_width;
    self.messageBox.lim_height = messageHeight * self.messageBox.subviews.count;
    if(self.messageBox.subviews.count>0) {
        for (NSInteger i=0; i<self.messageBox.subviews.count; i++) {
            UIView *view = self.messageBox.subviews[i];
            view.lim_left = 10.0f;
            view.lim_top = i * view.lim_height;
            view.lim_width = self.messageContentView.lim_width - leftSpace*2;
        }
    }
    
    self.lineView.lim_width = self.messageContentView.lim_width - leftSpace*2;
    self.lineView.lim_left = leftSpace;
    self.lineView.lim_top = self.messageBox.lim_bottom + lineTop;
    
    self.descLbl.lim_top = self.lineView.lim_bottom;
    self.descLbl.lim_left = leftSpace;
    self.descLbl.lim_width = self.messageContentView.lim_width - leftSpace * 2;
    
}


- (UILabel *)titleLbl {
    if(!_titleLbl) {
        _titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, titleHeight)];
        _titleLbl.font = [[QCApp shared].config appFontOfSize:16.0f];
    }
    return _titleLbl;
}

- (UIView *)messageBox {
    if(!_messageBox) {
        _messageBox = [[UIView alloc] init];
        _messageBox.userInteractionEnabled = NO;
    }
    return _messageBox;
}

-(UILabel*) messageTextLbl {
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, messageHeight)];
    lbl.font = [[QCApp shared].config appFontOfSize:12.0f];
    lbl.textColor = [QCApp shared].config.tipColor;
    return lbl;
}

- (UIView *)lineView {
    if(!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 1.0f)];
        [_lineView setBackgroundColor:[UIColor colorWithRed:246.0f/255.0f green:246.0f/255.0f blue:246.0f/255.0f alpha:1.0f]];
    }
    return _lineView;
}

- (UILabel *)descLbl {
    if(!_descLbl) {
        _descLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, descHeight)];
        _descLbl.font = [[QCApp shared].config appFontOfSize:12.0f];
        _descLbl.textColor = [QCApp shared].config.tipColor;
        _descLbl.text = LLang(@"聊天记录");
    }
    return _descLbl;
}


+ (BOOL)hiddenBubble {
    return YES;
}


@end
