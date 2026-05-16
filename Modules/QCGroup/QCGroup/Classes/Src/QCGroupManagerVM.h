//
//  QCGroupManagerVM.h
//  QCCore
//
//  Created by tt on 2020/3/1.
//

#import "QCBaseTableVM.h"
#import "QCFormSection.h"
#import <QCIM/QCIM.h>
#import <PromiseKit/PromiseKit.h>
NS_ASSUME_NONNULL_BEGIN
@class QCGroupManagerVM;
@protocol QCGroupManagerVMDelegate <NSObject>


/// 删除管理者
/// @param vm <#vm description#>
/// @param manager <#manager description#>
-(void) didDeleteManager:(QCGroupManagerVM*)vm manager:(QCChannelMember*)manager;


/// 群转让
/// @param vm <#vm description#>
-(void) didTransferGrouper:(QCGroupManagerVM*)vm;

@end

@interface QCGroupManagerVM : QCBaseTableVM

@property(nonatomic,weak) id<QCGroupManagerVMDelegate> delegate;

@property(nonatomic,strong) QCChannel *channel;


-(NSArray<QCFormSection*>*) getSections;


@property(nonatomic,strong) NSArray<QCChannelMember*> *members; // 成员


/// 请求转让群主
/// @param toUID <#toUID description#>
-(AnyPromise*) requestTransferGrouper:(NSString*)toUID;

/// 重新加载管理者
-(void) reloadManagerAndCreators;


/// 重新加载频道数据
-(void) reloadChannelInfo;
@end

NS_ASSUME_NONNULL_END
