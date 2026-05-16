//
//  QCConversationListSelectVM.m
//  WuKongBase
//
//  Created by tt on 2020/9/28.
//

#import "QCConversationListSelectVM.h"
#import "QCConversationListSelectCell.h"
#import "QCConversationWrapModel.h"
#import "QCAPIClient.h"

/**
 * 内部统一选项结构,屏蔽数据源差异(最近会话/群组接口/好友 channelInfo)
 */
@interface QCConversationListSelectItem : NSObject
@property(nonatomic,strong) QCChannel *channel;
@property(nonatomic,copy) NSString *title;
@property(nonatomic,copy) NSString *iconURL;
@property(nonatomic,assign) BOOL forbidden; // 全员禁言中
@property(nonatomic,assign) NSInteger sortKey;
@property(nonatomic,assign) BOOL stick;
@end

@implementation QCConversationListSelectItem
@end


@interface QCConversationListSelectVM ()
@property(nonatomic,strong) NSMutableArray<QCConversationListSelectItem*> *recentItems;
@property(nonatomic,strong) NSMutableArray<QCConversationListSelectItem*> *groupItems;
@property(nonatomic,strong) NSMutableArray<QCConversationListSelectItem*> *friendItems;

@property(nonatomic,strong) NSMutableArray<QCChannel*> *selectedChannels;
@property(nonatomic,assign,readwrite) QCConversationListSelectTab currentTab;
@property(nonatomic,assign) BOOL groupsLoaded;
@property(nonatomic,assign) BOOL friendsLoaded;
@end

@implementation QCConversationListSelectVM

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentTab = QCConversationListSelectTabRecent;
        _recentItems = [NSMutableArray array];
        _groupItems = [NSMutableArray array];
        _friendItems = [NSMutableArray array];
    }
    return self;
}

- (NSMutableArray<QCChannel *> *)selectedChannels {
    if(!_selectedChannels) {
        _selectedChannels = [NSMutableArray array];
    }
    return _selectedChannels;
}

- (NSArray<QCChannel *> *)selectedChannelsArray {
    return [self.selectedChannels copy];
}

- (NSArray<QCConversationListSelectItem *> *)currentItems {
    switch (self.currentTab) {
        case QCConversationListSelectTabGroup:  return self.groupItems;
        case QCConversationListSelectTabFriend: return self.friendItems;
        case QCConversationListSelectTabRecent:
        default: return self.recentItems;
    }
}

- (NSArray<QCConversationListSelectItem *> *)filteredItems {
    NSArray<QCConversationListSelectItem*> *src = [self currentItems];
    if (self.keyword.length == 0) return src;
    NSString *kw = [self.keyword lowercaseString];
    NSMutableArray *result = [NSMutableArray array];
    for (QCConversationListSelectItem *it in src) {
        if (it.title && [[it.title lowercaseString] rangeOfString:kw].location != NSNotFound) {
            [result addObject:it];
        }
    }
    return result;
}

- (NSArray<NSDictionary *> *)tableSectionMaps {
    NSMutableArray *items = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    NSArray<QCConversationListSelectItem*> *list = [self filteredItems];
    for (QCConversationListSelectItem *it in list) {
        QCChannel *channel = it.channel;
        BOOL selected = [weakSelf isChannelSelected:channel];
        NSString *value = it.forbidden ? LLang(@"全员禁言中") : @"";
        [items addObject:@{
            @"class": QCConversationListSelectModel.class,
            @"title": it.title?:@"",
            @"iconURL": it.iconURL?:@"",
            @"circular": @(true),
            @"selected": @(selected),
            @"multiple": @(self.multiple),
            @"extra": channel?:[NSNull null],
            @"value": value,
            @"onClick": ^{
                if (it.forbidden) return;
                if (!channel) return;
                if (weakSelf.multiple) {
                    [weakSelf toggleChannel:channel];
                    [weakSelf reloadData];
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(conversationListSelectVM:selectedChanged:)]) {
                        [weakSelf.delegate conversationListSelectVM:weakSelf selectedChanged:[weakSelf selectedChannelsArray]];
                    }
                } else {
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(conversationListSelectVM:didSelected:)]) {
                        [weakSelf.delegate conversationListSelectVM:weakSelf didSelected:@[channel]];
                    }
                }
            }
        }];
    }
    return @[@{
        @"height": @(0.01f),
        @"items": items,
    }];
}

