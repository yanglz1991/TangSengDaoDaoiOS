//
//  QCChannelInfoDB.h
//  QCIM
//
//  Created by tt on 2019/12/23.
//

#import <Foundation/Foundation.h>
#import "QCChannelInfo.h"
#import "QCDB.h"
#import "QCChannelInfoSearchResult.h"
#import "QCChannelMessageSearchResult.h"
NS_ASSUME_NONNULL_BEGIN

// 频道在线状态
typedef enum : NSUInteger {
    QCOnlineStatusOffline, // 离线
    QCOnlineStatusOnline, // 在线
} QCOnlineStatus;

// 频道状态
typedef enum : NSUInteger {
    QCChannelStatusUnkown,
    QCChannelStatusNormal,
    QCChannelStatusBlacklist,
} QCChannelStatus;

@interface QCChannelInfoDB : NSObject
+ (QCChannelInfoDB *)shared;

/**
 保存频道信息

 @param channelInfo 频道信息
 @return <#return value description#>
 */
-(BOOL) saveChannelInfo:(QCChannelInfo*)channelInfo;


/**
 批量修改或添加频道信息

 @param channelInfos <#channelInfos description#>
 @return 已存在的旧的频道信息集合
 */
-(NSArray<QCChannelInfo*>*) addOrUpdateChannelInfos:(NSArray<QCChannelInfo*>*)channelInfos;

/**
 更新频道信息

 @param channelInfo <#channelInfo description#>
 */
-(void) updateChannelInfo:(QCChannelInfo*)channelInfo;




/// 更新在线状态
/// @param channel 指定的频道
/// @param status 在线状态
/// @param lastOffline 最后一次离线时间
-(void) updateChannelOnlineStatus:(QCChannel*)channel status:(QCOnlineStatus)status lastOffline:(NSTimeInterval)lastOffline;

/**
  更新在线状态
 @param channel 指定的频道
 @param status 在线状态
 @param lastOffline 最后一次离线时间
 @param mainDeviceFlag 在线的主设备
 */
-(void) updateChannelOnlineStatus:(QCChannel*)channel status:(QCOnlineStatus)status lastOffline:(NSTimeInterval)lastOffline mainDeviceFlag:(QCDeviceFlagEnum)mainDeviceFlag;


/// 删除频道信息
/// @param channel <#channel description#>
-(void) deleteChannelInfo:(QCChannel*)channel;

/**
 获取频道信息

 @param channel 频道
 @return <#return value description#>
 */
-(QCChannelInfo*) queryChannelInfo:(QCChannel*)channel;
-(QCChannelInfo*) queryChannelInfo:(QCChannel*)channel  db:(FMDatabase*)db;


/// 通过状态查询频道信息
/// @param status 0.正常 2.黑明单
-(NSArray<QCChannelInfo*>*) queryChannelInfosWithStatus:(QCChannelStatus)status;


/// 通过状态和关注类型查询频道集合
/// @param status 状态
/// @param follow <#follow description#>
-(NSArray<QCChannelInfo*>*) queryChannelInfosWithStatusAndFollow:(QCChannelStatus)status follow:(QCChannelInfoFollow)follow;


/// 获取跟我好友关系的频道数据
/// @param keyword 关键字
/// @param limit 数量限制
-(NSArray<QCChannelInfo*>*) queryChannelInfoWithFriend:(NSString*)keyword limit:(NSInteger)limit;



/// 查询所有在线的频道
-(NSArray<QCChannelInfo*>*) queryChannelOnlines;

/// 搜索频道信息
/// @param keyword 频道关键字
/// @param channelType 频道类型
/// @param limit 数量限制
-(NSArray<QCChannelInfoSearchResult*>*) searchChannelInfoWithKeyword:(NSString*)keyword channelType:(uint8_t)channelType limit:(NSInteger)limit;


/// 搜索频道信息
/// @param keyword 频道关键字
/// @param limit 数量限制

-(NSArray<QCChannelMessageSearchResult*>*) searchChannelMessageWithKeyword:(NSString*)keyword  limit:(NSInteger)limit;

/// 查询频道
/// @param keyword 关键字
/// @param channelType 频道类型
/// @param limit 数量限制
-(NSArray<QCChannelInfo*>*) queryChannelInfoWithType:(NSString*)keyword channelType:(uint8_t)channelType limit:(NSInteger)limit;


/**
 查询最近会话的频道
 */
-(NSArray<QCChannelInfo*>*) queryAllConversationChannelInfos;
@end

NS_ASSUME_NONNULL_END
