//
//  QCGroupApprovalCell.h
//  WuKongGroupManager
//
//  群邀请审批记录列表 cell
//

#import "QCFormItemCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface QCGroupApprovalModel : QCFormItemModel

/// 邀请编号
@property(nonatomic, copy) NSString *inviteNo;

/// 邀请者头像 URL
@property(nonatomic, copy, nullable) NSString *avatarURL;

/// 邀请者名称
@property(nonatomic, copy) NSString *inviterName;

/// 创建时间字符串
@property(nonatomic, copy, nullable) NSString *createdAt;

/// 主要内容（包含邀请人数 + 被邀请成员名称）
@property(nonatomic, copy) NSString *content;

/// 备注（可空）
@property(nonatomic, copy, nullable) NSString *remark;

@end

@interface QCGroupApprovalCell : QCFormItemCell

@end

NS_ASSUME_NONNULL_END