- (BOOL)isChannelSelected:(QCChannel*)channel {
    for (QCChannel *c in self.selectedChannels) {
        if (c.channelType == channel.channelType && [c.channelId isEqualToString:channel.channelId]) {
            return YES;
        }
    }
    return NO;
}

- (void)toggleChannel:(QCChannel*)channel {
    NSInteger foundIdx = NSNotFound;
    for (NSInteger i = 0; i < self.selectedChannels.count; i++) {
        QCChannel *c = self.selectedChannels[i];
        if (c.channelType == channel.channelType && [c.channelId isEqualToString:channel.channelId]) {
            foundIdx = i;
            break;
        }
    }
    if (foundIdx != NSNotFound) {
        [self.selectedChannels removeObjectAtIndex:foundIdx];
    } else {
        [self.selectedChannels addObject:channel];
    }
}

- (void)commitSelection {
    if (self.selectedChannels.count == 0) return;
    if (self.delegate && [self.delegate respondsToSelector:@selector(conversationListSelectVM:didSelected:)]) {
        [self.delegate conversationListSelectVM:self didSelected:[self selectedChannelsArray]];
    }
}

#pragma mark - 当前 Tab 全选 / 取消全选

// 仅统计可被选择(非禁言、且 channel 非空)的项
- (NSArray<QCChannel*>*)currentTabSelectableChannels {
    NSMutableArray<QCChannel*> *result = [NSMutableArray array];
    for (QCConversationListSelectItem *it in [self filteredItems]) {
        if (!it.channel) continue;
        if (it.forbidden) continue;
        [result addObject:it.channel];
    }
    return result;
}

- (NSInteger)currentTabSelectableCount {
    return [self currentTabSelectableChannels].count;
}

- (NSInteger)currentTabSelectedCount {
    NSInteger n = 0;
    for (QCChannel *ch in [self currentTabSelectableChannels]) {
        if ([self isChannelSelected:ch]) n++;
    }
    return n;
}

- (BOOL)isCurrentTabAllSelected {
    NSArray<QCChannel*> *list = [self currentTabSelectableChannels];
    if (list.count == 0) return NO;
    for (QCChannel *ch in list) {
        if (![self isChannelSelected:ch]) return NO;
    }
    return YES;
}

- (void)toggleSelectAllCurrentTab {
    NSArray<QCChannel*> *list = [self currentTabSelectableChannels];
    if (list.count == 0) return;
    BOOL allSelected = [self isCurrentTabAllSelected];
    if (allSelected) {
        // 移除当前可见列表里的所有 channel
        NSMutableArray<QCChannel*> *remaining = [NSMutableArray array];
        for (QCChannel *sc in self.selectedChannels) {
            BOOL hit = NO;
            for (QCChannel *ch in list) {
                if (sc.channelType == ch.channelType && [sc.channelId isEqualToString:ch.channelId]) {
                    hit = YES;
                    break;
                }
            }
            if (!hit) [remaining addObject:sc];
        }
        [self.selectedChannels removeAllObjects];
        [self.selectedChannels addObjectsFromArray:remaining];
    } else {
        // 把当前可见列表里未选的 channel 追加(去重)
        for (QCChannel *ch in list) {
            if (![self isChannelSelected:ch]) {
                [self.selectedChannels addObject:ch];
            }
        }
    }
    [self reloadData];
    if (self.delegate && [self.delegate respondsToSelector:@selector(conversationListSelectVM:selectedChanged:)]) {
        [self.delegate conversationListSelectVM:self selectedChanged:[self selectedChannelsArray]];
    }
}

