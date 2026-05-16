//
//  QCConversationContextImpl.m
//  QCCore
//
//  Created by tt on 2022/5/19.
//

#import "QCConversationContextImpl.h"
#import "QCUserHandleVC.h"
#import "QCMentionUserCell.h"
#import "QCInputMentionCache.h"
#import "QCReplyView.h"
#import "QCMessageEditView.h"
#import "QCContextMenusVC.h"
#import "QCAlertUtil.h"
#import "QCAppConfig.h"
#import "QCApp.h"
#import <QCCore/QCCore-Swift.h>

@interface QCConversationContextImpl ()

/**
 *  用来存储所有添加j过的delegate
 *  NSHashTable 与 NSMutableSet相似，但NSHashTable可以持有元素的弱引用，而且在对象被销毁后能正确地将其移除。
 */
@property (strong, nonatomic) NSHashTable  *delegates;
/**
 *  delegateLock 用于给delegate的操作加锁，防止多线程同时调用
 */
@property (strong, nonatomic) NSLock  *delegateLock;

@property(nonatomic,strong) QCChannel *channel;
@property(nonatomic,weak) QCConversationView *conversationView;

@property(nonatomic,weak) QCConversationVM *conversationVM;

// ---------- mention @ ----------
@property(nonatomic,strong) QCUserHandleVC *mentionUserHandleVC;
@property(nonatomic,strong) QCInputMentionCache *mentionCache;


// ---------- 长按菜单 ----------
//@property(nonatomic,strong) QCContextMenusVC *messageActionsVC;
//@property(nonatomic,strong) UILongPressGestureRecognizer *messageActionLongPressGesture;

///避免多个cell同时长按
//@property (nonatomic,assign)BOOL messageActionsVCIsShow;



@end

@implementation QCConversationContextImpl

-(instancetype) initWithChannel:(QCChannel*)channel conersationView:(QCConversationView*)conversationView conversationVM:(QCConversationVM*)conversationVM{
    self = [super init];
    if (self) {
        self.channel = channel;
        self.conversationView = conversationView;
        self.conversationVM = conversationVM;
    }
    return self;
}
- (void)showMentionUsers {
    [self showMentionUsers:@""];
}

-(NSString*) inputText {
    return [self.conversationView.input inputText];
}

-(NSRange) inputSelectedRange {
    return [self.conversationView.input inputSelectedRange];
}

-(void) inputDeleteText:(NSRange)range {
    [self.conversationView.input inputDeleteText:range];
}

/**
 往输入框插入文本
 */
-(void) inputInsertText:(NSString *)text {
    [self.conversationView.input inputInsertText:text];
}

-(void) inputSetText:(NSString*)text {
    [self.conversationView.input inputSetText:text];
}

-(void) inputTextToSend {
    NSString *text = self.conversationView.input.textView.text;
    [self.conversationView.input inputSetText:@""];
    [self sendTextMessage:text];
}

// 展示mention用户列表 (//keyword = nil  都不显示 keyword=“” 为显示所有)
-(void) showMentionUsers:(NSString *)keyword {
    [self addMentionUserHandleVCIfNeed];
    __weak typeof(self) weakSelf = self;
    [self getMentionUserListWithKeyword:keyword complete:^(NSArray<QCMentionUserCellModel *> *users) {
        if(![weakSelf array:(NSArray<QCMentionUserCellModel*>*)weakSelf.mentionUserHandleVC.items isEqualTo:users]) {
            [weakSelf.mentionUserHandleVC reload:users];
        }
    }];
    
    
    return;
}



- (void)replyTo:(QCMessage *)message {
    [self.conversationView.input becomeFirstResponder];
    self.conversationView.replyMessage = message;
    
    UIView *replyView = [self replyView:message];
    
    [self setInputTopView:replyView];
    
    // 添加@
    [self addMention:message.fromUid];
    
}

