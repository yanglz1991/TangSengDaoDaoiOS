//
//  QCReplyView.m
//  QCCore
//
//  Created by tt on 2020/10/20.
//

#import "QCReplyView.h"
#import "QCConstant.h"
#import "QCApp.h"
#import "UIView+WK.h"
#import "QCResource.h"
#import "QCAvatarUtil.h"
#import "UIImageView+WK.h"
#import "QCUserAvatar.h"
#define viewHeight 54.0f

@interface QCReplyView ()

@property(nonatomic,strong) QCMessage *message;

@property(nonatomic,strong) UIView *splitView;

@property(nonatomic,strong) QCUserAvatar *replyAvatarIcon;

@property(nonatomic,strong) UILabel *nameLbl;

@property(nonatomic,strong) UILabel *contentLbl;

@property(nonatomic,strong) UIButton *closeBtn;

@end

@implementation QCReplyView

+ (instancetype)message:(QCMessage *)message {
    QCReplyView *view = [[QCReplyView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, QCScreenWidth, viewHeight)];
    view.message = message;
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.splitView];
        [self addSubview:self.replyAvatarIcon];
        [self addSubview:self.nameLbl];
        [self addSubview:self.contentLbl];
        [self addSubview:self.closeBtn];
    }
    return self;
}

- (void)setMessage:(QCMessage *)message {
    _message = message;
    
    self.nameLbl.text = @"---";
    if(message.from) {
        self.nameLbl.text = message.from.displayName;
    }
    [self.nameLbl sizeToFit];
    
    self.contentLbl.text = [message.content conversationDigest];
    [self.contentLbl sizeToFit];
    if(self.contentLbl.lim_width> QCScreenWidth - 30*2) {
        self.contentLbl.lim_width = QCScreenWidth - 30*2;
    }
    self.replyAvatarIcon.url = [QCAvatarUtil getAvatar:message.fromUid];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // split
    self.splitView.lim_left = 15.0f;
    self.splitView.lim_top = 10.0f;
    self.splitView.lim_height = viewHeight-5.0f*2;
    self.splitView.lim_width = 2.0f;
    
    self.replyAvatarIcon.lim_left = 15.0f;
    self.replyAvatarIcon.lim_top = 10.0f;
    
    // name
    self.nameLbl.lim_left = self.replyAvatarIcon.lim_right + 4.0f;
    self.nameLbl.lim_top = self.replyAvatarIcon.lim_top-2.0f;
    
    // content
    self.contentLbl.lim_top = self.nameLbl.lim_bottom + 2.0f;
    self.contentLbl.lim_left = self.replyAvatarIcon.lim_left;
    
    // close
    self.closeBtn.lim_top = 0.0f;
    self.closeBtn.lim_left = QCScreenWidth - self.closeBtn.lim_width - 15.0f;
}

- (UIView *)splitView {
    if(!_splitView) {
        _splitView = [[UIView alloc] init];
        _splitView.backgroundColor = [QCApp shared].config.themeColor;
        _splitView.hidden = YES;
    }
    return _splitView;
}

- (QCUserAvatar *)replyAvatarIcon {
    if(!_replyAvatarIcon) {
        _replyAvatarIcon = [[QCUserAvatar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 20.0f)];
    }
    return _replyAvatarIcon;
}

- (UILabel *)nameLbl {
    if(!_nameLbl) {
        _nameLbl = [[UILabel alloc] init];
        _nameLbl.textColor = [QCApp shared].config.tipColor;
        _nameLbl.font = [[QCApp shared].config appFontOfSize:16.0f];
    }
    return _nameLbl;
}

- (UILabel *)contentLbl {
    if(!_contentLbl) {
        _contentLbl = [[UILabel alloc] init];
        _contentLbl.font = [[QCApp shared].config appFontOfSize:15.0f];
        _contentLbl.numberOfLines = 1;
        _contentLbl.textColor = [QCApp shared].config.tipColor;
    }
    return _contentLbl;
}

- (UIButton *)closeBtn {
    if(!_closeBtn) {
        _closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 38.0f, 38.0f)];
        [_closeBtn setImage:[self imageName:@"Common/Index/Close"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closePressed) forControlEvents:UIControlEventTouchUpInside];
        [_closeBtn setContentEdgeInsets:UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f)];
    }
    return _closeBtn;
}

-(void) closePressed {
    if(self.onClose) {
        self.onClose();
    }
}

-(UIImage*) imageName:(NSString*)name {
    return [QCApp.shared loadImage:name moduleID:@"QCCore"];
//    return [[QCResource shared] resourceForImage:name podName:@"QCCore_images"];
}
@end
