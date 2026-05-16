//
//  QCTaskManager.h
//  WuKongIMSDK
//
//  Created by tt on 2020/1/15.
//

#import <Foundation/Foundation.h>
#import "QCTaskProto.h"
NS_ASSUME_NONNULL_BEGIN

@protocol QCTaskManagerDelegate <NSObject>

@optional


/**
 任务完成

 @param task <#task description#>
 */
-(void) taskComplete:(id<QCTaskProto>)task;


/**
 任务进度

 @param task <#task description#>
 */
-(void) taskProgress:(id<QCTaskProto>)task;

@end

@interface QCTaskManager : NSObject

@property(nonatomic,weak) id<QCTaskManagerDelegate> delegate;

/**
 添加任务

 @param task <#task description#>
 */
-(void) add:(id<QCTaskProto>)task;


/**
 获取任务

 @param taskId <#taskId description#>
 */
-(id<QCTaskProto> __nullable) get:(NSString *)taskId;
/**
 移除任务

 @param task <#task description#>
 */
-(void) remove:(id<QCTaskProto>)task;

@end

NS_ASSUME_NONNULL_END