-(UIView*) replyView:(QCMessage*)message {
    __weak typeof(self) weakSelf = self;
    QCReplyView *replyView = [QCReplyView message:message];
    [replyView setOnClose:^{
        weakSelf.conversationView.replyMessage = nil;
        [weakSelf setInputTopView:nil];
    }];
    return replyView;
}

- (QCMessage *)replyingMessage {
    return self.conversationView.replyMessage;
}

-(BOOL) hasReply {
    if(self.conversationView.replyMessage) {
        return true;
    }
    return false;
}

-(void) showConversationTopView:(BOOL)show animated:(BOOL)animated{
    [self.conversationView showTopView:show animated:animated];
}


/**
 编辑消息
 */

-(void) editTo:(QCMessage*)message {
    if(message.contentType!=WK_TEXT) {
        return;
    }
    self.conversationView.editMessage = message;
    
    QCTextContent *textContent = (QCTextContent*)message.content;
    if(message.remoteExtra.contentEdit) {
        textContent = (QCTextContent*)message.remoteExtra.contentEdit;
    }
    [self.conversationView.input becomeFirstResponder];
    [self.conversationView.input inputSetText:textContent.content];
    [self.conversationView.input resetCurrentInputHeight];
    
    UIView *editView = [self editView:message];
    [self setInputTopView:editView];
}

-(UIView*) editView:(QCMessage*)message {
    __weak typeof(self) weakSelf = self;
    QCMessageEditView *editView = [QCMessageEditView message:message];
    [editView setOnClose:^{
        weakSelf.conversationView.editMessage = nil;
        [weakSelf setInputTopView:nil];
    }];
    return editView;
}

- (QCMessage *)editingMessage {
    return self.conversationView.editMessage;
}

-(BOOL) hasEdit {
    if(self.conversationView.editMessage) {
        return true;
    }
    return false;
}

-(void) setInputTopView:(UIView* __nullable)view {
    __weak typeof(self) weakSelf = self;
    [self.conversationView.input setTopView:view animateBlock:^{
        [weakSelf.conversationView layoutSubviews];
        [weakSelf layoutMentionUserHandle];
    }];
    [self callConversationInputChangeDelegate];
}

- (UIView *)inputTopView {
    return self.conversationView.input.topView;
}

-(void) inputBecomeFirstResponder {
    [self.conversationView.input becomeFirstResponder];
}

-(void) endEditing {
    [self.conversationView.input endEditing];
}

-(NSArray<QCMessageModel*>*) getMessagesWithContentType:(NSInteger)contentType {
    return [self.conversationView.messageListView getMessagesWithContentType:contentType];;
}

- (void)startRecordingVoiceMessage {
    [[QCSDK shared].mediaManager stopAudioPlay];
    NSArray *voiceMessages = [self getMessagesWithContentType:WK_VOICE];
    if(voiceMessages) {
        for (QCMessageModel *voiceMessage in voiceMessages) {
            if(voiceMessage.voicePlayStatus == QCVoicePlayStatusPlaying) {
                voiceMessage.voicePlayStatus = QCVoicePlayStatusNoPlay;
                [self refreshCell:voiceMessage];
            }
        }
    }
}

- (void)refreshCell:(QCMessageModel *)messageModel {
    [self.conversationView.messageListView refreshCell:messageModel];
}

- (NSArray<NSString *> *)dates {
    
    return [self.conversationView.messageListView dates];
}

- (NSArray<QCMessageModel *> *)messagesAtDate:(NSString *)date {
    return [self.conversationView.messageListView messagesAtDate:date];
}

-(UIViewController*) targetVC {
    return self.conversationView.lim_viewController;
}

- (NSArray<UITableViewCell *> *)visibleCells {
    return [self.conversationView.messageListView visibleCells];
}



