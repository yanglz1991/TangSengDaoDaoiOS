//
//  QCMyGroupCell.m
//  QCContacts
//
//  Created by tt on 2020/7/16.
//

#import "QCMyGroupCell.h"

@class QCMyGroupCell;

@implementation QCMyGroupModel

- (Class)cell {
    return QCMyGroupCell.class;
}

- (NSNumber *)showArrow {
    return @(false);
}

@end

@interface QCMyGroupCell ()

@property(nonatomic,strong) QCUserAvatar *avatarImgView;
@property(nonatomic,strong) UILabel *nameLbl;

@end

@implementation QCMyGroupCell

+ (CGSize)sizeForModel:(QCFormItemModel *)model {
    return CGSizeMake(QCScreenWidth, 66.0f);
}
- (void)setupUI {
    [super setupUI];
    [self.contentView addSubview:self.avatarImgView];
    [self.contentView addSubview:self.nameLbl];
    
}

- (QCUserAvatar *)avatarImgView {
    if(!_avatarImgView) {
        _avatarImgView = [[QCUserAvatar alloc] init];
    }
    return _avatarImgView;
}

- (UILabel *)nameLbl {
    if(!_nameLbl) {
        _nameLbl = [[UILabel alloc] init];
        [_nameLbl setFont:[[QCApp shared].config appFontOfSizeMedium:16.0f]];
    }
    return _nameLbl;
}

- (void)refresh:(QCMyGroupModel *)model {
    [super refresh:model];
    self.avatarImgView.url = [QCAvatarUtil getGroupAvatar:model.groupNo];
    self.nameLbl.text = model.name;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.avatarImgView.lim_left = 15.0f;
    self.avatarImgView.lim_top = self.lim_height/2.0f  - self.avatarImgView.lim_height/2.0f;
    
    self.nameLbl.lim_left = self.avatarImgView.lim_right +  15.0f;
    self.nameLbl.lim_width = self.lim_width - self.avatarImgView.lim_right - self.nameLbl.lim_left - 30.0f;
    self.nameLbl.lim_height = self.lim_height;
    self.nameLbl.lim_top = self.lim_height/2.0f - self.nameLbl.lim_height/2.0f;
}
@end
