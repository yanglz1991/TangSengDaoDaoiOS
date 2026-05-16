//
//  QCContactsAddMyShortCell.h
//  QCCore
//
//  Created by tt on 2020/6/22.
//

#import <QCCore/QCCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCContactsAddMyShortModel : QCFormItemModel

@property(nonatomic,copy) NSString *value;


/// 二维码点击
@property(nonatomic,strong) void(^onQRCode)(void);

@end

@interface QCContactsAddMyShortCell : QCCell


@end

NS_ASSUME_NONNULL_END
