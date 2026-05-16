//
//  QCGroupBlacklistVM.h
//  WuKongBase
//
//  Created by tt on 2020/10/19.
//

#import "QCBaseTableVM.h"
@class QCGroupBlacklistVM;
NS_ASSUME_NONNULL_BEGIN

@protocol QCGroupBlacklistVMDelegate <NSObject>

@optional


/// 移除黑名单
/// @param vm <#vm description#>
-(void) groupBlacklistVMRemoveBlacklist:(QCGroupBlacklistVM*)vm member:(QCChannelMember*)member;

@end

@interface QCGroupBlacklistVM : QCBaseTableVM

@property(nonatomic,weak) id<QCGroupBlacklistVMDelegate> delegate;

@property(nonatomic,strong) QCChannel *channel;

// 添加或移除黑名单
-(void) addOrRemoveBlacklist:(NSString*)action uids:(NSArray<NSString*>*)uids;

@end

NS_ASSUME_NONNULL_END
