//
//  WKConversationListSelectVM.m
//  WuKongBase
//
//  Created by tt on 2020/9/28.
//

#import "WKConversationListSelectVM.h"
#import "WKConversationListSelectCell.h"
#import "WKConversationWrapModel.h"
#import "WKAPIClient.h"

/**
 * 内部统一选项结构,屏蔽数据源差异(最近会话/群组接口/好友 channelInfo)
 */
@interface WKConversationListSelectItem : NSObject
@property(nonatomic,strong) WKChannel *channel;
@property(nonatomic,copy) NSString *title;
@property(nonatomic,copy) NSString *iconURL;
@property(nonatomic,assign) BOOL forbidden; // 全员禁言中
@property(nonatomic,assign) NSInteger sortKey;
@property(nonatomic,assign) BOOL stick;
@end

@implementation WKConversationListSelectItem
@end


@interface WKConversationListSelectVM ()
@property(nonatomic,strong) NSMutableArray<WKConversationListSelectItem*> *recentItems;
@property(nonatomic,strong) NSMutableArray<WKConversationListSelectItem*> *groupItems;
@property(nonatomic,strong) NSMutableArray<WKConversationListSelectItem*> *friendItems;

@property(nonatomic,strong) NSMutableArray<WKChannel*> *selectedChannels;
@property(nonatomic,assign,readwrite) WKConversationListSelectTab currentTab;
@property(nonatomic,assign) BOOL groupsLoaded;
@property(nonatomic,assign) BOOL friendsLoaded;
@end

@implementation WKConversationListSelectVM

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentTab = WKConversationListSelectTabRecent;
        _recentItems = [NSMutableArray array];
        _groupItems = [NSMutableArray array];
        _friendItems = [NSMutableArray array];
    }
    return self;
}

- (NSMutableArray<WKChannel *> *)selectedChannels {
    if(!_selectedChannels) {
        _selectedChannels = [NSMutableArray array];
    }
    return _selectedChannels;
}

- (NSArray<WKChannel *> *)selectedChannelsArray {
    return [self.selectedChannels copy];
}

- (NSArray<WKConversationListSelectItem *> *)currentItems {
    switch (self.currentTab) {
        case WKConversationListSelectTabGroup:  return self.groupItems;
        case WKConversationListSelectTabFriend: return self.friendItems;
        case WKConversationListSelectTabRecent:
        default: return self.recentItems;
    }
}

- (NSArray<WKConversationListSelectItem *> *)filteredItems {
    NSArray<WKConversationListSelectItem*> *src = [self currentItems];
    if (self.keyword.length == 0) return src;
    NSString *kw = [self.keyword lowercaseString];
    NSMutableArray *result = [NSMutableArray array];
    for (WKConversationListSelectItem *it in src) {
        if (it.title && [[it.title lowercaseString] rangeOfString:kw].location != NSNotFound) {
            [result addObject:it];
        }
    }
    return result;
}

