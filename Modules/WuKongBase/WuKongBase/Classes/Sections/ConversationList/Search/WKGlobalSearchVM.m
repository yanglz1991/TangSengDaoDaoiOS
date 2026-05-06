//
//  WKGlobalSearchVM.m
//  WuKongBase
//
//  Created by tt on 2020/4/24.
//

#import "WKGlobalSearchVM.h"
#import "WKTableSectionUtil.h"
#import "WKLabelItemCell.h"
#import "WKSearchHeaderCell.h"
#import "WKSearchContactsCell.h"
#import <WuKongIMSDK/WuKongIMSDK.h>
#import "WKAvatarUtil.h"
#import "WKSearchMessageCell.h"
#import "WKSearchMoreCell.h"
#import "WKChannelMessageSearchResultVC.h"
#import "WKGlobalSearchResultController.h"
#import "WKConversationVC.h"
#import "WKSearchMediaCell.h"
#define WKSearchMaxCount 4

@interface WKGlobalSearchVM ()

@property(nonatomic,strong) NSDictionary *searchResult;

@property(nonatomic,assign) NSInteger page;
@property(nonatomic,assign) NSInteger limit;
@property(nonatomic,assign) BOOL pullup; // 是否pullup中
@property(nonatomic,assign) BOOL hasMore;// 是否有更多数据
@property(nonatomic,copy) NSString *tabType;
@property(nonatomic,assign) uint32_t localOldestOrderSeq; // 频道内本地搜索的分页游标(0 表示从最新开始)

@end

@implementation WKGlobalSearchVM

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.page = 1;
        self.tabType = @"all";
    }
    return self;
}

- (NSArray<WKFormSection *> *)tableSections {
    if(!self.searchResult) {
        return nil;
    }
    
    NSArray *items = [self handleSearchResult:self.searchResult];
    
    return  [WKTableSectionUtil toSections:items];
}

-(void) initQuery {
    self.page = 1;
    self.pullup = false;
    self.hasMore = false;
    self.localOldestOrderSeq = 0;
}

- (BOOL)searchInChannel {
    if(!self.channel) {
        return false;
    }
    return  true;
}

- (BOOL)shouldShowNoDataText {
    // 频道内聊天 tab 未输入关键字时，列表保持空白，不显示"暂无数据"提示
    if (self.searchInChannel && [self.tabType isEqualToString:@"all"] && self.keyword.length == 0) {
        return NO;
    }
    return YES;
}

-(void) changeKeyword:(NSString*)keyword {
    self.keyword = keyword;
    [self initQuery];
    [self resetPullupState];
    [self reloadRemoteData];
}

- (void)changeTabType:(NSString *)type {
    [self initQuery];
    [self resetPullupState];
    self.tabType = type;

    [self reloadRemoteData];
}

- (void)requestData:(void (^)(NSError * _Nullable))complete {
    [self search:^(NSError *error){
        complete(error);
    }];
}

- (void)pullup:(void (^)(BOOL))complete {
    self.page++;
    self.pullup = true;
    
    if(![self.tabType isEqualToString:@"all"] && ![self.tabType isEqualToString:@"file"]&&![self.tabType isEqualToString:@"media"]) {
        complete(false);
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self search:^(NSError *error){
        if(error) {
            complete(true);
            return;
        }
        complete(weakSelf.hasMore);
    }];
}

