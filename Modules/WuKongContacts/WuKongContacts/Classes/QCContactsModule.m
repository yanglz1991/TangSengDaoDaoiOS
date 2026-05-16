//
//  QCContactsModule.m
//  WuKongContacts
//
//  Created by tt on 2019/12/7.
//

#import "QCContactsModule.h"
#import "QCContactsSync.h"
#import "QCContactsAddVC.h"
#import "QCUserInfoVC.h"
#import "QCContactsFriendRequestVC.h"
#import "QCMyGroupListVC.h"
@QCModule(QCContactsModule)

@interface QCContactsModule ()<QCChannelManagerDelegate>

@end

@implementation QCContactsModule


-(NSString*) moduleId {
    return @"WuKongContacts";
}

// 模块初始化
- (void)moduleInit:(QCModuleContext*)context{
    NSLog(@"【WuKongContacts】模块初始化！");
    
    __weak typeof(self) weakSelf = self;
    // 联系人同步
    [self setMethod:QCPOINT_SYNC_CONTACTS handler:^id _Nullable(id  _Nonnull param) {
        return [[QCContactsSync alloc] init];
    } category:QCPOINT_CATEGORY_SYNC];
    
    
     // 显示添加联系人界面
    [[QCApp shared] setMethod:QCPOINT_CONVERSATION_ADDCONTACTS handler:^id _Nullable(id  _Nonnull param) {
        QCContactsAddVC *vc = [QCContactsAddVC new];
        [[QCNavigationManager shared] pushViewController:vc animated:YES];
        return nil;
    }];
    
    
    // 提供联系人选择的数据
    [self setMethod:QCPOINT_CONTACTS_SELECT_DATA handler:^id _Nullable(id  _Nonnull param) {
//        NSArray<QCDBContactsModel*> *contactsList = [[QCDBContacts shared] queryVaild];
        NSArray<QCChannelInfo*> *channelInfos = [[QCChannelInfoDB shared] queryChannelInfosWithStatusAndFollow:QCChannelStatusNormal follow:QCChannelInfoFollowFriend];
        NSMutableArray *items = [NSMutableArray array];
        if(channelInfos) {
            for (QCChannelInfo *channelInfo in channelInfos) {
                if(channelInfo.channel.channelType != WK_PERSON) {
                    continue;
                }
                QCContactsSelect *contacts = [[QCContactsSelect alloc] init];
                contacts.uid =channelInfo.channel.channelId;
                contacts.name = channelInfo.name;
                contacts.displayName =channelInfo.displayName;
                contacts.avatar = [QCAvatarUtil getAvatar:channelInfo.channel.channelId];
                [items addObject:contacts];
            }
        }
        return items;
    }];
    
    
    // 新朋友item
    [self setMethod:@"contacts.header.newFriend" handler:^id _Nullable(id  _Nonnull param) {
        QCContactsHeaderItem *item = [QCContactsHeaderItem initWithSid:WK_CONTACTS_HEADER_ITEM_NEWFRIEND title:LLangW(@"新的朋友",weakSelf) icon:@"Contacts/Index/FriendNew" moduleID:[weakSelf moduleId] onClick:^{
            [[QCContactsManager shared] markAllFriendRequestToReaded]; // 好友请求标记为已读
            // 跳转
            [[QCNavigationManager shared] pushViewController:[QCContactsFriendRequestVC new] animated:YES];
        }];
        int count = [[QCContactsManager shared] getFriendRequestUnreadCount];
        if(count>0) {
            item.badgeValue = [NSString stringWithFormat:@"%d", [[QCContactsManager shared] getFriendRequestUnreadCount]];
        }
        
        return item;
    } category:QCPOINT_CATEGORY_CONTACTSITEM sort:9000];
    
    // 保存的群item
       [self setMethod:@"contacts.header.groupSave" handler:^id _Nullable(id  _Nonnull param) {
           QCContactsHeaderItem *item = [QCContactsHeaderItem initWithSid:WK_CONTACTS_HEADER_ITEM_NEWFRIEND title:LLangW(@"保存的群聊",weakSelf) icon:@"Contacts/Index/GroupSave" moduleID:[weakSelf moduleId] onClick:^{
               // 跳转
               [[QCNavigationManager shared] pushViewController:[QCMyGroupListVC new] animated:YES];
           }];
           return item;
       } category:QCPOINT_CATEGORY_CONTACTSITEM sort:8000];

    
}

// 模块启动
-(BOOL) moduleDidFinishLaunching:(QCModuleContext *)context{

    
    return true;
}

- (void)moduleDidDatabaseLoad:(QCModuleContext *)context {
    // 初始化db
    [[QCDBMigration shared] migrateDatabase:[self resourceBundle]];
}

@end
