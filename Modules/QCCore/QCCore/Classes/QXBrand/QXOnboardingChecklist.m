//
//  QXOnboardingChecklist.m
//  QCCore
//

#import "QXOnboardingChecklist.h"

NSString * const QXOnboardingTaskAvatar       = @"onboarding.avatar";
NSString * const QXOnboardingTaskNickname     = @"onboarding.nickname";
NSString * const QXOnboardingTaskFirstFriend  = @"onboarding.first_friend";
NSString * const QXOnboardingTaskFirstGroup   = @"onboarding.first_group";
NSString * const QXOnboardingTaskFirstMessage = @"onboarding.first_message";
NSString * const QXOnboardingTaskTwoFactor    = @"onboarding.two_factor";
NSString * const QXOnboardingTaskBackup       = @"onboarding.backup";

static NSString * const kQXOnboardingDefaultsPrefix = @"QXOnboarding.";

@implementation QXOnboardingTask
@end

@interface QXOnboardingChecklist ()
@property (nonatomic, copy) NSArray<QXOnboardingTask *> *tasks;
@end

@implementation QXOnboardingChecklist

+ (instancetype)sharedChecklist {
    static QXOnboardingChecklist *c = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        c = [QXOnboardingChecklist new];
    });
    return c;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self buildTasks];
    }
    return self;
}

- (void)buildTasks {
    NSArray *defs = @[
        @[QXOnboardingTaskAvatar,       @"设置头像",     @"上传一张你喜欢的头像，让朋友更容易认出你。", @(0)],
        @[QXOnboardingTaskNickname,     @"完善昵称",     @"为你的账号取一个有特色的昵称。",         @(1)],
        @[QXOnboardingTaskFirstFriend,  @"添加第一位好友", @"通过手机号或扫一扫添加你的第一位好友。", @(2)],
        @[QXOnboardingTaskFirstGroup,   @"加入第一个群",  @"加入一个公开群，参与你感兴趣的话题。",   @(3)],
        @[QXOnboardingTaskFirstMessage, @"发送首条消息",  @"和朋友说一声「禧语见」吧。",           @(4)],
        @[QXOnboardingTaskTwoFactor,    @"开启二步验证",  @"为账号增加一道安全屏障。",             @(5)],
        @[QXOnboardingTaskBackup,       @"启用聊天备份",  @"开启加密备份，避免重装时丢失记录。",     @(6)],
    ];
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:defs.count];
    for (NSArray *row in defs) {
        QXOnboardingTask *t = [QXOnboardingTask new];
        t.identifier = row[0];
        t.title      = row[1];
        t.desc       = row[2];
        t.orderIndex = [row[3] integerValue];
        t.completed  = [self isTaskCompleted:t.identifier];
        t.iconAsset  = [NSString stringWithFormat:@"onboarding_%@", t.identifier];
        [list addObject:t];
    }
    self.tasks = [list copy];
}

- (NSArray<QXOnboardingTask *> *)allTasks {
    [self refreshState];
    return self.tasks;
}

- (NSArray<QXOnboardingTask *> *)pendingTasks {
    [self refreshState];
    NSMutableArray *out = [NSMutableArray array];
    for (QXOnboardingTask *t in self.tasks) {
        if (!t.completed) {
            [out addObject:t];
        }
    }
    return [out copy];
}

- (NSArray<QXOnboardingTask *> *)completedTasks {
    [self refreshState];
    NSMutableArray *out = [NSMutableArray array];
    for (QXOnboardingTask *t in self.tasks) {
        if (t.completed) {
            [out addObject:t];
        }
    }
    return [out copy];
}

- (CGFloat)completionRatio {
    NSInteger total = [self totalCount];
    if (total == 0) {
        return 0;
    }
    return (CGFloat)[self completedCount] / (CGFloat)total;
}

- (NSInteger)completedCount {
    return [self completedTasks].count;
}

- (NSInteger)totalCount {
    return self.tasks.count;
}

- (void)markTaskCompleted:(NSString *)identifier {
    if (identifier.length == 0) return;
    NSString *key = [kQXOnboardingDefaultsPrefix stringByAppendingString:identifier];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)markTaskUncompleted:(NSString *)identifier {
    if (identifier.length == 0) return;
    NSString *key = [kQXOnboardingDefaultsPrefix stringByAppendingString:identifier];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isTaskCompleted:(NSString *)identifier {
    if (identifier.length == 0) return NO;
    NSString *key = [kQXOnboardingDefaultsPrefix stringByAppendingString:identifier];
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

- (void)resetAll {
    NSArray<NSString *> *keys = [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys];
    for (NSString *k in keys) {
        if ([k hasPrefix:kQXOnboardingDefaultsPrefix]) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:k];
        }
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)refreshState {
    for (QXOnboardingTask *t in self.tasks) {
        t.completed = [self isTaskCompleted:t.identifier];
    }
}

@end
