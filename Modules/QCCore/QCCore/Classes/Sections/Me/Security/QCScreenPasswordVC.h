//
//  QCScreenPasswordVC.h
//  QCCore
//
//  Created by tt on 2021/8/16.
//

#import <QCCore/QCCore.h>
#import "QCScreenPasswordVM.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCScreenPasswordVC : QCBaseVC<QCScreenPasswordVM*>

@property(nonatomic,copy) void(^onFinished)(NSString *pwd);

@property(nonatomic,assign) BOOL allowBack; // 是否允许返回


@end

NS_ASSUME_NONNULL_END
