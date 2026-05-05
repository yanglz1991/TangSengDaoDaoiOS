//
//  WKFileModule.m
//  WuKongFile
//
//  Created by tt on 2020/5/5.
//

#import "WKFileModule.h"
#import "WKFileContent.h"
#import "WKFileCell.h"
#import "WKFileChooseUtil.h"
#import "WKFileCommon.h"
#import "WKPanelFileFuncItem.h"
@WKModule(WKFileModule)
@implementation WKFileModule

+(NSString*) gmoduleId {
    return @"WuKongFile";
}

-(NSString*) moduleId {
    return [WKFileModule gmoduleId];
}

- (void)moduleInit:(WKModuleContext *)context {
    NSLog(@"【WuKongFile】模块初始化！");
     // 注册消息
    [[WKApp shared] registerCellClass:WKFileCell.class forMessageContntClass:WKFileContent.class];
    
    // file
    [self setMethod:WKPOINT_CATEGORY_PANELFUNCITEM_FILE handler:^id _Nullable(id  _Nonnull param) {
        WKPanelDefaultFuncItem *item = [[WKPanelFileFuncItem alloc] init];
        item.sort = 8000;
        return item;
    } category:WKPOINT_CATEGORY_PANELFUNCITEM];

    // 搜索记录里的文件 item。注册此端点后，全局/频道内搜索页会显示「文件」tab。
    // 端点返回 WKSearchMessageModel 字典，复用搜索页的消息 cell 以最小改动支持文件搜索展示。
    [self setMethod:WKPOINT_SEARCH_ITEM_FILE handler:^id _Nullable(id  _Nonnull param) {
        NSDictionary *message = param[@"message"];
        id contentObj = param[@"content"];
        if(!message || ![contentObj isKindOfClass:[WKFileContent class]]) {
            return nil;
        }
        WKFileContent *fileContent = (WKFileContent*)contentObj;

        NSString *channelId = @"";
        NSInteger channelType = 0;
        if(message[@"channel"] && message[@"channel"] != [NSNull null]) {
            channelId = message[@"channel"][@"channel_id"] ?: @"";
            channelType = [message[@"channel"][@"channel_type"] integerValue];
        }
        WKChannel *channel = [WKChannel channelID:channelId channelType:channelType];

        NSNumber *messageSeq = message[@"message_seq"] ?: @(0);
        NSNumber *timestamp = message[@"timestamp"] ?: @(0);

        NSString *fileName = fileContent.name ?: @"";
        NSString *sizeStr = [[WKFileCommon shared] sizeFormat:fileContent.size];
        NSString *displayContent = sizeStr.length > 0
            ? [NSString stringWithFormat:@"%@ · %@", fileName, sizeStr]
            : fileName;

        return @{
            @"class": WKSearchMessageModel.class,
            @"channel": channel,
            @"keyword": @"",
            @"content": displayContent ?: @"",
            @"timestamp": timestamp,
            @"showBottomLine": @(NO),
            @"showTopLine": @(NO),
            @"bottomLeftSpace": @(0.0),
            @"onClick": ^{
                WKConversationVC *vc = [[WKConversationVC alloc] init];
                vc.channel = channel;
                vc.locationAtOrderSeq = [WKSDK.shared.chatManager getOrderSeq:messageSeq.unsignedLongLongValue];
                [[WKNavigationManager shared] pushViewController:vc animated:YES];
            }
        };
    } category:nil];
}


// 数据库加载完成
-(void) moduleDidDatabaseLoad:(WKModuleContext*_Nonnull) context {
    WKLogDebug(@"【WuKongFile】数据库加载完成....");
//    WKChannel *fileHelperChannel = [[WKChannel alloc] initWith:[WKApp shared].loginInfo.uid channelType:WK_PERSON];
//    WKConversation *fileHeplerConversation = [[WKSDK shared].conversationManager getConversation:fileHelperChannel];
//    if(!fileHeplerConversation) {
//        WKConversation *fileHeplerConversation = [WKConversation new];
//        fileHeplerConversation.channel = fileHelperChannel;
//        fileHeplerConversation.version = 1;
//        fileHeplerConversation.lastMsgTimestamp = [[NSDate date] timeIntervalSince1970];
//        [[WKSDK shared].conversationManager addConversation:fileHeplerConversation];
//    }
    
}
-(UIImage*) imageName:(NSString*)name {
    return [[WKApp shared] loadImage:name moduleID:@"WuKongFile"];
}

@end
