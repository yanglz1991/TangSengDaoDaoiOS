//
//  QCBaseTableVM.h
//  WuKongBase
//
//  Created by tt on 2020/6/21.
//

#import "QCFormSection.h"
#import "QCLabelItemCell.h"
#import "QCSwitchItemCell.h"
#import "QCButtonItemCell.h"
NS_ASSUME_NONNULL_BEGIN
@class QCBaseTableVM;
@protocol QCBaseTableVMDelegate <NSObject>



/// 重新加载数据
/// @param vm <#vm description#>
-(void) baseTableReloadData:(QCBaseTableVM*)vm;

-(void) baseTableReloadRemoteData:(QCBaseTableVM*)vm;

-(void) baseTableResetPullupState:(QCBaseTableVM*)vm;
@end

@interface QCBaseTableVM : QCBaseVM

@property(nonatomic,weak) id<QCBaseTableVMDelegate> delegateR;

// 是否启用上拉
@property(nonatomic,assign) BOOL enablePullup;

-(NSArray<QCFormSection*>*) tableSections;

-(NSArray<NSDictionary*>*) tableSectionMaps;


/// 请求数据
/// @param complete <#complete description#>
-(void) requestData:(void(^)(NSError * __nullable error))complete;


/// 上拉请求
/// @param complete <#complete description#>
-(void) pullup:(void(^)(BOOL noMore))complete;


/// 重新加载数据（触发tableview的 reloadData）
-(void) reloadData;

// 重新加载远程数据
-(void) reloadRemoteData;

// 重置上拉状态
-(void) resetPullupState;

@end

NS_ASSUME_NONNULL_END
