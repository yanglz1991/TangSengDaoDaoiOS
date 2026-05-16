//
//  QCScreenPasswordVM.h
//  QCCore
//
//  Created by tt on 2021/8/16.
//

#import <QCCore/QCCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCScreenPasswordVM : QCBaseVM

// 关闭解锁密码
-(AnyPromise*) requestCloseLock;

@end

NS_ASSUME_NONNULL_END
