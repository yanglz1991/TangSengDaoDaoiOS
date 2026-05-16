//
//  QCRobotManager.h
//  WuKongIMSDK
//
//  Created by tt on 2021/10/19.
//

#import <Foundation/Foundation.h>
#import "QCRobot.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^QCSyncRobotCallback)(NSArray<QCRobot*>* __nullable robots,NSError * __nullable error);
typedef void(^QCSyncRobotProvider)(NSArray<NSDictionary*> *robotVersionDicts,QCSyncRobotCallback callback);

@interface QCRobotManager : NSObject

+ (QCRobotManager *)shared;

/// 机器人数据提供者
@property(nonatomic,copy) QCSyncRobotProvider syncRobotProvider;

// 通过机器人id同步机器人
-(void) sync:(NSArray<NSString*>*)robotIDs complete:(void(^)(BOOL hasData,NSError *error))complete;

// 通过username同步机器人
-(void) syncWithUsernames:(NSArray<NSString*>*)usernames complete:(void(^)(BOOL hasData,NSError *error))complete;

/**
 获取机器人（通过username）
 @param username 机器人的用户名
 */
-(QCRobot*) getRobotWithUsername:(NSString*)username;

@end

NS_ASSUME_NONNULL_END
