//
//  QCGroupApprovalListVM.h
//  WuKongGroupManager
//
//  群邀请审批记录列表 VM
//

#import "QCBaseTableVM.h"

@class QCGroupApprovalListVM;

NS_ASSUME_NONNULL_BEGIN

@protocol QCGroupApprovalListVMDelegate <NSObject>

@optional

/// 点击某条审批记录
- (void)groupApprovalListVM:(QCGroupApprovalListVM *)vm didSelectInviteNo:(NSString *)inviteNo;

@end

@interface QCGroupApprovalListVM : QCBaseTableVM

@property(nonatomic, weak) id<QCGroupApprovalListVMDelegate> delegate;

@property(nonatomic, strong) QCChannel *channel;

@end

NS_ASSUME_NONNULL_END
