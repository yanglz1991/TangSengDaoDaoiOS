//
//  QCScreenPasswordSettingVM.h
//  WuKongBase
//
//  Created by tt on 2021/8/16.
//

#import <WuKongBase/WuKongBase.h>
@class QCScreenPasswordSettingVM;
NS_ASSUME_NONNULL_BEGIN
@protocol QCScreenPasswordSettingVMDelegate <NSObject>

@optional

-(void) screenPasswordSettingVMAutoLockDidClick:(QCScreenPasswordSettingVM*)vm;

// 关闭解锁密码
-(void) screenPasswordSettingVMCloseLockDidClick:(QCScreenPasswordSettingVM*)vm;

// 更改解锁密码
-(void) screenPasswordSettingVMChangeLockDidClick:(QCScreenPasswordSettingVM*)vm;

@end


@interface QCScreenPasswordSettingVM : QCBaseTableVM

@property(nonatomic,weak) id<QCScreenPasswordSettingVMDelegate> delegate;


// 获取锁定的时间描述
-(NSString*) getLockTimeDesc:(NSInteger)minute;

// 请求设置锁屏时间
-(AnyPromise*) requestSetLockAfterMinute;

// 关闭解锁密码
-(AnyPromise*) requestCloseLock;

@end

NS_ASSUME_NONNULL_END