-(void) search:(void(^)(NSError * _Nullable))complete {
    __weak typeof(self) weakSelf = self;

    // 频道内查找聊天记录（all/media/file 三个 tab）改为基于本地 SDK WKMessageDB 数据库查询，
    // 避免依赖未启用的 WuKongIM 服务端搜索插件 /v1/search/global。
    if(self.searchInChannel) {
        [self localSearchInChannel:complete];
        return;
    }

    NSMutableArray<NSNumber*>  *contentTypes = [NSMutableArray array];
    BOOL onlyMessage = false;
    self.limit = 20;
    if([self.tabType isEqualToString:@"file"]) {
        onlyMessage = true;
        [contentTypes addObject:@(WK_FILE)];
    } else if ([self.tabType isEqualToString:@"media"]) { // 图片/视频
        onlyMessage = true;
        
        if([WKApp.shared hasMethod:WKPOINT_SEARCH_ITEM_VIDEO]) {
            [contentTypes addObjectsFromArray:@[@(WK_IMAGE),@(WK_SMALLVIDEO)]];
        }else {
            [contentTypes addObjectsFromArray:@[@(WK_IMAGE)]];
        }
        self.limit = 40;
    }
    
    NSString *keyword = self.keyword;
    if([self.tabType isEqualToString:@"media"]) { // 图片和视频不能通过关键字搜索，所以这里抹掉关键字
        keyword = @"";
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:@{
        @"keyword": keyword?:@"",
        @"page": @(self.page),
        @"limit": @(self.limit),
        @"only_message": onlyMessage?@(1):@(0),
        @"content_type": contentTypes,
    }];
    if(self.channel) {
        param[@"channel_id"] = self.channel.channelId?:@"";
        param[@"channel_type"] = @(self.channel.channelType);
    }
    
    [self requestSearch:param callback:^(NSError *err,NSDictionary * result) {
        if(err) {
            if(complete) {
                complete(err);
            }
            return;
        }
        
        if(weakSelf.pullup) {
            if(!weakSelf.searchResult) {
                weakSelf.searchResult = result;
            }else {
                
                NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithDictionary:weakSelf.searchResult];
                
                NSMutableArray<NSDictionary*> *messages = [NSMutableArray arrayWithArray:weakSelf.searchResult[@"messages"]];
                NSArray *resultMessages = result[@"messages"];
                if(resultMessages && resultMessages.count>=weakSelf.limit) {
                    weakSelf.hasMore = true;
                }else {
                    weakSelf.hasMore = false;
                }
                if(messages) {
                    [messages addObjectsFromArray:resultMessages];
                }
                resultDict[@"messages"] = messages;
                weakSelf.searchResult = resultDict;
            }
        }else {
            weakSelf.searchResult = result;
        }
        if(complete) {
            complete(nil);
        }
        [weakSelf reloadData];
    }];
}

