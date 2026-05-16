//
//  QCForbiddenSpeakTimeSelectVM.h
//  WuKongBase
//
//  Created by tt on 2022/3/25.
//

#import <WuKongBase/WuKongBase.h>

NS_ASSUME_NONNULL_BEGIN

@class QCForbiddenSpeakTimeSelectVM;

@protocol QCForbiddenSpeakTimeSelectVMDelegate <NSObject>

// 自定义时间选择
-(void) forbiddenSpeakTimeSelectVMDidCustomTime:(QCForbiddenSpeakTimeSelectVM*)vm;

@end

@interface QCForbiddenSpeakTimeSelectVM : QCBaseTableVM

@property(nonatomic,copy) NSString *uid; // 禁言的用户uid
@property(nonatomic,strong) QCChannel *channel; // 用户所在频道

@property(nonatomic,assign) NSInteger selectSeconds;



@property(nonatomic,weak) id<QCForbiddenSpeakTimeSelectVMDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
