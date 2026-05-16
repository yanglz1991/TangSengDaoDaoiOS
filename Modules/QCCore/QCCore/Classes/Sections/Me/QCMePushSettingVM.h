//
//  QCMePushSettingVM.h
//  QCCore
//
//  Created by tt on 2020/6/19.
//

#import "QCCore.h"
#import "QCFormSection.h"
#import "QCBaseTableVM.h"
NS_ASSUME_NONNULL_BEGIN
@class QCMePushSettingVM;
@protocol QCMePushSettingDelegate <NSObject>

-(void) mePushSettingVMRefreshTable:(QCMePushSettingVM*)vm;

@end

@interface QCMePushSettingVM : QCBaseTableVM

@property(nonatomic,weak) id<QCMePushSettingDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
