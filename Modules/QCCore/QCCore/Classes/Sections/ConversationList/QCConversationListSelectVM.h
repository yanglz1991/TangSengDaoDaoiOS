//
//  QCConversationListSelectVM.h
//  QCCore
//
//  Created by tt on 2020/9/28.
//

#import <QCCore/QCCore.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, QCConversationListSelectTab) {
    QCConversationListSelectTabRecent = 0, // 最近聊天
    QCConversationListSelectTabGroup  = 1, // 群组
    QCConversationListSelectTabFriend = 2, // 好友
};

@class QCConversationListSelectVM;
@protocol QCConversationListSelectVMDelegate <NSObject>

@optional


/// 被选中的最近会话(单选/多选最终确认时回调)
/// @param vm vm
/// @param channels channels
-(void) conversationListSelectVM:(QCConversationListSelectVM*)vm didSelected:(NSArray<QCChannel*>*)channels;

/// 多选模式下,选中集合发生变化(用于 VC 实时更新底部按钮文案)
-(void) conversationListSelectVM:(QCConversationListSelectVM*)vm selectedChanged:(NSArray<QCChannel*>*)channels;

@end

@interface QCConversationListSelectVM : QCBaseTableVM

@property(nonatomic,weak) id<QCConversationListSelectVMDelegate> delegate;

/// 是否开启多选
@property(nonatomic,assign) BOOL multiple;

/// 当前 Tab(默认 QCConversationListSelectTabRecent)
@property(nonatomic,assign,readonly) QCConversationListSelectTab currentTab;

/// 当前关键字(为空表示无搜索)
@property(nonatomic,copy) NSString *keyword;

/// 切换 Tab,内部触发刷新
-(void) switchTab:(QCConversationListSelectTab)tab;

/// 获取已选频道列表
-(NSArray<QCChannel*>*) selectedChannelsArray;

/// 通过外部触发"完成"动作(多选场景下使用)
-(void) commitSelection;

/// 当前 Tab 经搜索过滤后可见的、可被选择(非禁言)的频道总数
-(NSInteger) currentTabSelectableCount;

/// 当前 Tab 已选频道数(只统计当前 Tab 列表里的)
-(NSInteger) currentTabSelectedCount;

/// 当前 Tab 是否已全部勾选
-(BOOL) isCurrentTabAllSelected;

/// 全选 / 取消全选当前 Tab(已被禁言的项不计入)
-(void) toggleSelectAllCurrentTab;

@end

NS_ASSUME_NONNULL_END
