//
//  QCRobotDB.h
//  QCIM
//
//  Created by tt on 2021/10/19.
//

#import <Foundation/Foundation.h>
#import "QCRobot.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCRobotDB : NSObject

+ (QCRobotDB *)shared;

/// 查询robot
-(NSArray<QCRobot*>*) queryRobots:(NSArray<NSString*>*)robotIDs;

-(void) addOrUpdateRobots:(NSArray<QCRobot*>*)robots;

-(QCRobot*) queryRobotWithUsername:(NSString*)username;

-(NSArray<QCRobot*>*) queryRobotsWithUsernames:(NSArray<NSString*>*)usernames;


@end

NS_ASSUME_NONNULL_END