/// 添加@
/// @param uid 被@人的uid
-(void) addMention:(NSString *)uid{
    if(self.channel.channelType == WK_PERSON || self.channel.channelType == WK_CustomerService) { // 单聊不能@
        return;
    }
    if(!uid || [uid isEqualToString:@""] || [uid isEqualToString:[QCApp shared].loginInfo.uid]) {
        return;
    }
    
    NSString *str =  [self addMentionToCache:@[uid]];
    [self.conversationView.input inputInsertText:str];
    [self.conversationView.input becomeFirstResponder];
    
}

- (void)setMultipleOn:(BOOL)multiple selectedMessage:(QCMessageModel *)messageModel {
    [self.conversationView setMultipleOn:multiple selectedMessage:messageModel];
}

/// 定位到指定的消息
/// @param messageSeq 通过消息messageSeq定位消息
-(void) locateMessageCell:(uint32_t)messageSeq {
    [self.conversationView.messageListView locateMessageCell:messageSeq];
}

-(UITableViewCell*) cellForRowAtIndex:(NSIndexPath*)indexPath {
    return [self.conversationView.messageListView cellForRowAtIndex:indexPath];
}

-(void) hideMentionUsers {
    //    [self showMentionUsers:nil];
    [self.mentionUserHandleVC reload:@[]];
}

-(QCMessage*) sendTextMessage:(NSString*)text {
    return [self sendTextMessage:text entities:nil];
}

- (QCChannelInfo *)getChannelInfo {
    return [QCSDK.shared.channelManager getChannelInfo:self.channel];
}

-(QCMessage*) sendTextMessage:(NSString*)text entities:(NSArray<QCMessageEntity*>*)entities {
    return [self sendTextMessage:text entities:entities robotID:nil];
}

-(NSArray<NSTextCheckingResult*>*) ranges:(NSString*)text pattern:(NSString*)pattern{
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *results = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    return results;
}

-(NSArray<QCMessageEntity*>*) entities:(NSString*)text mentionCache:(QCInputMentionCache*)mentionCache{
    
    // -------------------- @ --------------------
    NSMutableArray<QCMessageEntity*> *entities = [NSMutableArray array];
    NSArray<QCInputMentionItem*> *mentionItems =  mentionCache.items;
    NSMutableArray<QCMessageEntity*> *newMentionEntities = [NSMutableArray array];
    if(mentionItems && mentionItems.count>0) {
        
        for (QCInputMentionItem *mentionItem in mentionItems) {
            NSString *mentionName = [NSString stringWithFormat:@"%@%@",QCInputAtStartChar,mentionItem.name];
            NSArray<NSTextCheckingResult*> *results = [self ranges:text pattern:mentionName];
            if(results && results.count>0) {
                for (NSTextCheckingResult *result in results) {
                    BOOL exist = false;
                    for (QCMessageEntity *existEntity in newMentionEntities) {
                        if(NSLocationInRange(result.range.location, existEntity.range)) {
                            exist = true;
                            break;
                        }
                    }
                    if(!exist) {
                        QCMessageEntity *entity = [[QCMessageEntity alloc] init];
                        entity.type = QCMentionRichTextStyle;
                        entity.value = mentionItem.uid;
                        entity.range = result.range;
                        [newMentionEntities addObject:entity];
                    }
                    
                }
            }
        }
        
    }
    [entities addObjectsFromArray:newMentionEntities];
    
    // -------------------- 链接 --------------------
    NSArray<id<QCMatchToken>> *linkTokens = [QCRichTextParseService.shared parseLink:text];
    if(linkTokens && linkTokens.count>0) {
        for (id<QCMatchToken> linkToken in linkTokens) {
            if(linkToken.type != WKatchTokenTypeLink) {
                continue;
            }
            BOOL locationInRange = false;
            if(newMentionEntities.count>0) {
                for (QCMessageEntity *mentionEntity in newMentionEntities) {
                    if(NSLocationInRange(linkToken.range.location, mentionEntity.range)) {
                        locationInRange = true;
                        break;
                    }
                }
            }
            if(!locationInRange) {
                QCMessageEntity *entity = [[QCMessageEntity alloc] init];
                entity.type = QCLinkRichTextStyle;
                entity.range = linkToken.range;
                [entities addObject:entity];
            }
        }
    }
    
    
    return entities;
}

