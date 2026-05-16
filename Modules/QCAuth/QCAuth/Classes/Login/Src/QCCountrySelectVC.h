//
//  QCCountrySelectVC.h
//  QCAuth
//
//  Created by tt on 2020/6/8.
//

#import <QCCore/QCCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCCountrySelectVC : QCBaseVC

// 选择完成
@property(nonatomic,copy) void(^onFinished)(NSDictionary *data);

@end

NS_ASSUME_NONNULL_END