-(NSMutableArray<NSDictionary*>*) handleSearchResult:(NSDictionary * )result {
    NSArray<NSDictionary*> *friends = result[@"friends"];
    NSArray<NSDictionary*> *groups = result[@"groups"];
    NSArray<NSDictionary*> *messages = result[@"messages"];
    if(self.tabType && ![self.tabType isEqualToString:@""]) {
        if([self.tabType isEqualToString:@"contacts"]) {
            messages = [NSArray array];
            groups = [NSArray array];
        }else if([self.tabType isEqualToString:@"group"]) {
            friends = [NSArray array];
            messages = [NSArray array];
        } else if([self.tabType isEqualToString:@"file"]) {
            friends = [NSArray array];
            groups = [NSArray array];
        }
    }
    
    NSMutableArray<NSDictionary*> *items = [NSMutableArray array];
    if(friends&&friends.count>0) {
        [items addObject: @{
                   @"class":WKSearchHeaderModel.class,
                   @"title":LLang(@"联系人"),
                   @"showBottomLine":@(NO)
                            
        }];
        
        // friends
        NSMutableArray<NSDictionary*> *friendItems = [NSMutableArray array];
        for (NSInteger i=0; i<friends.count; i++) {
            NSDictionary *friend = friends[i];
            
            NSString *name = friend[@"channel_name"]?:@"";
            NSString *uid = friend[@"channel_id"]?:@"";
            [friendItems addObject:@{
                      @"class":WKSearchContactsModel.class,
                      @"name":name,
                      @"avatar":[WKAvatarUtil getAvatar:uid],
                      @"keyword": @"",
                      @"showBottomLine":@(NO),
                      @"showTopLine":@(NO),
                      @"onClick":^{
                        [[WKApp shared] invoke:WKPOINT_USER_INFO param:@{@"uid":uid}];
                      }
                   }];
        }
        [items addObject:@{
            @"height":WKSectionHeight,
             @"items":friendItems,
        }];
    }
    
    // groups
    if(groups && groups.count>0) {
        [items addObject: @{
                   @"class":WKSearchHeaderModel.class,
                   @"title":LLang(@"群聊"),
                   @"showBottomLine":@(NO),
                            
        }];
        
        NSMutableArray<NSDictionary*> *groupsItems = [NSMutableArray array];
        for (NSInteger i=0; i<groups.count; i++) {
            NSDictionary *group = groups[i];
            
            NSString *name = group[@"channel_name"]?:@"";
            NSString *groupNo = group[@"channel_id"]?:@"";
            [groupsItems addObject:@{
               @"class":WKSearchContactsModel.class,
               @"name":name?:@"",
               @"avatar":[WKAvatarUtil getGroupAvatar:groupNo],
               @"keyword": @"",
               @"showBottomLine":@(NO),
               @"showTopLine":@(NO),
               @"onClick":^{
                [[WKApp shared] pushConversation:[WKChannel groupWithChannelID:groupNo]];
            }
            }];
        }
        
        
        [items addObject:@{
            @"height":WKSectionHeight,
             @"items":groupsItems,
        }];
    }
    
    // messages
    if(messages && messages.count>0 && ![self.tabType isEqualToString:@"media"]) {
        if(![self.tabType isEqualToString:@"file"] && ![self searchInChannel]) {
            [items addObject: @{
                @"class":WKSearchHeaderModel.class,
                @"title":LLang(@"聊天记录"),
                @"showBottomLine":@(NO),
                
            }];
        }
       
        NSMutableArray<NSDictionary*> *messagesItems = [NSMutableArray array];
        for (NSInteger i=0; i<messages.count; i++) {
            NSDictionary *message = messages[i];
            
          
            NSString *content = @"";
            NSString *channelId = @"";
            NSString *fromUid = @"";
            NSNumber *channelType = @(0);
            NSNumber *timestamp = message[@"timestamp"]?:@(0);
            if(message[@"channel"] && message[@"channel"] != [NSNull null]) {
                channelId = message[@"channel"][@"channel_id"];
                channelType = message[@"channel"][@"channel_type"];
            }
            
            NSNumber *messageSeq = message[@"message_seq"]?:@(0);
            NSDictionary *payload = message[@"payload"];
            fromUid = message[@"from_uid"];
            NSNumber *contentType = @(0);
            if(payload) {
                contentType = payload[@"type"];
            }
           
            
            WKMessageContent *messageContent = [WKSDK.shared.chatManager getMessageContent:contentType.intValue];
            if(payload) {
                NSString *payloadStr = [WKJsonUtil toJson:payload];
                [messageContent decode:[payloadStr dataUsingEncoding:NSUTF8StringEncoding]];
            }
            
            content = [messageContent conversationDigest];
            
            
            // 文件由文件服务提供item视图
            if([self.tabType isEqualToString:@"file"]) {
                NSMutableDictionary *param = [NSMutableDictionary dictionary];
                param[@"message"] = message;
                param[@"content"] = messageContent;
                NSDictionary *itemDict = [WKApp.shared invoke:WKPOINT_SEARCH_ITEM_FILE param:param];
                if(itemDict) {
                    [messagesItems addObject:itemDict];
                }
                continue;
            }
            
            WKChannel *channel = [WKChannel channelID:channelId channelType:channelType.integerValue];
            
            WKChannel *requestChannel = channel;
            if([self searchInChannel]) {
                requestChannel = [WKChannel personWithChannelID:fromUid];
            }
            
            if([WKSDK.shared isSystemMessage:contentType.integerValue]) {
                content = LLang(@"[系统消息]");
                requestChannel = channel;
            }
            
           
            
            
            [messagesItems addObject:@{
                @"class":WKSearchMessageModel.class,
                @"channel":requestChannel,
                @"keyword": @"",
                @"content": content?:@"",
                @"timestamp":timestamp,
                @"showBottomLine":@(NO),
                @"showTopLine":@(NO),
                @"bottomLeftSpace":@(0.0),
                @"onClick":^{
                WKConversationVC *vc = [[WKConversationVC alloc] init];
                vc.channel = channel;
                vc.locationAtOrderSeq = [WKSDK.shared.chatManager getOrderSeq:messageSeq.unsignedLongLongValue];
                [[WKNavigationManager shared] pushViewController:vc animated:YES];
            }
            }];
        }
        
        
        [items addObject:@{
            @"height":WKSectionHeight,
            @"items":messagesItems,
        }];
    }
    
    // meida
    if(messages && messages.count>0 && [self.tabType isEqualToString:@"media"]) {
        NSMutableArray<NSMutableArray<NSDictionary*>*> *messageGroups = [NSMutableArray array]; // 消息分组
        NSInteger numOfRow = 3; // 每行数量
        
        NSInteger i =1;
        NSMutableArray<NSDictionary*> *rows = [NSMutableArray array];

        for (NSDictionary *message in messages) {
            [rows addObject:message];
            if(i%numOfRow == 0) {
                [messageGroups addObject:rows];
                rows = [NSMutableArray array];
            }
            i++;
        }
        if(messages.count%numOfRow!=0) {
            [messageGroups addObject:rows];
        }
        
        NSMutableArray *mediaItems = [NSMutableArray array];
        for (NSMutableArray<NSDictionary*> *rows in messageGroups) {
            
            NSMutableArray<WKSearchMediaItem*> *items = [NSMutableArray array];
            for (NSDictionary *message in rows) {
                NSDictionary *payload = message[@"payload"];
                if(!payload) {
                    continue;
                }
                NSNumber *contentType = @(0);
                if(payload) {
                    contentType = payload[@"type"];
                }
                NSURL *url = [[WKApp shared] getImageFullUrl:payload[@"url"]];
                
                WKSearchMediaItem *item = [[WKSearchMediaItem alloc] init];
                item.url = url.absoluteString;
                if(contentType.intValue == WK_SMALLVIDEO) {
                    item.type = @"video";
                }
                NSMutableDictionary *extra = [NSMutableDictionary dictionary];
                extra[@"message"] = message;
                item.extra = extra;

                // 改为点击图片后跳转到聊天窗口并定位到该消息（替代直接弹 WKImageBrowser），
                // 规避 YBImageBrowser/WKImageBrowser 内部路径带来的闪退风险，体验也与其他 tab 一致。
                __block NSString *mediaChannelId = @"";
                __block NSNumber *mediaChannelType = @(0);
                if (message[@"channel"] && message[@"channel"] != [NSNull null]) {
                    mediaChannelId = message[@"channel"][@"channel_id"] ?: @"";
                    mediaChannelType = message[@"channel"][@"channel_type"] ?: @(0);
                }
                NSNumber *mediaMessageSeq = message[@"message_seq"] ?: @(0);
                item.onClick = ^{
                    if (mediaChannelId.length == 0) return;
                    WKConversationVC *vc = [[WKConversationVC alloc] init];
                    vc.channel = [WKChannel channelID:mediaChannelId channelType:mediaChannelType.integerValue];
                    vc.locationAtOrderSeq = [WKSDK.shared.chatManager getOrderSeq:mediaMessageSeq.unsignedLongLongValue];
                    [[WKNavigationManager shared] pushViewController:vc animated:YES];
                };

                [items addObject:item];
            }
            
            [mediaItems addObject:@{
                @"class":WKSearchMediaModel.class,
                @"items": items,
                @"numOfRow": @(numOfRow),
            }];
        }
        
        [items addObject:@{
            @"height":WKSectionHeight,
            @"items":mediaItems,
        }];
        
    }
        
    return items;
}


