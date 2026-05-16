//
//  QCConversationView+Robot.h
//  WuKongBase
//
//  Created by tt on 2022/5/20.
//

#import "QCConversationView.h"

NS_ASSUME_NONNULL_BEGIN

@interface QCConversationView (Robot)

-(void) initRobot;

-(void) syncRobot:(NSArray<NSString*>*) robotIDs;

-(void) adjustRobotMenusIfNeed;

@end

NS_ASSUME_NONNULL_END