- (void)switchTab:(QCConversationListSelectTab)tab {
    if (self.currentTab == tab) return;
    self.currentTab = tab;
    [self reloadData];
    if (tab == QCConversationListSelectTabGroup && !self.groupsLoaded) {
        [self loadGroups];
    } else if (tab == QCConversationListSelectTabFriend && !self.friendsLoaded) {
        [self loadFriends];
    }
    [self notifySelectionChanged];
}

- (void)setKeyword:(NSString *)keyword {
    _keyword = [keyword copy];
    [self reloadData];
}

#pragma mark - 数据加载

- (void)requestData:(void (^)(NSError * _Nullable))complete {
    [self loadRecent];
    // 群组/好友 在切到对应 Tab 时再加载,避免不必要的请求
    complete(nil);
}

- (void)loadRecent {
    [self.recentItems removeAllObjects];
    NSArray<QCConversation*> *conversations = [[[QCSDK shared] conversationManager] getConversationList];
    NSMutableArray<QCConversationWrapModel*> *wraps = [NSMutableArray array];
    if (conversations) {
        for (QCConversation *conv in conversations) {
            QCConversationWrapModel *w = [[QCConversationWrapModel alloc] initWithConversation:conv];
            [wraps addObject:w];
        }
        [self sortConversationList:wraps];
    }
    for (QCConversationWrapModel *w in wraps) {
        QCConversationListSelectItem *item = [QCConversationListSelectItem new];
        item.channel = w.channel;
        if (w.channelInfo) {
            item.title = w.channelInfo.displayName;
            item.iconURL = [QCAvatarUtil getFullAvatarWIthPath:w.channelInfo.logo];
            item.forbidden = [self isChannelForbidden:w.channelInfo];
        } else {
            [w startChannelRequest];
            item.title = @"";
            item.iconURL = @"";
        }
        item.stick = w.stick;
        item.sortKey = (NSInteger)w.lastMsgTimestamp;
        [self.recentItems addObject:item];
    }
}

- (void)loadGroups {
    __weak typeof(self) weakSelf = self;
    // 后端 /group/my 仅返回 save=1 的群,不是"我加入的所有群"。
    // 因此先收集本地会话中的群,再用接口补充未在会话中的已保存群,channelID 去重。
    [self.groupItems removeAllObjects];
    NSMutableSet *seen = [NSMutableSet set];

    // 1. 本地会话里的群
    NSArray<QCConversation*> *conversations = [[[QCSDK shared] conversationManager] getConversationList];
    if (conversations) {
        for (QCConversation *conv in conversations) {
            if (conv.channel.channelType != WK_GROUP) continue;
            NSString *channelId = conv.channel.channelId;
            if (channelId.length == 0) continue;
            if ([seen containsObject:channelId]) continue;
            [seen addObject:channelId];
            QCConversationListSelectItem *item = [QCConversationListSelectItem new];
            item.channel = conv.channel;
            QCChannelInfo *info = [[QCSDK shared].channelManager getChannelInfo:conv.channel];
            if (info) {
                item.title = info.displayName;
                item.iconURL = [QCAvatarUtil getFullAvatarWIthPath:info.logo];
            } else {
                item.title = channelId;
                item.iconURL = [QCAvatarUtil getAvatar:channelId];
                [[QCSDK shared].channelManager fetchChannelInfo:conv.channel];
            }
            item.forbidden = NO;
            [self.groupItems addObject:item];
        }
    }
    // 接口未返回前先渲染本地会话部分
    if (self.currentTab == QCConversationListSelectTabGroup) {
        [self reloadData];
    }

    // 2. 拉接口已保存的群,补充
    [[QCAPIClient sharedClient] GET:@"group/my" parameters:@{@"page_size": @(1000)}].then(^(id result){
        NSArray *array = nil;
        if ([result isKindOfClass:[NSArray class]]) {
            array = result;
        } else if ([result isKindOfClass:[NSDictionary class]] && ((NSDictionary*)result)[@"list"]) {
            array = ((NSDictionary*)result)[@"list"];
        }
        if (array) {
            for (NSDictionary *dic in array) {
                if (![dic isKindOfClass:[NSDictionary class]]) continue;
                NSString *groupNo = dic[@"group_no"];
                if (groupNo.length == 0) continue;
                if ([seen containsObject:groupNo]) continue;
                [seen addObject:groupNo];
                NSString *name = dic[@"name"]?:@"";
                NSString *remark = dic[@"remark"]?:@"";
                QCChannel *channel = [QCChannel groupWithChannelID:groupNo];
                QCConversationListSelectItem *item = [QCConversationListSelectItem new];
                item.channel = channel;
                QCChannelInfo *info = [[QCSDK shared].channelManager getChannelInfo:channel];
                if (info) {
                    item.title = info.displayName;
                    item.iconURL = [QCAvatarUtil getFullAvatarWIthPath:info.logo];
                } else {
                    item.title = remark.length > 0 ? remark : name;
                    item.iconURL = [QCAvatarUtil getAvatar:groupNo];
                    [[QCSDK shared].channelManager fetchChannelInfo:channel];
                }
                item.forbidden = NO;
                [weakSelf.groupItems addObject:item];
            }
        }
        weakSelf.groupsLoaded = YES;
        if (weakSelf.currentTab == QCConversationListSelectTabGroup) {
            [weakSelf reloadData];
            [weakSelf notifySelectionChanged];
        }
    }).catch(^(NSError *error){
        weakSelf.groupsLoaded = YES;
        if (weakSelf.currentTab == QCConversationListSelectTabGroup) {
            [weakSelf reloadData];
            [weakSelf notifySelectionChanged];
        }
    });
}

