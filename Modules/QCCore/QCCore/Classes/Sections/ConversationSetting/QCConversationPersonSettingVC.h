//
//  QCConversationSettingVC.h
//  QCCore
//
//  Created by tt on 2020/1/20.
//

#import "QCBaseVC.h"
#import "QCBaseTableVC.h"
#import <QCIM/QCIM.h>
#import "QCConversationSettingVM.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCConversationPersonSettingVC : QCBaseTableVC<QCConversationSettingVM*>

@property(nonatomic,strong) QCChannel *channel;
@property(nonatomic,weak) id<QCConversationContext> context;

@end

NS_ASSUME_NONNULL_END