- (NSArray<NSDictionary *> *)tableSectionMaps {
    NSMutableArray *items = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    NSArray<WKConversationListSelectItem*> *list = [self filteredItems];
    for (WKConversationListSelectItem *it in list) {
        WKChannel *channel = it.channel;
        BOOL selected = [weakSelf isChannelSelected:channel];
        NSString *value = it.forbidden ? LLang(@"全员禁言中") : @"";
        [items addObject:@{
            @"class": WKConversationListSelectModel.class,
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

- (BOOL)isChannelSelected:(WKChannel*)channel {
    for (WKChannel *c in self.selectedChannels) {
        if (c.channelType == channel.channelType && [c.channelId isEqualToString:channel.channelId]) {
            return YES;
        }
    }
    return NO;
}

- (void)toggleChannel:(WKChannel*)channel {
    NSInteger foundIdx = NSNotFound;
    for (NSInteger i = 0; i < self.selectedChannels.count; i++) {
        WKChannel *c = self.selectedChannels[i];
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

- (void)switchTab:(WKConversationListSelectTab)tab {
    if (self.currentTab == tab) return;
    self.currentTab = tab;
    [self reloadData];
    if (tab == WKConversationListSelectTabGroup && !self.groupsLoaded) {
        [self loadGroups];
    } else if (tab == WKConversationListSelectTabFriend && !self.friendsLoaded) {
        [self loadFriends];
    }
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
    NSArray<WKConversation*> *conversations = [[[WKSDK shared] conversationManager] getConversationList];
    NSMutableArray<WKConversationWrapModel*> *wraps = [NSMutableArray array];
    if (conversations) {
        for (WKConversation *conv in conversations) {
            WKConversationWrapModel *w = [[WKConversationWrapModel alloc] initWithConversation:conv];
            [wraps addObject:w];
        }
        [self sortConversationList:wraps];
    }
    for (WKConversationWrapModel *w in wraps) {
        WKConversationListSelectItem *item = [WKConversationListSelectItem new];
        item.channel = w.channel;
        if (w.channelInfo) {
            item.title = w.channelInfo.displayName;
            item.iconURL = [WKAvatarUtil getFullAvatarWIthPath:w.channelInfo.logo];
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
    NSArray<WKConversation*> *conversations = [[[WKSDK shared] conversationManager] getConversationList];
    if (conversations) {
        for (WKConversation *conv in conversations) {
            if (conv.channel.channelType != WK_GROUP) continue;
            NSString *channelId = conv.channel.channelId;
            if (channelId.length == 0) continue;
            if ([seen containsObject:channelId]) continue;
            [seen addObject:channelId];
            WKConversationListSelectItem *item = [WKConversationListSelectItem new];
            item.channel = conv.channel;
            WKChannelInfo *info = [[WKSDK shared].channelManager getChannelInfo:conv.channel];
            if (info) {
                item.title = info.displayName;
                item.iconURL = [WKAvatarUtil getFullAvatarWIthPath:info.logo];
            } else {
                item.title = channelId;
                item.iconURL = [WKAvatarUtil getAvatar:channelId];
                [[WKSDK shared].channelManager fetchChannelInfo:conv.channel];
            }
            item.forbidden = NO;
            [self.groupItems addObject:item];
        }
    }
    // 接口未返回前先渲染本地会话部分
    if (self.currentTab == WKConversationListSelectTabGroup) {
        [self reloadData];
    }

    // 2. 拉接口已保存的群,补充
    [[WKAPIClient sharedClient] GET:@"group/my" parameters:@{@"page_size": @(1000)}].then(^(id result){
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
                WKChannel *channel = [WKChannel groupWithChannelID:groupNo];
                WKConversationListSelectItem *item = [WKConversationListSelectItem new];
                item.channel = channel;
                WKChannelInfo *info = [[WKSDK shared].channelManager getChannelInfo:channel];
                if (info) {
                    item.title = info.displayName;
                    item.iconURL = [WKAvatarUtil getFullAvatarWIthPath:info.logo];
                } else {
                    item.title = remark.length > 0 ? remark : name;
                    item.iconURL = [WKAvatarUtil getAvatar:groupNo];
                    [[WKSDK shared].channelManager fetchChannelInfo:channel];
                }
                item.forbidden = NO;
                [weakSelf.groupItems addObject:item];
            }
        }
        weakSelf.groupsLoaded = YES;
        if (weakSelf.currentTab == WKConversationListSelectTabGroup) {
            [weakSelf reloadData];
        }
    }).catch(^(NSError *error){
        weakSelf.groupsLoaded = YES;
        if (weakSelf.currentTab == WKConversationListSelectTabGroup) {
            [weakSelf reloadData];
        }
    });
}

- (void)loadFriends {
    [self.friendItems removeAllObjects];
    NSArray<WKChannelInfo*> *channelInfos = [[WKChannelInfoDB shared] queryChannelInfosWithStatusAndFollow:WKChannelStatusNormal follow:WKChannelInfoFollowFriend];
    if (channelInfos) {
        for (WKChannelInfo *info in channelInfos) {
            if (info.channel.channelType != WK_PERSON) continue;
            WKConversationListSelectItem *item = [WKConversationListSelectItem new];
            item.channel = info.channel;
            item.title = info.displayName;
            item.iconURL = [WKAvatarUtil getFullAvatarWIthPath:info.logo];
            item.forbidden = NO;
            [self.friendItems addObject:item];
        }
    }
    self.friendsLoaded = YES;
    if (self.currentTab == WKConversationListSelectTabFriend) {
        [self reloadData];
    }
}

- (BOOL)isChannelForbidden:(WKChannelInfo*)channelInfo {
    if (!channelInfo) return NO;
    if (channelInfo.forbidden) {
        // 管理员允许发言
        return ![[WKSDK shared].channelManager isManager:channelInfo.channel memberUID:[WKApp shared].loginInfo.uid];
    }
    return NO;
}

-(void) sortConversationList:(NSMutableArray<WKConversationWrapModel*>*) conversationWrapModels{
    [conversationWrapModels sortUsingComparator:^NSComparisonResult(WKConversationWrapModel   *obj1, WKConversationWrapModel   *obj2) {
        if(obj1.stick && !obj2.stick) return NSOrderedAscending;
        if(obj2.stick && !obj1.stick) return NSOrderedDescending;
        if(obj1.lastMsgTimestamp < obj2.lastMsgTimestamp) return NSOrderedDescending;
        if(obj1.lastMsgTimestamp == obj2.lastMsgTimestamp) return NSOrderedSame;
        return NSOrderedAscending;
    }];
}

@end
