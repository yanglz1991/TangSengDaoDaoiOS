//
//  QCReplyView.m
//  WuKongBase
//
//  Created by tt on 2020/10/20.
//

#import "QCMessageEditView.h"
#import "QCConstant.h"
#import "QCApp.h"
#import "UIView+WK.h"
#import "QCResource.h"
#import "QCAvatarUtil.h"
#import "UIImageView+WK.h"
#define viewHeight 54.0f

@interface QCMessageEditView ()

@property(nonatomic,strong) QCMessage *message;

@property(nonatomic,strong) UIView *splitView;

@property(nonatomic,strong) UILabel *titleLbl;

@property(nonatomic,strong) UILabel *contentLbl;

@property(nonatomic,strong) UIButton *closeBtn;


@end

@implementation QCMessageEditView

+ (instancetype)message:(QCMessage *)message {
    QCMessageEditView *view = [[QCMessageEditView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, QCScreenWidth, viewHeight)];
    view.message = message;
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.splitView];
        [self addSubview:self.titleLbl];
        [self addSubview:self.contentLbl];
        [self addSubview:self.closeBtn];
    }
    return self;
}

- (void)setMessage:(QCMessage *)message {
    _message = message;
    
    self.titleLbl.text = @"编辑消息";
    [self.titleLbl sizeToFit];
    
    QCMessageContent *content = message.content;
    if(message.remoteExtra.contentEdit) {
        content = message.remoteExtra.contentEdit;
    }
    self.contentLbl.text = [content conversationDigest];
    [self.contentLbl sizeToFit];
    if(self.contentLbl.lim_width> QCScreenWidth - 30*2) {
        self.contentLbl.lim_width = QCScreenWidth - 30*2;
    }
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // split
    self.splitView.lim_left = 15.0f;
    self.splitView.lim_top = 10.0f;
    self.splitView.lim_height = viewHeight-5.0f*2;
    self.splitView.lim_width = 2.0f;
    
    
    // name
    self.titleLbl.lim_left = 12.0f;
    self.titleLbl.lim_top = self.splitView.lim_top-2.0f;
    
    // content
    self.contentLbl.lim_top = self.titleLbl.lim_bottom + 2.0f;
    self.contentLbl.lim_left = self.titleLbl.lim_left;
    
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

- (UILabel *)titleLbl {
    if(!_titleLbl) {
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.textColor = [QCApp shared].config.themeColor;
        _titleLbl.font = [[QCApp shared].config appFontOfSize:17.0f];
    }
    return _titleLbl;
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
//        [_closeBtn setBackgroundColor:[UIColor redColor]];
    }
    return _closeBtn;
}

-(void) closePressed {
    if(self.onClose) {
        self.onClose();
    }
}

-(UIImage*) imageName:(NSString*)name {
    return [QCApp.shared loadImage:name moduleID:@"WuKongBase"];
//    return [[QCResource shared] resourceForImage:name podName:@"WuKongBase_images"];
}
@end
