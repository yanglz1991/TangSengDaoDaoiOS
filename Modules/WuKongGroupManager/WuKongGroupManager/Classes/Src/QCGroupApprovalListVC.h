//
//  QCGroupApprovalListVC.h
//  WuKongGroupManager
//
//  群邀请审批记录列表
//

#import "QCBaseTableVC.h"
#import "QCGroupApprovalListVM.h"

NS_ASSUME_NONNULL_BEGIN

@interface QCGroupApprovalListVC : QCBaseTableVC<QCGroupApprovalListVM *>

@property(nonatomic, strong) QCChannel *channel;

@end

NS_ASSUME_NONNULL_END
