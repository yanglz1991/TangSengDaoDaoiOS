//
//  QCContactsAddFunctionItemCell.m
//  WuKongBase
//
//  Created by tt on 2020/6/22.
//

#import "QCContactsAddFunctionItemCell.h"

@implementation QCContactsAddFunctionItemModel

-(Class) cell {
    return QCContactsAddFunctionItemCell.class;
}

-(CGFloat) cellHeight {
    return 60.0f;
}

@end

@interface QCContactsAddFunctionItemCell ()
@property(nonatomic,strong) UIImageView *iconImageView; // 头像
@property(nonatomic,strong) UILabel *titleLbl; // 标题
@property(nonatomic,strong) UILabel *subtitleLbl; // 标题
@end

@implementation QCContactsAddFunctionItemCell


- (void)setupUI {
    [super setupUI];
    CGFloat iconSize = 30.0f;
    self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, iconSize, iconSize)];
    self.iconImageView.layer.masksToBounds = YES;
    self.iconImageView.layer.cornerRadius = 5.0f;
    [self.contentView addSubview:self.iconImageView];
    
    self.titleLbl = [[UILabel alloc] init];
    [self.titleLbl setFont:[[QCApp shared].config appFontOfSize:16.0f]];
    [self.titleLbl setTextColor:[QCApp shared].config.defaultTextColor];
    [self.contentView addSubview:self.titleLbl];
    
    self.subtitleLbl = [[UILabel alloc] init];
    [self.subtitleLbl setFont:[[QCApp shared].config appFontOfSize:14.0f]];
    [self.subtitleLbl setTextColor:[UIColor grayColor]];
    [self.contentView addSubview:self.subtitleLbl];
}

- (void)refresh:(QCContactsAddFunctionItemModel*)cellModel {
    [super refresh:cellModel];
    self.titleLbl.text = cellModel.title;
    self.subtitleLbl.text = cellModel.subtitle;
    self.iconImageView.image = cellModel.icon;
    [self.subtitleLbl sizeToFit];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat iconLeft = 15.0f;
    self.iconImageView.lim_top = self.lim_height/2.0f - self.iconImageView.lim_height/2.0f;
    self.iconImageView.lim_left = iconLeft;
    
    
    CGFloat titleLeft = 10.0f;
    CGFloat titleRight = 10.0f;
    self.titleLbl.lim_left = self.iconImageView.lim_right + titleLeft;
    self.titleLbl.lim_width = self.lim_width - self.titleLbl.lim_left - titleRight;
    self.titleLbl.lim_height = 18.0f;
    self.titleLbl.lim_top = 10.0f;
    
    self.subtitleLbl.lim_left = self.titleLbl.lim_left;
    self.subtitleLbl.lim_top = self.titleLbl.lim_bottom + 4.0f;
    self.subtitleLbl.lim_width = self.lim_width - self.subtitleLbl.lim_left - titleRight;
    self.subtitleLbl.lim_height = 20.0f;
    
}

-(UIImage*) imageName:(NSString*)name {
    return [[QCApp shared] loadImage:name moduleID:@"WuKongContacts"];
}


@end
