//
//  QCConversationSelectVC.h
//  WuKongBase
//
//  Created by tt on 2020/2/2.
//

#import "WuKongBase.h"
#import "QCConversationListSelectVM.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCConversationListSelectVC : QCBaseTableVC<QCConversationListSelectVM*>


/**
 单选回调(兼容原有单选场景)
 */
@property(nonatomic,copy) void(^onSelect)(QCChannel*channel);

/**
 多选确认回调:仅当 viewModel.multiple == YES 时,从底部"确定"按钮触发
 */
@property(nonatomic,copy) void(^onSelectChannels)(NSArray<QCChannel*>*channels);

@end


NS_ASSUME_NONNULL_END
