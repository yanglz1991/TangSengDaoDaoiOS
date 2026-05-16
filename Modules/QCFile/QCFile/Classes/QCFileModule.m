//
//  QCFileModule.m
//  QCFile
//
//  Created by tt on 2020/5/5.
//

#import "QCFileModule.h"
#import "QCFileContent.h"
#import "QCFileCell.h"
#import "QCFileChooseUtil.h"
#import "QCFileCommon.h"
#import "QCPanelFileFuncItem.h"
@QCModule(QCFileModule)
@implementation QCFileModule

+(NSString*) gmoduleId {
    return @"QCFile";
}

-(NSString*) moduleId {
    return [QCFileModule gmoduleId];
}

- (void)moduleInit:(QCModuleContext *)context {
    NSLog(@"【QCFile】模块初始化！");
     // 注册消息
    [[QCApp shared] registerCellClass:QCFileCell.class forMessageContntClass:QCFileContent.class];
    
    // file
    [self setMethod:QCPOINT_CATEGORY_PANELFUNCITEM_FILE handler:^id _Nullable(id  _Nonnull param) {
        QCPanelDefaultFuncItem *item = [[QCPanelFileFuncItem alloc] init];
        item.sort = 8000;
        return item;
    } category:QCPOINT_CATEGORY_PANELFUNCITEM];

    // 搜索记录里的文件 item。注册此端点后，全局/频道内搜索页会显示「文件」tab。
    // 端点返回 QCSearchMessageModel 字典，复用搜索页的消息 cell 以最小改动支持文件搜索展示。
    [self setMethod:QCPOINT_SEARCH_ITEM_FILE handler:^id _Nullable(id  _Nonnull param) {
        NSDictionary *message = param[@"message"];
        id contentObj = param[@"content"];
        if(!message || ![contentObj isKindOfClass:[QCFileContent class]]) {
            return nil;
        }
        QCFileContent *fileContent = (QCFileContent*)contentObj;

        NSString *channelId = @"";
        NSInteger channelType = 0;
        if(message[@"channel"] && message[@"channel"] != [NSNull null]) {
            channelId = message[@"channel"][@"channel_id"] ?: @"";
            channelType = [message[@"channel"][@"channel_type"] integerValue];
        }
        QCChannel *channel = [QCChannel channelID:channelId channelType:channelType];

        NSNumber *messageSeq = message[@"message_seq"] ?: @(0);
        NSNumber *timestamp = message[@"timestamp"] ?: @(0);

        NSString *fileName = fileContent.name ?: @"";
        NSString *sizeStr = [[QCFileCommon shared] sizeFormat:fileContent.size];
        NSString *displayContent = sizeStr.length > 0
            ? [NSString stringWithFormat:@"%@ · %@", fileName, sizeStr]
            : fileName;

        return @{
            @"class": QCSearchMessageModel.class,
            @"channel": channel,
            @"keyword": @"",
            @"content": displayContent ?: @"",
            @"timestamp": timestamp,
            @"showBottomLine": @(NO),
            @"showTopLine": @(NO),
            @"bottomLeftSpace": @(0.0),
            @"onClick": ^{
                QCConversationVC *vc = [[QCConversationVC alloc] init];
                vc.channel = channel;
                vc.locationAtOrderSeq = [QCSDK.shared.chatManager getOrderSeq:messageSeq.unsignedLongLongValue];
                [[QCNavigationManager shared] pushViewController:vc animated:YES];
            }
        };
    } category:nil];
}


// 数据库加载完成
-(void) moduleDidDatabaseLoad:(QCModuleContext*_Nonnull) context {
    QCLogDebug(@"【QCFile】数据库加载完成....");
//    QCChannel *fileHelperChannel = [[QCChannel alloc] initWith:[QCApp shared].loginInfo.uid channelType:WK_PERSON];
//    QCConversation *fileHeplerConversation = [[QCSDK shared].conversationManager getConversation:fileHelperChannel];
//    if(!fileHeplerConversation) {
//        QCConversation *fileHeplerConversation = [QCConversation new];
//        fileHeplerConversation.channel = fileHelperChannel;
//        fileHeplerConversation.version = 1;
//        fileHeplerConversation.lastMsgTimestamp = [[NSDate date] timeIntervalSince1970];
//        [[QCSDK shared].conversationManager addConversation:fileHeplerConversation];
//    }
    
}
-(UIImage*) imageName:(NSString*)name {
    return [[QCApp shared] loadImage:name moduleID:@"QCFile"];
}

@end
