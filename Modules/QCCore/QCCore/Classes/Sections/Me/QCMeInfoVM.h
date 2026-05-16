//
//  QCMeInfoVM.h
//  QCCore
//
//  Created by tt on 2020/6/23.
//

#import "QCCore.h"

NS_ASSUME_NONNULL_BEGIN
@class QCMeInfoVM;
@protocol QCMeInfoDelegate<NSObject>

@optional


/// 修改名字
/// @param vm <#vm description#>
-(void) meInfoVMUpdateName:(QCMeInfoVM*)vm;

/// 修改性别
/// @param vm <#vm description#>
-(void) meInfoVMUpdateSex:(QCMeInfoVM*)vm;

/// 修改短编号
/// @param vm <#vm description#>
-(void) meInfoVMUpdateShortNo:(QCMeInfoVM*)vm;

@end

@interface QCMeInfoVM : QCBaseTableVM

@property(nonatomic,weak) id<QCMeInfoDelegate> delegate;


/// 更新我的个人信息
/// @param field 属性
/// @param value 值
-(AnyPromise*) updateInfo:(NSString*)field value:(NSString*)value;

@end

NS_ASSUME_NONNULL_END
