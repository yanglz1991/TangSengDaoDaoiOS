//
//  QCContactsManager.m
//  Pods
//
//  Created by tt on 2020/1/4.
//

#import "QCContactsManager.h"
#import <QCIM/QCIM.h>
#import "QCConstant.h"
#import "QCApp.h"
#import "QCFriendRequestDB.h"
#import "QCLogs.h"
#import "QCAvatarUtil.h"
#import "QCCore.h"
#import "QCSyncService.h"
@interface QCContactsManager ()<QCChatManagerDelegate,QCCMDManagerDelegate>
/**
 *  用来存储所有添加j过的delegate
 *  NSHashTable 与 NSMutableSet相似，但NSHashTable可以持有元素的弱引用，而且在对象被销毁后能正确地将其移除。
 */
@property (strong, nonatomic) NSHashTable  *delegates;
/**
 *  delegateLock 用于给delegate的操作加锁，防止多线程同时调用
 */
@property (strong, nonatomic) NSLock  *delegateLock;

@end

@implementation QCContactsManager

static QCContactsManager *_instance;
+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
+ (QCContactsManager *)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        [[QCSDK shared].cmdManager addDelegate:_instance];
    });
    return _instance;
}

- (void)dealloc {
    // 因为是单利的 虽然这里不会执行 但是流程还是要走的
    [[QCSDK shared].cmdManager removeDelegate:self];
}


#pragma mark - QCCMDManagerDelegate

- (void)cmdManager:(QCCMDManager *)manager onCMD:(QCCMDModel *)model {
    [self handleCMD:model.cmd param:model.param];
}


-(void) handleCMD:(QCMessage*)message {
    QCCMDContent *cmdContent = (QCCMDContent*)message.content;
    NSString *cmd = cmdContent.cmd;
    [self handleCMD:cmd param:cmdContent.param];
   
}

-(void) handleCMD:(NSString*)cmd param:(NSDictionary*)param {
    if([cmd isEqualToString:@"friendRequest"]) { // 好友请求
        [self handleFriendRequest:param];
    }else if ([cmd isEqualToString:@"friendAccept"]) { // 接受好友请求
        [self handleFriendAccepted:param];
    }else if ([cmd isEqualToString:@"friendDeleted"]) { // 被好友删除
        [self handleFriendDeleted:param];
    }
}

// 处理好友请求
-(void) handleFriendRequest:(NSDictionary*)param {
    if(param) {
        QCFriendRequestDBModel *requestModel = [QCFriendRequestDBModel new];
        requestModel.uid = param[@"apply_uid"];
        requestModel.name = param[@"apply_name"]?:@"";
        requestModel.avatar =param[@"apply_avatar"]?:@"";
        if([requestModel.avatar isEqualToString:@""]) {
            requestModel.avatar = [QCAvatarUtil getAvatar:requestModel.uid];
        }
        requestModel.remark = param[@"remark"]?:@"";
        requestModel.token = param[@"token"]?:@"";
        requestModel.status = QCFriendRequestStatusWaitSure;
        requestModel.readed = false;
        BOOL isNewRequest = [[QCFriendRequestDB shared] addFriendRequest:requestModel];
        if(isNewRequest) {
            [self callLastFriendRequestDelegate:requestModel];
        }
        [self callFriendRequestUnreadCountDelegate:[[QCFriendRequestDB shared] getFriendRequestUnreadCount]];
    }
}

// 好友接受邀请
/**
 {"content":"你们已经是好友了，可以愉快的聊天了！","sure_name":"赵一","sure_uid":"748c5be0761a45af82fe77af8d0fd567","to_uid":"00abc9c07a87437aa7b41b082c3f13c0","type":1004}
 **/
-(void) handleFriendAccepted:(NSDictionary*)param {

    // 调用委托 通知到UI
    [self callFriendAcceptedDelegate:param];
}
// 被好友删除
-(void) handleFriendDeleted:(NSDictionary*)param {
    NSString *uid = param[@"uid"];
    if(!uid || [uid isEqualToString:@""]) {
        return;
    }
    QCChannel *channel = [[QCChannel alloc] initWith:uid channelType:WK_PERSON];
    // 删除频道
    [[QCSDK shared].channelManager deleteChannelInfo:channel];
    // ---------- 会话和对应的消息 ----------
    // 删除最近会话
    [[QCSDK shared].conversationManager deleteConversation:channel];
    // 清除会话的消息
    [[QCMessageManager shared] clearMessages:channel];
    // 同步联系人
    [[QCSyncService shared] syncContacts:nil];
    
}


-(int) getFriendRequestUnreadCount {
    return [[QCFriendRequestDB shared] getFriendRequestUnreadCount];
}

-(void) markAllFriendRequestToReaded {
    [[QCFriendRequestDB shared] markAllFriendRequestToReaded];
    [self callFriendRequestUnreadCountDelegate:[[QCFriendRequestDB shared] getFriendRequestUnreadCount]];
}

-(void) updateFriendRequestStatus:(NSString*)uid status:(QCFriendRequestStatus)status {
    [[QCFriendRequestDB shared] updateFriendRequestStatus:uid status:status];
}

-(NSArray<QCFriendRequestDBModel*>*) getAllFriendRequest {
    return [[QCFriendRequestDB shared] getAllFriendRequest];
}

- (NSLock *)delegateLock {
    if (_delegateLock == nil) {
        _delegateLock = [[NSLock alloc] init];
    }
    return _delegateLock;
}

-(NSHashTable*) delegates {
    if (_delegates == nil) {
        _delegates = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return _delegates;
}

- (void)callLastFriendRequestDelegate:(QCFriendRequestDBModel*)model {
    [self.delegateLock lock];
    for (id delegate in self.delegates) {//遍历delegates ，call delegate
        if ([delegate respondsToSelector:@selector(contactsManager:lastFriendRequest:)]) {
            __weak typeof(self) weakSelf = self;
            [delegate contactsManager:weakSelf lastFriendRequest:model];
        }
    }
    [self.delegateLock unlock];
}
- (void)callFriendAcceptedDelegate:(NSDictionary*)param {
    [self.delegateLock lock];
    for (id delegate in self.delegates) {//遍历delegates ，call delegate
        if ([delegate respondsToSelector:@selector(contactsManager:friendAccepted:)]) {
            __weak typeof(self) weakSelf = self;
            [delegate contactsManager:weakSelf friendAccepted:param];
        }
    }
    [self.delegateLock unlock];
}


- (void)callFriendRequestUnreadCountDelegate:(int)unreadCount {
    [self.delegateLock lock];
    for (id delegate in self.delegates) {//遍历delegates ，call delegate
        if ([delegate respondsToSelector:@selector(contactsManager:friendRequestUnreadCount:)]) {
            __weak typeof(self) weakSelf = self;
            [delegate contactsManager:weakSelf friendRequestUnreadCount:unreadCount];
        }
    }
    [self.delegateLock unlock];
}



-(void) addDelegate:(id<QCContactsManagerDelegate>) delegate{
    [self.delegateLock lock];//防止多线程同时调用
    [self.delegates addObject:delegate];
    [self.delegateLock unlock];
}
- (void)removeDelegate:(id<QCContactsManagerDelegate>) delegate {
    [self.delegateLock lock];//防止多线程同时调用
    [self.delegates removeObject:delegate];
    [self.delegateLock unlock];
}


@end
