//
//  QCMeAvatarCell.m
//  WuKongBase
//
//  Created by tt on 2020/6/23.
//

#import "QCMeAvatarCell.h"
#import "QCApp.h"
@implementation QCMeAvatarModel

- (Class)cell {
    return QCMeAvatarCell.class;
}

@end

@interface QCMeAvatarCell ()
@property(nonatomic,strong) QCUserAvatar *avatarImgView;
@end

@implementation QCMeAvatarCell

+(CGSize) sizeForModel:(QCFormItemModel*)model{
    return CGSizeMake(QCScreenWidth, 84.0f);
}

- (void)setupUI {
    [super setupUI];
    
    [self.valueView addSubview:self.avatarImgView];
    
}

- (QCUserAvatar *)avatarImgView {
    if(!_avatarImgView) {
        _avatarImgView = [[QCUserAvatar alloc] init];
    }
    return _avatarImgView;
}

- (void)refresh:(QCMeAvatarModel*)cellModel {
    [super refresh:cellModel];
    [_avatarImgView setUrl:[QCAvatarUtil getAvatar:[QCApp shared].loginInfo.uid]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.avatarImgView.lim_top = self.lim_height/2.0f - self.avatarImgView.lim_height/2.0f;
    self.avatarImgView.lim_left = self.valueView.lim_width - self.avatarImgView.lim_width;
}

@end
