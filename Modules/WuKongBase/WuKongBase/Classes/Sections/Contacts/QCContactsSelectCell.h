//
//  QCContactsSelectCell.h
//  WuKongContacts
//
//  Created by tt on 2020/1/19.
//

#import <Foundation/Foundation.h>
#import "QCContacts.h"
#import "QCCell.h"
#import "QCCheckBox.h"
#import "QCImageView.h"
#import "QCUserAvatar.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCContactsSelect : QCContacts

@property(nonatomic,assign) QCContactsMode mode;
// 是否禁用
@property(nonatomic,assign) BOOL disable;

// 最后一条数据
@property(nonatomic,assign) BOOL last;

// 第一条数据
@property(nonatomic,assign) BOOL first;

// 是否被选择
@property(nonatomic,assign) BOOL selected;

@end

typedef void (^stateChangeCheckBlock)(QCContactsSelect *model);

@interface QCContactsSelectCell : QCCell

@property(nonatomic,strong) QCUserAvatar *avatarImgView;
@property(nonatomic,strong) UILabel *nameLbl;

@property(nonatomic,strong) QCContactsSelect *contactSelectModel;

@property(nonatomic,strong) QCCheckBox *checkBox;

@property(nonatomic, strong) stateChangeCheckBlock stateChangeCheckBk;

-(void) refreshWithModel:(id)cellModel;


@end

NS_ASSUME_NONNULL_END
