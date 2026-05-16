//
//  QCChannelMemberDB.h
//  QCIM
//
//  Created by tt on 2020/1/20.
//

#import <Foundation/Foundation.h>
#import "QCChannel.h"
NS_ASSUME_NONNULL_BEGIN

// 成员角色
typedef enum : NSUInteger {
    QCMemberRoleCommon, // 普通成员
    QCMemberRoleCreator, // 创建者
    QCMemberRoleManager, // 管理员
} QCMemberRole;

// 成员状态
typedef enum : NSUInteger {
    QCMemberStatusUnknown,
    QCMemberStatusNormal, // 正常
    QCMemberStatusBlacklist, // 被拉入黑名单
} QCMemberStatus;

@interface QCChannelMember : NSObject

@property(nonatomic,copy)    NSString *channelId; // 频道ID
@property(nonatomic,assign)  uint8_t channelType; // 频道类型
@property(nonatomic,copy) NSString *memberAvatar; // 成员头像
@property(nonatomic,copy)    NSString *memberUid; // 成员uid
@property(nonatomic,copy)    NSString *memberName; // 成员名称
@property(nonatomic,copy)    NSString *memberRemark; // 成员备注

@property(nonatomic,copy,readonly) NSString *displayName;

@property(nonatomic,assign)  QCMemberRole  role; // 成员角色
@property(nonatomic,assign) QCMemberStatus status; // 成员状态

@property(nonatomic,strong) NSNumber *version; // 版本
@property(nonatomic,strong) NSMutableDictionary *extra; // 扩展字段

@property(nonatomic,strong) NSString *createdAt; // 成员加入时间
@property(nonatomic,strong) NSString *updatedAt; // 成员数据最后一次更新时间

@property(nonatomic,assign) BOOL robot; // 是否是机器人
@property(nonatomic,assign) BOOL isDeleted; // 是否已删除

@end

@interface QCChannelMemberDB : NSObject

+ (QCChannelMemberDB *)shared;


/**
 添加或更新成员

 @param members <#members description#>
 */
-(void) addOrUpdateMembers:(NSArray<QCChannelMember*>*)members;


/// 删除频道成员
/// @param channel <#channel description#>
-(void) deleteMembers:(QCChannel*)channel;

/**
 获取频道的成员最新同步key

 @param channel 频道信息
 @return <#return value description#>
 */
-(NSString*) getMemberLastSyncKey:(QCChannel*)channel;


/**
 获取频道对应的成员列表

 @param channel 频道
 @return <#return value description#>
 */
-(NSArray<QCChannelMember*>*) getMembersWithChannel:(QCChannel*)channel;

/**
  获取频道成员集合
 @param channel 频道对象
 @param limit 数量限制
 */
-(NSArray<QCChannelMember*>*) getMembersWithChannel:(QCChannel*)channel limit:(NSInteger)limit;

/**
 获取频道成员集合（分页查询）
 @param channel 频道对象
 @param keyword 名字关键字筛选 为空则不做为条件筛选
 @page page 页码 从1开始
 @param limit 数量限制
 */
-(NSArray<QCChannelMember*>*) getMembersWithChannel:(QCChannel*)channel keyword:(NSString*)keyword page:(NSInteger)page limit:(NSInteger)limit;
-(NSArray<QCChannelMember*>*) getMembersWithChannel:(QCChannel*)channel role:(QCMemberRole)role;

/// 获取群内的黑名单成员
/// @param channel <#channel description#>
-(NSArray<QCChannelMember*>*) getBlacklistMembersWithChannel:(QCChannel*)channel;


/// 获取管理员和创建者列表
/// @param channel 频道
-(NSArray<QCChannelMember*>*) getManagerAndCreator:(QCChannel*)channel;

/**
 获取频道内指定uid的成员列表

 @param channel <#channel description#>
 @param uids <#uids description#>
 @return <#return value description#>
 */
-(NSArray<QCChannelMember*>*) getMembersWithChannel:(QCChannel*)channel uids:(NSArray<NSString*>*)uids;


/**
  更新指定用户的成员状态
@param status 成员状态
@param channel 频道
@param uids 成员uid集合
 */
-(void) updateMemberStatus:(QCMemberStatus)status channel:(QCChannel*) channel  uids:(NSArray<NSString*>*)uids;

/**
 是否是管理员 （群主或管理者）

 @param channel 频道
 @param uid 用户UID
 @return <#return value description#>
 */
-(BOOL) isManager:(QCChannel*)channel memberUID:(NSString*)uid;


/**
 是否是创建者

 @param channel 频道
 @param uid 用户UID
 @return <#return value description#>
 */
-(BOOL) isCreator:(QCChannel*)channel memberUID:(NSString*)uid;


/// 成员是否存在频道里
/// @param channel 频道对象
/// @param uid 成员uid
-(BOOL) exist:(QCChannel*)channel uid:(NSString*)uid;

/**
 获取指定的成员信息

 @param channel 频道
 @param uid 成员UID
 @return 成员信息
 */
- (QCChannelMember*)get:(QCChannel*)channel  memberUID:(NSString *)uid;

/**
 获取成员数量
 */
-(NSInteger) getMemberCount:(QCChannel*)channel;
@end

NS_ASSUME_NONNULL_END
