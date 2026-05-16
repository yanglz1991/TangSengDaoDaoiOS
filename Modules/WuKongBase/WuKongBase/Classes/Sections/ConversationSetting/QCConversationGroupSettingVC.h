//
//  QCConversationGroupSettingVC.h
//  AFNetworking
//
//  Created by tt on 2020/1/21.
//

#import "QCBaseVC.h"
#import "QCBaseTableVC.h"
#import <WuKongIMSDK/WuKongIMSDK.h>
#import "QCConversationSettingVM.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCConversationGroupSettingVC : QCBaseTableVC<QCConversationSettingVM*>

@property(nonatomic,strong) QCChannel *channel;

@property(nonatomic,weak) id<QCConversationContext> context;
@end

NS_ASSUME_NONNULL_END