// MARK: - 频道内本地搜索（基于 WKMessageDB 本地数据库）

- (NSSet<NSNumber *> *)targetContentTypesForLocalSearch {
    if ([self.tabType isEqualToString:@"file"]) {
        return [NSSet setWithObjects:@(WK_FILE), nil];
    }
    if ([self.tabType isEqualToString:@"media"]) {
        if ([WKApp.shared hasMethod:WKPOINT_SEARCH_ITEM_VIDEO]) {
            return [NSSet setWithObjects:@(WK_IMAGE), @(WK_SMALLVIDEO), nil];
        }
        return [NSSet setWithObjects:@(WK_IMAGE), nil];
    }
    // 聊天 tab：仅在文本消息中按关键字搜索（与 Android 端行为一致）
    return [NSSet setWithObjects:@(WK_TEXT), nil];
}

- (NSDictionary *)convertWKMessageToDict:(WKMessage *)msg {
    NSMutableDictionary *channelDict = [NSMutableDictionary dictionary];
    if (msg.channel) {
        channelDict[@"channel_id"] = msg.channel.channelId ?: @"";
        channelDict[@"channel_type"] = @(msg.channel.channelType);
    }

    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    payload[@"type"] = @(msg.contentType);
    if (msg.contentData) {
        NSError *err = nil;
        id parsed = [NSJSONSerialization JSONObjectWithData:msg.contentData options:0 error:&err];
        if (!err && [parsed isKindOfClass:[NSDictionary class]]) {
            [payload addEntriesFromDictionary:(NSDictionary *)parsed];
            // type 字段以 SDK contentType 为准，避免 payload 中 type 缺失导致 UI 解析失败
            payload[@"type"] = @(msg.contentType);
        }
    }

    return @{
        @"channel": channelDict,
        @"from_uid": msg.fromUid ?: @"",
        @"timestamp": @(msg.timestamp),
        @"message_seq": @(msg.messageSeq),
        // 额外补充字段，供下游（如小视频点击播放）凭这些唯一标识反查本地 WKMessage
        @"client_msg_no": msg.clientMsgNo ?: @"",
        @"message_id": @(msg.messageId),
        @"order_seq": @(msg.orderSeq),
        @"payload": payload,
    };
}

