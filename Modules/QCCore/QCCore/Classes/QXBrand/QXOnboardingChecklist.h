//
//  QXOnboardingChecklist.h
//  QCCore
//
//  喜聊新用户引导清单。维护一组"完成度任务"（设置头像、添加首位
//  好友、加入兴趣群、开启二步验证 ...），并暴露完成度进度供
//  设置/我页面展示。状态本地化保存。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const QXOnboardingTaskAvatar;
extern NSString * const QXOnboardingTaskNickname;
extern NSString * const QXOnboardingTaskFirstFriend;
extern NSString * const QXOnboardingTaskFirstGroup;
extern NSString * const QXOnboardingTaskFirstMessage;
extern NSString * const QXOnboardingTaskTwoFactor;
extern NSString * const QXOnboardingTaskBackup;

@interface QXOnboardingTask : NSObject
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, assign) BOOL completed;
@property (nonatomic, assign) NSInteger orderIndex;
@property (nonatomic, copy) NSString *iconAsset;
@end

@interface QXOnboardingChecklist : NSObject

+ (instancetype)sharedChecklist;

- (NSArray<QXOnboardingTask *> *)allTasks;
- (NSArray<QXOnboardingTask *> *)pendingTasks;
- (NSArray<QXOnboardingTask *> *)completedTasks;

- (CGFloat)completionRatio;     // 0~1
- (NSInteger)completedCount;
- (NSInteger)totalCount;

- (void)markTaskCompleted:(NSString *)identifier;
- (void)markTaskUncompleted:(NSString *)identifier;
- (BOOL)isTaskCompleted:(NSString *)identifier;
- (void)resetAll;

@end

NS_ASSUME_NONNULL_END
