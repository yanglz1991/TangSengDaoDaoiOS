//
//  WKGroupApprovalListVC.h
//  WuKongGroupManager
//
//  群邀请审批记录列表
//

#import "WKBaseTableVC.h"
#import "WKGroupApprovalListVM.h"

NS_ASSUME_NONNULL_BEGIN

@interface WKGroupApprovalListVC : WKBaseTableVC<WKGroupApprovalListVM *>

@property(nonatomic, strong) WKChannel *channel;

@end

NS_ASSUME_NONNULL_END
