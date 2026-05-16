//
//  QCGroupBlacklistVC.h
//  QCCore
//
//  Created by tt on 2020/10/19.
//

#import "QCBaseTableVC.h"
#import "QCGroupBlacklistVM.h"

NS_ASSUME_NONNULL_BEGIN

@interface QCGroupBlacklistVC : QCBaseTableVC<QCGroupBlacklistVM*>

@property(nonatomic,strong) QCChannel *channel;

@end

NS_ASSUME_NONNULL_END
