//
//  QCPanelDefaultFuncItem.m
//  WuKongBase
//
//  Created by tt on 2020/2/23.
//

#import "QCPanelDefaultFuncItem.h"
#import "QCResource.h"
#import "QCConstant.h"
#import "QCMoreItemClickEvent.h"
#import "QCFuncItemButton.h"
#import "WuKongBase.h"
#import "QCConversationContext.h"
#import "QCCardContent.h"
#import "QCFuncGroupEditVC.h"
@interface QCPanelDefaultFuncItem ()



@end

@implementation QCPanelDefaultFuncItem

-(NSString*) sid {
    return @"";
}

- (nonnull QCFuncItemButton *)itemButton:(QCConversationInputPanel*)inputPanel {
    self.inputPanel = inputPanel;
    QCFuncItemButton *btn = [[QCFuncItemButton alloc] init];
    [btn setImage:[self itemIcon] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onPressed:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:[self title] forState:UIControlStateNormal];
    return btn;
}

-(void) onPressed:(QCFuncItemButton*)btn {
    [self.inputPanel switchPanel:[self panelID]];
}

-(NSString*) title {
    return @"";
}

-(UIImage*) itemIcon {
    
    return nil;
}

-(NSString*) panelID {
    return @"";
}

- (BOOL)support:(id<QCConversationContext>)context {
    return true;
}

-(BOOL) allowEdit {
    return true;
}

-(UIImage*) getImageNameForBase:(NSString*)name {
    return [QCApp.shared loadImage:name moduleID:@"WuKongBase"];
    //    return [currentModule ImageForResource:name];
//    return  [[QCResource shared] resourceForImage:name podName:@"WuKongBase_images"];
}

@end

@implementation QCPanelEmojiFuncItem

-(BOOL) allowEdit {
    return false;
}
- (NSString *)sid {
    return @"apm.wukong.emoji";
}

- (UIImage *)itemIcon {
    return [self getImageNameForBase:@"Conversation/Toolbar/FaceNormal"];
}

- (NSString *)panelID {
    return QCPOINT_PANEL_EMOJI;
}

- (NSString *)title {
    return LLang(@"表情");
}

@end

@interface QCPanelMentionFuncItem ()


@end
@implementation QCPanelMentionFuncItem

- (NSString *)sid {
    return @"apm.wukong.mention";
}
- (UIImage *)itemIcon {
    return [self getImageNameForBase:@"Conversation/Toolbar/MentionNormal"];
}

- (BOOL)support:(id<QCConversationContext>)context {
    return context.channel.channelType != WK_PERSON;
}


-(void) onPressed:(UIButton*)btn {
    [self.inputPanel inputInsertText:@"@"];
    [self.inputPanel.conversationContext showMentionUsers];
   
}
- (NSString *)title {
    return LLang(@"@");
}

@end


@interface QCPanelVoiceFuncItem ()

@end
@implementation QCPanelVoiceFuncItem

-(BOOL) allowEdit {
    return false;
}


- (NSString *)sid {
    return @"apm.wukong.voice";
}

- (UIImage *)itemIcon {
    return [self getImageNameForBase:@"Conversation/Toolbar/VoiceNormal"];
}

- (NSString *)panelID {
    return QCPOINT_PANEL_VOICE;
}
- (NSString *)title {
    return LLang(@"语音");
}
@end



@interface QCPanelImageFuncItem ()

@end
@implementation QCPanelImageFuncItem

-(BOOL) allowEdit {
    return false;
}


- (NSString *)sid {
    return @"apm.wukong.image";
}

- (UIImage *)itemIcon {
    return [self getImageNameForBase:@"Conversation/Toolbar/ImageNormal"];
}

-(void) onPressed:(UIButton*)btn {
   
    // 图片点击
    [[QCMoreItemClickEvent shared] onPhotoItemPressed:self.inputPanel.conversationContext];
}
- (NSString *)title {
    return LLang(@"图片");
}

@end

@implementation QCPanelMoreFuncItem

- (NSString *)sid {
    return @"apm.wukong.more";
}

- (UIImage *)itemIcon {
    return [self getImageNameForBase:@"Conversation/Toolbar/MoreNormal"];
}

- (void)onPressed:(UIButton *)btn {
    QCFuncGroupEditVC *vc = [[QCFuncGroupEditVC alloc] init];
    vc.conversationContext = self.inputPanel.conversationContext;
    vc.modalPresentationStyle = UIModalPresentationPopover;
//    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
    [[QCNavigationManager shared].topViewController presentViewController:vc animated:YES completion:nil];
}
- (NSString *)title {
    return LLang(@"更多");
}

- (QCFuncGroupEditItemType)type {
    return QCFuncGroupEditItemTypeMore;
}
@end


@implementation QCPanelCardFuncItem

- (NSString *)sid {
    return @"apm.wukong.card";
}

- (UIImage *)itemIcon {
    return [self getImageNameForBase:@"Conversation/Toolbar/CardNormal"];
}

// 群聊里禁止分享名片（如需放开请删除这个 support: 方法）
- (BOOL)support:(id<QCConversationContext>)context {
    return context.channel.channelType == WK_PERSON;
}

- (void)onPressed:(UIButton *)btn {
    id<QCConversationContext> conversationContext =  self.inputPanel.conversationContext;
    NSMutableArray<NSString*> *hiddenUsers = [NSMutableArray array];
    if(conversationContext.channel.channelType == WK_PERSON) {
        [hiddenUsers addObject:conversationContext.channel.channelId];
    }
    
    [[QCApp shared] invoke:QCPOINT_CONTACTS_SELECT param:@{@"mode":@"single",@"on_finished":^(NSArray<NSString*>*uids){
        if(uids && [uids count]<=0) {
            return;
        }
        NSString *uid = uids[0];
        QCChannelInfo *channelInfo = [[QCSDK shared].channelManager getChannelInfo:[[QCChannel alloc] initWith:uid channelType:WK_PERSON]];
        if(!channelInfo) {
            QCLogDebug(@"没有查到频道信息！");
            return;
        }
        __weak typeof(self) weakSelf = self;
        id<QCConversationContext> context = self.inputPanel.conversationContext;
        
        [QCAlertUtil alert:[NSString stringWithFormat:LLangW(@"发送%@的名片到当前聊天",weakSelf),channelInfo.displayName] buttonsStatement:@[LLangW(@"取消",weakSelf),LLangW(@"确定",weakSelf)] chooseBlock:^(NSInteger buttonIdx) {
            btn.selected = false;
            if(buttonIdx == 1) {
                [[QCNavigationManager shared] popViewControllerAnimated:YES];
                
                [context sendMessage:[QCCardContent cardContent:[channelInfo extraValueForKey:QCChannelExtraKeyVercode] uid:uid name:channelInfo.name avatar:channelInfo.logo]];
            }
        }];
       
       
    },@"on_cancel":^{
        btn.selected = false;
    },@"hidden_users":hiddenUsers}];
}

- (NSString *)title {
    return LLang(@"名片");
}

@end