- (void)loadFriends {
    [self.friendItems removeAllObjects];
    NSArray<QCChannelInfo*> *channelInfos = [[QCChannelInfoDB shared] queryChannelInfosWithStatusAndFollow:QCChannelStatusNormal follow:QCChannelInfoFollowFriend];
    if (channelInfos) {
        for (QCChannelInfo *info in channelInfos) {
            if (info.channel.channelType != WK_PERSON) continue;
            QCConversationListSelectItem *item = [QCConversationListSelectItem new];
            item.channel = info.channel;
            item.title = info.displayName;
            item.iconURL = [QCAvatarUtil getFullAvatarWIthPath:info.logo];
            item.forbidden = NO;
            [self.friendItems addObject:item];
        }
    }
    self.friendsLoaded = YES;
    if (self.currentTab == QCConversationListSelectTabFriend) {
        [self reloadData];
        [self notifySelectionChanged];
    }
}

// 通知外部（VC）选中集合 / 当前 Tab 可选项变化，用于刷新全选工具行与确认按钮文案
- (void)notifySelectionChanged {
    if (self.delegate && [self.delegate respondsToSelector:@selector(conversationListSelectVM:selectedChanged:)]) {
        [self.delegate conversationListSelectVM:self selectedChanged:[self selectedChannelsArray]];
    }
}

- (BOOL)isChannelForbidden:(QCChannelInfo*)channelInfo {
    if (!channelInfo) return NO;
    if (channelInfo.forbidden) {
        // 管理员允许发言
        return ![[QCSDK shared].channelManager isManager:channelInfo.channel memberUID:[QCApp shared].loginInfo.uid];
    }
    return NO;
}

-(void) sortConversationList:(NSMutableArray<QCConversationWrapModel*>*) conversationWrapModels{
    [conversationWrapModels sortUsingComparator:^NSComparisonResult(QCConversationWrapModel   *obj1, QCConversationWrapModel   *obj2) {
        if(obj1.stick && !obj2.stick) return NSOrderedAscending;
        if(obj2.stick && !obj1.stick) return NSOrderedDescending;
        if(obj1.lastMsgTimestamp < obj2.lastMsgTimestamp) return NSOrderedDescending;
        if(obj1.lastMsgTimestamp == obj2.lastMsgTimestamp) return NSOrderedSame;
        return NSOrderedAscending;
    }];
}

@end