-(NSArray<QCMessageEntity*>*) entities:(NSString*)text {
    
    return [self entities:text mentionCache:self.mentionCache];
}

-(QCMentionedInfo*) mentionedInfo:(NSString*)text mentionCache:(QCInputMentionCache*)mentionCache{
    QCMentionedInfo  *mentionedInfo;
    NSArray<NSString*> *mentionUids = [mentionCache allMentionUid:text];
    if(mentionUids && mentionUids.count>0) {
        if([mentionUids containsObject:@"all"]) {
            mentionedInfo = [[QCMentionedInfo alloc] initWithMentionedType:WK_Mentioned_All];
        }else{
            mentionedInfo = [[QCMentionedInfo alloc] initWithMentionedType:WK_Mentioned_Users uids:mentionUids];
        }
        
    }
    return mentionedInfo;
}

-(QCMentionedInfo*) mentionedInfo:(NSString*)text {
    return [self mentionedInfo:text mentionCache:self.mentionCache];
}

-(QCMessage*) sendTextMessage:(NSString*)text entities:(NSArray<QCMessageEntity*>*)entities robotID:(NSString*)robotID{
    if(!text || [[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        return nil;
    }
    
    NSMutableArray<QCMessageEntity*> *newEntities = [NSMutableArray arrayWithArray:entities];
    
    QCTextContent *content = [[QCTextContent alloc] initWithContent:text];
    
    QCMessage *editMessage = self.conversationView.editMessage;
    
    // -------------------- @ 设置 --------------------
    if(editMessage) {
        content.mentionedInfo = [self mentionedInfo:text];
        QCMessageContent *editContent = editMessage.content;
        if(editMessage.remoteExtra.contentEdit) {
            editContent = editMessage.remoteExtra.contentEdit;
        }
        NSArray<QCMessageEntity*> *oldEntities = editContent.entities;
        NSString *oldText = ((QCTextContent*)editContent).content;
        if(oldEntities && oldEntities.count>0) {
            for (QCMessageEntity *oldEntity in oldEntities) {
                if([oldEntity.type isEqualToString:QCMentionRichTextStyle]) {
                    QCInputMentionItem *inputMentionItem = [QCInputMentionItem new];
                    inputMentionItem.uid = oldEntity.value;
                    inputMentionItem.name = [oldText substringWithRange:NSMakeRange(oldEntity.range.location+1, oldEntity.range.length-1)];
                    
                    [self.mentionCache addMentionItem:inputMentionItem];
                }
            }
        }
        
    }else{
        content.mentionedInfo = [self mentionedInfo:text];
       
    }
    
    
    [newEntities addObjectsFromArray:[self entities:text]];
     
   
    [self.mentionCache clean];
    

    
    // ---------- 回复逻辑  ----------
    QCMessage *replyMessage = self.conversationView.replyMessage;
    if(replyMessage) {
        QCReply *reply = [QCReply new];
        reply.messageID = [NSString stringWithFormat:@"%llu",replyMessage.messageId];
        
        reply.messageSeq = replyMessage.messageSeq;
        reply.fromUID = replyMessage.fromUid;
        if(replyMessage.from) {
            reply.fromName = replyMessage.from.name;
        }
        reply.content = replyMessage.content;
        content.reply = reply;
        
        // 清除回复状态
        self.conversationView.replyMessage = nil;
        __weak typeof(self) weakSelf = self;
        [self.conversationView.input setTopView:nil animateBlock:^{
            [weakSelf.conversationView layoutSubviews];
        }];
    }
    // ---------- 编辑逻辑  ----------
   
    if(editMessage) {
        QCTextContent *newTextContent = [[QCTextContent alloc] initWithContent:text];
        if(newEntities&&newEntities.count>0) {
            newTextContent.entities = newEntities;
        }
        content.robotID = robotID;
        [[QCSDK shared].chatManager editMessage:editMessage newContent:newTextContent];
        self.conversationView.editMessage = nil;
        __weak typeof(self) weakSelf = self;
        [self.conversationView.input setTopView:nil animateBlock:^{
            [weakSelf.conversationView layoutSubviews];
        }];
        [self.conversationView.messageListView reloadData];
        
        [self.conversationView.messageListView animateMessageWithBlock:^{
            [self.conversationView layoutSubviews];
        }];
        
        return editMessage;
    }
    
  
    
    // ---------- 其它逻辑  ----------
    if(newEntities.count>0) {
        content.entities = newEntities;
    }
    content.robotID = robotID;
    
  return  [self sendMessage:content];
}


-(QCMessage*) sendMessage:(QCMessageContent*)content {
    // ---------- 全局禁言拦截 ----------
    QCAppRemoteConfig *rc = [QCApp shared].remoteConfig;
    if(rc) {
        if(self.channel.channelType == WK_GROUP && rc.disableGroupMessageOn) {
            NSString *tip = (rc.muteTextOfGroup && rc.muteTextOfGroup.length>0) ? rc.muteTextOfGroup : LLang(@"群聊禁言中");
            [QCAlertUtil alert:tip];
            return nil;
        }
        if((self.channel.channelType == WK_PERSON || self.channel.channelType == WK_CustomerService) && rc.disablePrivateMessageOn) {
            NSString *tip = (rc.muteTextOfPrivate && rc.muteTextOfPrivate.length>0) ? rc.muteTextOfPrivate : LLang(@"私聊禁言中");
            [QCAlertUtil alert:tip];
            return nil;
        }
    }
    QCSetting *setting = [QCSetting new];
    // 私聊默认开启已读回执，群聊不开启
    if(self.channel.channelType == WK_PERSON) {
        setting.receiptEnabled = YES;
    } else if(self.conversationVM.channelInfo) {
        setting.receiptEnabled = self.conversationVM.channelInfo.receipt;
    }
    if(self.conversationVM.channelInfo) {
        if(self.conversationVM.channelInfo.extra[@"msg_auto_delete"]) {
            setting.expire = [self.conversationVM.channelInfo.extra[@"msg_auto_delete"] integerValue];
        }
    }
//    if(self.channel.channelType == WK_PERSON) {
//        setting.signal = true; // 个人聊天进行signal加密
//    }
    
    // ---------- 阅后即焚  ----------
    QCChannelInfo *channelInfo = [self getChannelInfo];
    if(channelInfo && channelInfo.flame) {
        content.flame = channelInfo.flame;
        content.flameSecond = channelInfo.flameSecond;
    }
    NSString *topic = @"";
    if(self.conversationVM.channelInfo && self.conversationVM.channelInfo.parentChannel) {
        topic = [NSString stringWithFormat:@"%@@%hhu",self.conversationVM.channelInfo.parentChannel.channelId,self.conversationVM.channelInfo.parentChannel.channelType];
    }
    
    QCMessage *message = [[[QCSDK shared] chatManager] sendMessage:content channel:self.channel setting:setting topic:topic];
    if([[QCSDK shared].chatManager needStoreOfIntercept:message]) {
        [self.conversationView.messageListView sendMessage:[[QCMessageModel alloc] initWithMessage:message]];
    }
    return message;
    
}

-(void) resendMessage:(QCMessage*)message {
    
    QCMessageModel *messageModel = [[QCMessageModel alloc] initWithMessage:message];
    [self.conversationView.messageListView removeMessage:messageModel];
    
    QCMessage *newMessage = [[[QCSDK shared] chatManager] resendMessage:message];
    QCMessageModel *newMessageModel = [[QCMessageModel alloc] initWithMessage:newMessage];
    if([[QCSDK shared].chatManager needStoreOfIntercept:newMessage]) {
        [self.conversationView.messageListView sendMessage:newMessageModel];
    
    }
}

- (void)forwardMessage:(QCMessageContent *)content {
    QCMessage *message = [[QCSDK shared].chatManager forwardMessage:content channel:self.channel];
    [self.conversationView.messageListView sendMessage:[[QCMessageModel alloc] initWithMessage:message]];
}

-(void) longPressMessageCell:(QCMessageCell*)messageCell gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer{
//    if (self.messageActionsVCIsShow) {
//         return;
//     }
//    return;
    
    __weak typeof(self) weakSelf = self;
//    if(self.conversationView.input.keyboardHeight>0) {
//        self.conversationView.keepKeyboard = true;
//        [self endEditing];
//    }
//
    QCMessageModel *contextMessage = messageCell.messageModel;
    
    NSArray<QCMessageLongMenusItem*> *toolbarMenus;
    if(contextMessage.content.flame) {
        QCMessageLongMenusItem *revokeToolbarMenus = [[QCApp shared] invoke:QCPOINT_LONGMENUS_REVOKE param:@{@"message":contextMessage}];
        if(revokeToolbarMenus) {
            toolbarMenus = @[revokeToolbarMenus];
        }
    }else{
        toolbarMenus = [[QCApp shared] invokes:QCPOINT_CATEGORY_MESSAGE_LONGMENUS param:@{@"message":contextMessage}];
    }
    
    QCMessageContextController *messageContextController = [[QCMessageContextController alloc] initWithMessage:messageCell.messageModel context:self menusItems:toolbarMenus gesture:(ContextGesture*)gestureRecognizer];
    messageContextController.onDismissed = ^{
//        if(weakSelf.conversationView.keepKeyboard) {
//            weakSelf.conversationView.keepKeyboard = false;
//            [self.conversationView.input becomeFirstResponder];
//        }
    };
    __weak typeof(messageContextController) weakController = messageContextController;
    messageContextController.reactionSelected = ^(QCReactionContextItem * item, BOOL isLarge) {
        [[QCSDK shared].reactionManager addOrCancelReaction:item.reaction messageID:messageCell.messageModel.messageId complete:^(NSError * _Nullable error) {
            [weakController dismiss];
        }];
    };
    [messageContextController setup];
    [messageContextController show];
}

-(void) addMentionUserHandleVCIfNeed {
    if(self.mentionUserHandleVC.parentViewController) {
        return;
    }
    UIViewController *parentVC = self.conversationView.lim_viewController;
    [self layoutMentionUserHandle];
    [parentVC addChildViewController:self.mentionUserHandleVC];
    [self.conversationView insertSubview:self.mentionUserHandleVC.view belowSubview:self.conversationView.input];
    [self.mentionUserHandleVC didMoveToParentViewController:parentVC];
    
}


//keyword = nil为显示所有 keyword=“” 都不显示
-(void) getMentionUserListWithKeyword:(NSString*)keyword complete:(void(^)(NSArray<QCMentionUserCellModel*>*users))complete{

    __weak typeof(self) weakSelf = self;
    
    [[QCGroupManager shared] searchMembers:self.channel keyword:keyword limit:20 complete:^(QCChannelMemberCacheType cacheType, NSArray<QCChannelMember *> * _Nonnull members) {
        QCMemberRole role =  weakSelf.conversationVM.memberRole;
        
        NSArray<QCMentionUserCellModel*>*users = [weakSelf membersToMentionUsers:members role:role keyword:keyword];
        if(complete) {
            complete(users);
        }
    }];
    
   
}

-(NSArray<QCMentionUserCellModel*>*) membersToMentionUsers:(NSArray<QCChannelMember*>*)members role:(QCMemberRole)role keyword:(NSString*)keyword{
    
    NSMutableArray<QCMentionUserCellModel*> *users = [NSMutableArray array];
    BOOL isManager =  false;
    if(role == QCMemberRoleCreator || role == QCMemberRoleManager) {
        isManager = true;
    }
    if(isManager) {
        NSString *allStr = LLang(@"所有人");
        if(!keyword || [keyword isEqualToString:@""] || [allStr containsString:keyword]) {
            [users addObject:[QCMentionUserCellModel uid:@"all" name:allStr]];
        }
    }
    if(members && members.count>0) {
        for (QCChannelMember *member in members) {
            if([member.memberUid isEqualToString:[QCApp shared].loginInfo.uid]) { // 自己不在@列表那
                continue;
            }
            NSString *name = member.displayName;
            BOOL contain = false;
            if(![keyword isEqualToString:@""]) {
                if([name containsString:keyword]) {
                    contain = true;
                }
            }else{
                contain = true;
            }
            if(contain) {
                [users addObject:[QCMentionUserCellModel uid:member.memberUid name:member.displayName avatarURL:[NSURL URLWithString: [QCAvatarUtil getAvatar:member.memberUid]] robot:member.robot]];
            }
        }
    }
    return users;
}

-(void) layoutMentionUserHandle {
    self.mentionUserHandleVC.view.frame = CGRectMake(0.0f, 0.0f, self.conversationView.lim_width, self.conversationView.lim_height - self.conversationView.input.lim_height);
}

-(BOOL) array:(NSArray<QCMentionUserCellModel*>*)array1 isEqualTo:(NSArray<QCMentionUserCellModel*>*)array2 {
    if(array1.count!=array2.count) {
        return false;
    }
    for (NSInteger i=0;i<array1.count;i++) {
        QCMentionUserCellModel *userModel1 =  array1[i];
        QCMentionUserCellModel *userModel2 =  array2[i];
        if(![userModel1.uid isEqualToString:userModel2.uid]){
            return false;
        }
    }
    return true;
}

- (BOOL)forbidden {
    if(self.conversationVM.memberOfMe && (self.conversationVM.memberOfMe.role == QCMemberRoleCreator || self.conversationVM.memberOfMe.role == QCMemberRoleManager)) {
        return false;
    }else {
        if(self.conversationVM.channelInfo) {
            NSInteger forbiddenExpirTime = [self.conversationVM.memberOfMe.extra[@"forbidden_expir_time"] integerValue];
            BOOL forbidden = self.conversationVM.channelInfo.forbidden || forbiddenExpirTime > 0;
            return forbidden;
        }
    }
    return false;
}


// 是否显示了@列表
-(BOOL) isShowMentionUserHandle {
    if(self.mentionUserHandleVC.parentViewController && self.mentionUserHandleVC.items.count>0) {
        return true;
    }
    return false;
}


- (QCUserHandleVC *)mentionUserHandleVC {
    if(!_mentionUserHandleVC) {
        _mentionUserHandleVC = [[QCUserHandleVC alloc] init];
        [_mentionUserHandleVC setRegisterCellBlock:^(UITableView *tableView,NSString * _Nonnull reuseIdentifier) {
            [tableView registerClass:QCMentionUserCell.class forCellReuseIdentifier:reuseIdentifier];
        }];
        __weak typeof(self) weakSelf = self;
        [_mentionUserHandleVC setOnSelect:^(QCFormItemModel * _Nonnull model) {
            QCMentionUserCellModel *userModel = (QCMentionUserCellModel*)model;
        
            NSString *str =  [weakSelf addMentionToCache:@[userModel.uid]];
            [weakSelf.conversationView.input replaceInputingMention:str];
        }];
    }
    return _mentionUserHandleVC;
}


-(NSString*) addMentionToCache:(NSArray<NSString*>*)uids {
    if(!uids || uids.count==0) {
        return @"";
    }
    NSArray<QCChannelMember*> *mentionMembers = [[QCChannelMemberDB shared] getMembersWithChannel:self.channel uids:[uids filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (SELF in %@)",@"all"]]];
    NSMutableString *str = [[NSMutableString alloc] initWithString:@""];
    
    NSMutableDictionary *memberDict = [NSMutableDictionary dictionary];
    if(mentionMembers && mentionMembers.count>0) {
        for (QCChannelMember *mentionMember in mentionMembers) {
            memberDict[mentionMember.memberUid?:@""] = mentionMember;
        }
    }

    for (NSString *uid in uids) {
        
        QCChannelMember *mentionMember =  memberDict[uid];
        
        QCInputMentionItem *item = [[QCInputMentionItem alloc] init];
        item.uid  = uid;
        if(mentionMember) {
            if(mentionMember.memberRemark && ![mentionMember.memberRemark isEqualToString:@""]) {
                item.name = [self handleMentionName:mentionMember.memberRemark];
            }else {
                item.name = [self handleMentionName:mentionMember.memberName];
            }
        }else if([uid isEqualToString:@"all"]) {
            item.name = LLang(@"所有人");
        }else  { // 这种情况是群成员退群了，不在群里
           QCChannelInfo *memberUserInfo =  [[QCSDK shared].channelManager getChannelInfo:[QCChannel personWithChannelID:uid]];
            if(memberUserInfo) {
                item.name = [self handleMentionName:memberUserInfo.name];
                
            }else {
                item.name = @""; // 这种情况理论上应该不会发生，如果发生则给个空字符串避免闪退
            }
        }
       
        [self.mentionCache addMentionItem:item];
        [str appendString:QCInputAtStartChar];
        [str appendString:item.name];
        [str appendString:QCInputAtEndChar];
    }
    return str;
}

-(NSString*) handleMentionName:(NSString*)oldName {
    if(!oldName) {
        return @"";
    }
    return oldName;
//    NSString *newName = [oldName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    if([newName containsString:@" "]) { // 如果名字里包含空格 则取空格的前部（仿tg）
//       NSArray<NSString*> *nameArray = [newName componentsSeparatedByString:@" "];
//        newName = nameArray[0];
//    }
//    return newName;
}

- (QCInputMentionCache *)mentionCache {
    if(!_mentionCache) {
        _mentionCache = [QCInputMentionCache new];
    }
    return _mentionCache;
}

- (BOOL)isFuncGroupZooming {
    return [self.conversationView.input isFuncGroupZooming];
}

- (void)stopFuncGroupZoom {
    [self.conversationView.input stopFuncGroupZoom];
}

-(void) refreshInputView {
    [self.conversationView.input updateAndLayoutTextViewRightView];
}

- (BOOL)hasInputText {
    NSString *text = [self.conversationView.input inputText];
    if(text && ![text isEqualToString:@""]) {
        return  true;
    }
    return false;
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

- (void)addInputDelegate:(id<QCConversationInputDelegate>)delegate {
    [self.delegateLock lock];//防止多线程同时调用
    [self.delegates addObject:delegate];
    [self.delegateLock unlock];
}

- (void)removeInputDelegate:(id<QCConversationInputDelegate>)delegate {
    [self.delegateLock lock];//防止多线程同时调用
    [self.delegates removeObject:delegate];
    [self.delegateLock unlock];
}

-(void) callConversationInputChangeDelegate {
    [self.delegateLock lock];
    NSHashTable *copyDelegates =  [self.delegates copy];
    [self.delegateLock unlock];
    for (id delegate in copyDelegates) {//遍历delegates ，call delegate
        if(!delegate) {
            continue;
        }
        if ([delegate respondsToSelector:@selector(conversationInputChange:)]) {
            if (![NSThread isMainThread]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate conversationInputChange:self];
                });
            }else {
                [delegate conversationInputChange:self];
            }
        }
    }
}

- (void)dealloc {
    NSLog(@"[QCConversationContextImpl dealloc]");
}

@end
