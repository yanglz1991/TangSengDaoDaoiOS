//
//  WKGroupApprovalListVM.h
//  WuKongGroupManager
//
//  群邀请审批记录列表 VM
//

#import "WKBaseTableVM.h"

@class WKGroupApprovalListVM;

NS_ASSUME_NONNULL_BEGIN

@protocol WKGroupApprovalListVMDelegate <NSObject>

@optional

/// 点击某条审批记录
- (void)groupApprovalListVM:(WKGroupApprovalListVM *)vm didSelectInviteNo:(NSString *)inviteNo;

@end

@interface WKGroupApprovalListVM : WKBaseTableVM

@property(nonatomic, weak) id<WKGroupApprovalListVMDelegate> delegate;

@property(nonatomic, strong) WKChannel *channel;

@end

NS_ASSUME_NONNULL_END
