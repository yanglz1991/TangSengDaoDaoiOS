//
//  QCUserAvatar.m
//  QCCore
//
//  Created by tt on 2020/6/19.
//

#import "QCUserAvatar.h"

#import "QCApp.h"
#import "UIView+WK.h"


@interface QCUserAvatar ()
@property(nonatomic,strong) UIView *avatarBox;

@end

@implementation QCUserAvatar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.borderWidth = 0.0f;
        [self setupUI];
    }
    return self;
}
- (instancetype)init
{
    return [self initWithFrame:CGRectMake(0.0f, 0.0f, QCDefaultAvatarSize.width, QCDefaultAvatarSize.height)];;
}

-(void) setupUI {
    [self addSubview:self.avatarBox];
    [self.avatarBox addSubview:self.avatarImgView];
}

- (UIImageView *)avatarImgView {
    if(!_avatarImgView) {
        _avatarImgView = [[QCImageView alloc] initWithFrame:CGRectMake(self.borderWidth/2.0f, self.borderWidth/2.0f, self.frame.size.width -self.borderWidth, self.frame.size.height - self.borderWidth)];
        _avatarImgView.layer.masksToBounds = YES;
        _avatarImgView.layer.cornerRadius = _avatarImgView.frame.size.width*0.4;
    }
    return _avatarImgView;
}

- (void)setUrl:(NSString *)url {
    _url = url;
    [_avatarImgView loadImage:[NSURL URLWithString:url] placeholderImage:[QCApp shared].config.defaultAvatar];
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    self.avatarImgView.frame = CGRectMake(borderWidth/2.0f, borderWidth/2.0f, self.frame.size.width -borderWidth, self.frame.size.height - borderWidth);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.avatarBox setBackgroundColor:[QCApp shared].config.cellBackgroundColor];
}


- (UIView *)avatarBox {
    if(!_avatarBox) {
        _avatarBox = [[UIView alloc] initWithFrame:self.bounds];
        _avatarBox.layer.masksToBounds = YES;
        _avatarBox.layer.cornerRadius = _avatarBox.frame.size.width*0.4;
    }
    return _avatarBox;
}

@end