- (void)localSearchInChannel:(void (^)(NSError * _Nullable))complete {
    self.limit = [self.tabType isEqualToString:@"media"] ? 40 : 20;
    NSInteger pageLimit = self.limit;

    NSString *keyword = self.keyword ?: @"";
    if ([self.tabType isEqualToString:@"media"]) {
        keyword = @""; // 图片/视频不支持关键字过滤
    }
    BOOL needKeyword = keyword.length > 0;

    // 聊天 tab：未输入关键字时不查询，列表保持空白（避免默认列出频道全部文本消息）。
    if ([self.tabType isEqualToString:@"all"] && !needKeyword) {
        self.searchResult = nil;
        self.hasMore = NO;
        self.localOldestOrderSeq = 0;
        if (complete) complete(nil);
        [self reloadData];
        return;
    }

    NSSet<NSNumber *> *targetTypes = [self targetContentTypesForLocalSearch];

    NSMutableArray<NSDictionary *> *result = [NSMutableArray array];
    uint32_t cursor = self.localOldestOrderSeq; // 0 表示从最新开始
    BOOL reachedEnd = NO;
    const int fetchBatch = 80;
    int safety = 0;
    while (result.count < (NSUInteger)pageLimit && safety++ < 30) {
        // 拉取 cursor 之前的更早一批消息（pullDown = 向旧的方向拉取）。
        // 注意：传 0 给 startOrderSeq 时 SDK 会从最新开始返回。
        NSArray<WKMessage *> *batch = [[WKMessageDB shared] getMessages:self.channel
                                                          startOrderSeq:cursor
                                                            endOrderSeq:0
                                                                  limit:fetchBatch
                                                               pullMode:WKPullModeDown];
        if (!batch || batch.count == 0) {
            reachedEnd = YES;
            break;
        }
        for (WKMessage *msg in batch) {
            if (msg == nil) continue;
            cursor = msg.orderSeq; // 推进游标
            if (msg.isDeleted) continue;
            if (![targetTypes containsObject:@(msg.contentType)]) continue;
            // 媒体 tab：过滤掉 url 为空的图片/视频消息，避免点击后 [NSURL URLWithString:nil] 闪退。
            if ([self.tabType isEqualToString:@"media"]) {
                NSString *imgUrl = nil;
                if (msg.contentData) {
                    NSError *jsonErr = nil;
                    id parsedPayload = [NSJSONSerialization JSONObjectWithData:msg.contentData options:0 error:&jsonErr];
                    if (!jsonErr && [parsedPayload isKindOfClass:[NSDictionary class]]) {
                        id u = ((NSDictionary *)parsedPayload)[@"url"];
                        if ([u isKindOfClass:[NSString class]]) {
                            imgUrl = (NSString *)u;
                        }
                    }
                }
                if (imgUrl.length == 0) continue;
            }
            if (needKeyword) {
                NSString *digest = nil;
                if (msg.content && [msg.content respondsToSelector:@selector(conversationDigest)]) {
                    digest = [msg.content conversationDigest];
                }
                if (digest.length == 0) {
                    // 解码 fallback：直接在原始 JSON 串里检索
                    if (msg.contentData) {
                        digest = [[NSString alloc] initWithData:msg.contentData encoding:NSUTF8StringEncoding];
                    }
                }
                if (!digest || [digest rangeOfString:keyword options:NSCaseInsensitiveSearch].location == NSNotFound) {
                    continue;
                }
            }
            [result addObject:[self convertWKMessageToDict:msg]];
            if (result.count >= (NSUInteger)pageLimit) break;
        }
        if (batch.count < fetchBatch) {
            reachedEnd = YES;
            break;
        }
    }
    self.localOldestOrderSeq = cursor;
    self.hasMore = !reachedEnd;

    NSDictionary *resultDict = @{ @"messages": result };
    if (self.pullup && self.searchResult) {
        NSMutableDictionary *merged = [NSMutableDictionary dictionaryWithDictionary:self.searchResult];
        NSArray *existing = self.searchResult[@"messages"];
        NSMutableArray *combined = [NSMutableArray arrayWithArray:existing ?: @[]];
        [combined addObjectsFromArray:result];
        merged[@"messages"] = combined;
        self.searchResult = merged;
    } else {
        self.searchResult = resultDict;
    }

    if (complete) {
        complete(nil);
    }
    [self reloadData];
}

-(void) requestSearch:(NSDictionary*)param callback:(void (^)(NSError * _Nullable error,NSDictionary * _Nullable))callback{
    
    NSMutableDictionary *request = [NSMutableDictionary dictionaryWithDictionary:param];
    if(!request[@"limit"]) {
        request[@"limit"] = @(20);
    }
    
    [WKAPIClient.sharedClient POST:@"search/global" parameters:request].then(^(NSDictionary*result){
        if(callback) {
            callback(nil,result);
        }
    }).catch(^(NSError *error){
        if(callback) {
            callback(error,nil);
        }
    });
}
@end
