//
//  QCConstant.h
//  WuKongBase
//
//  Created by tt on 2019/12/7.
//


#import <WuKongIMSDK/WuKongIMSDK.h>

#define QCScreenWidth                              [UIScreen mainScreen].bounds.size.width
#define QCScreenHeight                             [UIScreen mainScreen].bounds.size.height


// ---------- point ----------

// ---------- 登录相关 ----------
// 显示登录界面
#define QCPOINT_LOGIN_SHOW @"login.show"
// 登录成功
#define QCPOINT_LOGIN_SUCCESS @"login.success"
// 清除登录信息
#define QCPOINT_LOGIN_CLEARLOGININFO @"login.clearLoginInfo"
// 退出登录
#define QCPOINT_LOGIN_LOGOUT @"login.logout"

// ---------- 聊天相关 ----------
// 显示聊天界面
#define QCPOINT_CONVERSATION_SHOW @"conversation.list.show"
// 开始聊天
#define QCPOINT_CONVERSATION_STARTCHAT @"conversation.list.startchat"
// 扫一扫
#define QCPOINT_CONVERSATION_SCAN @"conversation.list.scan"

// 跳到聊天页面（根据channelType进行处理）
#define QCPOINT_CATEGORY_CONVERSATION_SHOW @"conversation.list.category.show"

#define QCPOINT_CONVERSATION_SHOW_DEFAULT @"conversation.list.show.default"

// 面板
#define QCPOINT_CATEGORY_PANEL @"panel"
// emoji面板
#define QCPOINT_PANEL_EMOJI @"panel.emoji"
// 面板正文
#define QCPOINT_CATEGORY_PANELCONTENT @"panel.panelcontent"


// emoji面板正文-emoji
#define QCPOINT_PANELCONTENT_EMOJI @"panelcontent.emoji"
// emoji面板正文- 收藏
#define QCPOINT_PANELCONTENT_COLLECTION @"panelcontent.collection"
// emoji面板正文- 热图
#define QCPOINT_PANELCONTENT_HOT @"panelcontent.hot"
// 更多面板
#define QCPOINT_PANEL_MORE @"panel.more"
// 录音
#define QCPOINT_PANEL_VOICE @"panel.voice"
// 聊天页面设置
#define QCPOINT_CONVERSATION_SETTING @"conversation.setting"

// ---------- 消息相关 ----------

// 消息长按菜单项类别
#define QCPOINT_CATEGORY_MESSAGE_LONGMENUS @"message.longmenus"

// 合并转发
#define QCPOINT_CATEGORY_MERGEFORWARD_ITEM @"mergeforward.item"

// 长按菜单 - 添加表情
#define QCPOINT_LONGMENUS_ADDEMOJI @"longmenus.addemoji"
// 长按菜单 - 复制
#define QCPOINT_LONGMENUS_COPY @"longmenus.copy"
// 长按菜单 - 删除
#define QCPOINT_LONGMENUS_DELETE @"longmenus.delete"
// 长按菜单 - 回复
#define QCPOINT_LONGMENUS_REPLY @"longmenus.reply"
// 长按菜单 - 多选
#define QCPOINT_LONGMENUS_MULTIPLE @"longmenus.multiple"

// 长按菜单 - 转发
#define QCPOINT_LONGMENUS_FORWARD @"longmenus.forward"
// 长按菜单 - 撤回
#define QCPOINT_LONGMENUS_REVOKE @"longmenus.revoke"
// 长按菜单 - 编辑
#define QCPOINT_LONGMENUS_EDITOR @"longmenus.editor"
// 长按菜单 - 转发
#define QCPOINT_LONGMENUS_FORWARD @"longmenus.forward"
// 长按菜单 - 回应/点赞
#define QCPOINT_LONGMENUS_REACTIONS @"longmenus.reactions"
// 长按菜单 - 收藏
#define QCPOINT_LONGMENUS_FAVORITE @"longmenus.favorite"
// 长按菜单 - 已读
#define QCPOINT_LONGMENUS_READED @"longmenus.readed"

// 长按菜单 - 消息回应
#define QCPOINT_LONGMENUS_REACTIONS @"longmenus.reactions"

// 长按菜单 - 置顶
#define QCPOINT_LONGMENUS_PIN @"longmenus.pin"



// ---------- 消息扩展 ----------

#define QCPOINT_MESSAGEEXTEND_REACTIONVIEW @"messageextend.reactionview" // 消息点赞的view
// ---------- 聊天面板相关 ----------

// 更多面板里的item的分类point
#define QCPOINT_CATEGORY_PANELMORE_ITEMS @"panelmore.items"
// 更多面板-> 照片
#define QCPOINT_PANELMORE_PHOTO @"panelmore.photo"
// 更多面板-> 拍照
#define QCPOINT_PANELMORE_CAMERA @"panelmore.camera"

// 最近会话输入框输入文本响应
#define QCPOINT_CATEGORY_CONVERSATION_INPUT_TEXT_RESPOND @"conversation_input_text_respond"
// emoji输入或删除输入框的响应事件
#define QCPOINT_EMOJI_INPUT_TEXT_RESPOND @"emoji_input_text_respond"

// 聊天输入框的右边视图
#define QCPOINT_CATEGORY_TEXTVIEW_RIGHTVIEW @"conversation_input_textview_rightview"

// 会话输入框文本改变
#define QCPOINT_CATEGORY_CONVERSATION_INPUT_TEXT_CHANGE @"conversation_input_text_change"
#define QCPOINT_ROBOT_INPUT_TEXT_CHANGE @"robot_input_text_change" 

// 面板功能
#define QCPOINT_CATEGORY_PANELFUNCITEM @"panel.func.item"
// emoji
#define QCPOINT_CATEGORY_PANELFUNCITEM_EMOJI @"panel.func.item.emoji"

// mention
#define QCPOINT_CATEGORY_PANELFUNCITEM_MENTION @"panel.func.item.mention"
// voice
#define QCPOINT_CATEGORY_PANELFUNCITEM_VOICE @"panel.func.item.voice"
// image
#define QCPOINT_CATEGORY_PANELFUNCITEM_IMAGE @"panel.func.item.image"
// camera
#define QCPOINT_CATEGORY_PANELFUNCITEM_CAMERA @"panel.func.item.camera"
// camera
#define QCPOINT_CATEGORY_PANELFUNCITEM_LOCATION @"panel.func.item.location"
// card
#define QCPOINT_CATEGORY_PANELFUNCITEM_CARD @"panel.func.item.card"
// file
#define QCPOINT_CATEGORY_PANELFUNCITEM_FILE @"panel.func.item.file"
// 搜索记录里的文件item视图
#define QCPOINT_SEARCH_ITEM_FILE @"search.item.file"


// call
#define QCPOINT_CATEGORY_PANELFUNCITEM_CALL @"panel.func.item.call"
// more
#define QCPOINT_CATEGORY_PANELFUNCITEM_MORE @"panel.func.item.more"
// 发送视频
#define QCPOINT_SEND_VIDEO @"panel.send.video"

// 历史消息搜索里的小视频item
#define QCPOINT_SEARCH_ITEM_VIDEO @"search.item.video"

// 最近会话的顶部面板
#define QCPOINT_CONVERSATION_TOP_PANEL @"conversation.top.panel"

// ---------- 表情商店相关 ----------
// 跳到表情商店
#define QCPOINT_TO_STICKER_STORE @"to.sticker.store"
// 跳到表情详情
#define QCPOINT_TO_STICKER_INFO @"to.sticker.info"
// 跳到表情收藏
#define QCPOINT_TO_STICKER_COLLECTION @"to.sticker.collection"

// ---------- 联系人相关 ----------
// 显示添加联系人界面
#define QCPOINT_CONVERSATION_ADDCONTACTS @"conversation.list.addcontacts"

// 显示联系人信息
#define QCPOINT_CONTACTSINFO_SHOW @"contacts.info.show"

// 选择联系人数据的列表
#define QCPOINT_CONTACTS_SELECT_DATA @"contacts.select.data"

// 联系人选择
#define QCPOINT_CONTACTS_SELECT @"contacts.select"

// 联系人头部item
#define QCPOINT_CATEGORY_CONTACTSITEM @"contacts.header.item"

// 联系人信息更新通知
#define WK_NOTIFY_CONTACTS_UPDATE @"notify.contacts.update"
// 联系人tab红点更新
#define WK_NOTIFY_CONTACTS_TAB_REDDOT_UPDATE @"notify.contacts.tab.reddot.update"
// 联系人头更新
#define WK_NOTIFY_CONTACTS_HEADER_UPDATE @"notify.contacts.header.update"

// 联系人UI顶部的header的新朋友item
#define WK_CONTACTS_HEADER_ITEM_NEWFRIEND @"newFriend"
// 联系人tab的红点
#define WK_CONTACTS_CATEGORY_TAB_REDDOT @"contacts.tab.reddot"

// ---------- 扫一扫 ----------
// 处理者
#define QCPOINT_CATEGORY_SCAN_HANDLER @"scan.handlers"
// 扫码进群
#define QCPOINT_SCAN_HANDLER_JOIN_GROUP @"scan.handler.joinGroup"
// 扫码加好友
#define QCPOINT_SCAN_HANDLER_ADD_FRIEND @"scan.handler.addFriend"
// 扫码打开webview
#define QCPOINT_SCAN_HANDLER_WEBVIEW @"scan.handler.webview"
// 扫码授权登录
#define QCPOINT_SCAN_HANDLER_GRANTLOGIN @"scan.handler.grantLogin"


// ---------- 频道设置 ----------

#define QCPOINT_CATEGORY_CHANNELSETTING @"channelsetting"

// ---------- 群管理 ----------
// 显示群管理
#define QCPOINT_GROUPMANAGER_SHOW @"group.manager.show"

// ---------- 我的 ----------
//我的
#define QCPOINT_CATEGORY_ME @"me"
// 收藏
#define QCPOINT_ME_FAVORITE @"me.favorite"
// 新消息通知
#define QCPOINT_ME_NEWMSGNOTICE @"me.newMsgNotice"
// web端
#define QCPOINT_ME_WEB @"me.webclient"
// 通用
#define QCPOINT_ME_COMMON @"me.common"
// 安全与隐私
#define QCPOINT_ME_SECURITY @"me.security"

// 我的邀请码
#define QCPOINT_ME_INVITE @"me.invite"

// ---------- 通用设置 ----------

#define QCPOINT_CATEGORY_COMMONSETTING @"commonsetting"

// ---------- 个人资料相关 ----------

// 用户信息
#define QCPOINT_USER_INFO @"user.info"

// 用户信息页面的类别item
#define QCPOINT_CATEGORY_USER_INFO_ITEM @"user.info.item.category"

// ---------- 最近会话列表的+号 ----------
#define QCPOINT_CATEGORY_CONVERSATION_ADD @"conversation.add.category"

#define QCPOINT_CONVERSATION_ADD_STARTCHAT @"conversation.add.startchat" // 发起聊天
#define QCPOINT_CONVERSATION_ADD_ADDFRIEND @"conversation.add.addfriend" // 添加朋友
#define QCPOINT_CONVERSATION_ADD_SCAN @"conversation.add.scan" // 扫一扫
// ---------- 其他 ----------

// 同步数据
#define QCPOINT_CATEGORY_SYNC @"sync"
// 视频通话支持的方法
#define QCPOINT_VIDEOCALL_SUPPORT_FNC @"videocall.support.fnc"
// 同步联系人
#define QCPOINT_SYNC_CONTACTS @"sync.contacts"
// 同步违禁词
#define QCPOINT_SYNC_PROHIBITWORDS @"sync.prohibitwords"

#define QCPOINT_LABEL_DATA_LIST @"labels.data.list" // 标签数据列表
#define QCPOINT_LABEL_UI_DETAIL @"labels.ui.detail" // 标签详情UI
#define QCPOINT_LABEL_UI_SAVE @"labels.ui.save" // 存为标签


//-----------音视频状态相关-------
#define QCPOINT_CONVERSATION_LISTEN @"conversation.listen"
//#define QCPOINT_CONVERSATION_RECORD_LISTEN @"conversation.listen.record"
//#define QCPOINT_CONVERSATION_TALKBACK_LISTEN @"conversation.listen.talkback"
#define QCPOINT_CALL_STATUS @"call.status"


// ---------- 通知 ----------
// 群成员更新
#define QCNOTIFY_GROUP_MEMBERUPDATE @"group.memberupdate"
// 用户头像更新
#define QCNOTIFY_USER_AVATAR_UPDATE @"user.avatarupdate"
// 输入中
#define QCNOTIFY_TYPING @"typing"
// 系统语言改变
#define QCNOTIFY_LANG_CHANGE @"lim.lang.change"
// 系统模块发生改变
#define QCNOTIFY_MODULE_CHANGE @"lim.module.change"
// 聊天背景改变
#define QCNOTIFY_CHATBACKGROUND_CHANGE @"lim.chatbackground.change"
// 频道头像更新
#define QCNOTIFY_CHANNEL_AVATAR_UPDATE @"channel.avatarupdate"
// 标签列表刷新
#define WK_NOTIFY_LABELLIST_REFRESH @"lim.notify.labellist.refresh"
// 远程 app 配置（含全局禁言开关）已更新
#define QCNOTIFY_APP_REMOTE_CONFIG_UPDATE @"lim.app.remoteconfig.update"

// 消息类型
typedef enum : NSUInteger {
    
    // 1- 999 为业务消息
    WK_SMALLVIDEO = 5, // 小视频
    WK_LOCATION = 6, // 位置消息
    WK_CARD = 7, // 名片
    WK_FILE = 8, // 文件
    WK_REDPACKET = 9, // 红包
    WK_TRANSFER = 10, // 转账消息
    
    WK_MERGEFORWARD = 11, // 合并转发
    
    WK_LOTTIE_STICKER = 12, // lottie贴图
    
    WK_EMOJI_STICKER = 13, // emoji贴图
    
    WK_RICHTEXT = 14, // 富文本消息类型
    
    WK_TYPING = 101, // 正在输入
    
    WK_SCREENSHOT = 20, // 截屏通知
    
    // 1000-2000 为系统消息
    WK_FRIEND_REQUEST = 1000, // 好友邀请请求（这个消息应该不使用了，因为走cmd了）
    WK_GROUP_MEMBERADD = 1002, // 添加群成员
    WK_GROUP_MEMBERREMOVE = 1003, // 移除群成员
    WK_FRIEND_ACCEPTED = 1004, // 好友接受邀请
    WK_GROUP_UPDATE = 1005, // 群数据更新
    WK_MESSAGE_REVOKE = 1006, // 消息撤回
    WK_GROUP_MEMBERSCANJOIN = 1007, // 用户扫码入群
    WK_GROUP_TRANSFERGROUPER = 1008, // 转让群主
    WK_GROUP_MEMBERINVITE = 1009, // 邀请入群
    WK_GROUP_MEMBERREFUND = 1010, // 成员拒绝入群
    
    WK_REDPACKET_OPEN = 1011, // 红包领取tip（由服务端下发）
    
    WK_TRADE_SYSTEM_NOTIFY = 1012, // 交易系统通知（比如：转账退回，红包退回）
    
    WK_GROUP_FORBIDDEN_ADD_FRIEND = 1013, // 群内禁止互加好友
    
   
    
    WK_GROUP_UPGRADE = 1022, // 群升级
    
    WK_TIP = 2000, // tip消息
    
    // 音频通话消息号段 9900 - 9999
    WK_VIDEOCALL_RESULT = 9989, // 音视频通话结果
    WK_VIDEOCALL_SWITCH_TO_VIDEO = 9990, // 切换到视频
    WK_VIDEOCALL_SWITCH_TO_VIDEO_REPLY = 9991, // 切换到视频回复
    WK_VIDEOCALL_CANCEL = 9992, // 通话取消
    WK_VIDEOCALL_SWITCH = 9993, // 音视频切换（未接通时）
    WK_VIDEOCALL_DATA = 9994, // RTC数据传输
    WK_VIDEOCALL_MISSED = 9995, // 未接听
    WK_VIDEOCALL_RECEIVED = 9996, // 收到通话
    WK_VIDEOCALL_REFUSE = 9997, // 拒绝通话
    WK_VIDEOCALL_ACCEPT = 9998, // 接受通话
    WK_VIDEOCALL_HANGUP = 9999, // 挂断通话
    
    // 20000 - 30000 为本地自定义消息
    WK_HISTORY_SPLIT = 20000, // 历史消息分割线  ----- 以上为历史消息 -----
    WK_ENDTOEND_ENCRYPT_HIT = 20001, // 端对端加密提示
    
    
} QCContentTypeExtend;

// 好友请求状态
typedef enum : NSUInteger {
    QCFriendRequestStatusWaitSure = 0, // 等待确认
    QCFriendRequestStatusSured = 1, // 已确认
} QCFriendRequestStatus;


typedef enum : NSUInteger {
    QCHistoryMessageSearchTypeAll, // 搜索所有
    QCHistoryMessageSearchTypeContacts, // 搜索联系人
    QCHistoryMessageSearchTypeMessages, // 搜索消息
    QCHistoryMessageSearchTypeConversation, // 搜索最近会话
} QCHistoryMessageSearchType;

// 呼叫类型
typedef enum : NSUInteger {
    QCCallTypeAudio = 0, // 语音呼叫
    QCCallTypeVideo, // 视频呼叫
    QCCallTypeAll,
} QCCallType;


typedef enum : uint8_t {
    WK_CustomerService = 3, // 客服
    WK_Community = 4 // 社区
} QCChannelTypeExt;

typedef enum NSInteger {
    QCRequestStrategyUnknown = -1, // 未知
    QCRequestStrategyAll = 0, // 请求所有(请求db和网络的数据)
    QCRequestStrategyOnlyDB = 1, // 仅仅请求db内的数据
    QCRequestStrategyOnlyNetwork = 2 // 仅仅请求网络的数据
} QCRequestStrategy;

#define QCReminderTypeMemberInvite 1001 // 进群申请

// 频道类别
// 客服
#define QCChannelCategoryService @"system" // 系统账号
#define QCChannelCategoryVisitor @"visitor" // 访客
#define QCChannelCategoryCustomerService @"customerService" // 客服


#define WK_Dispatch_Async_Main(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

typedef void(^QCOnClick)(void);




// cmd命令集合
static NSString *QCCMDVideoCall = @"videoCall"; // 音视频呼叫
static NSString *QCCMDMemberUpdate = @"memberUpdate"; //群成员更新
static NSString *QCCMDUnreadClear = @"unreadClear"; // 清除频道未读数
static NSString *QCCMDGroupAvatarUpdate = @"groupAvatarUpdate"; // 群头像更新
static NSString *QCCMDUserAvatarUpdate = @"userAvatarUpdate"; // 用户头像更新
static NSString *QCCMDChannelUpdate = @"channelUpdate"; // 频道基础信息更新
static NSString *QCCMDVoiceReaded = @"voiceReaded"; // 语音消息置为已读
static NSString *QCCMDTyping = @"typing"; // 输入中...
static NSString *QCCMDOnlineStatus = @"onlineStatus"; // 在线状态通知
static NSString *QCCMDMessageRevoke = @"messageRevoke"; // 消息撤回
static NSString *QCCMDSyncMessageExtra = @"syncMessageExtra"; // 同步消息的扩展数据
static NSString *QCCMDSyncMessageReaction = @"syncMessageReaction"; // 同步消息回应
static NSString *QCCMDMessageEerase = @"messageEerase"; // 擦除消息
static NSString *QCCMDSyncReminders = @"syncReminders"; // 同步提醒项
static NSString *QCCMDSyncConversationExtra = @"syncConversationExtra"; // 同步最近会话扩展


//RTC
static NSString *QCCMDRTCRoomInvoke = @"room.invoke"; // RTC 房间邀请
static NSString *QCCMDRTCRoomHangup = @"room.hangup"; // RTC 挂断
static NSString *QCCMDRTCRoomRefuse = @"room.refuse"; // RTC 拒绝加入房间

static NSString *QCCMDRTCP2PInvoke = @"rtc.p2p.invoke"; // RTC 邀请
static NSString *QCCMDRTCP2PAccept = @"rtc.p2p.accept"; // RTC 接受
static NSString *QCCMDRTCP2PRefuse = @"rtc.p2p.refuse"; // RTC 拒绝
static NSString *QCCMDRTCP2PCancel = @"rtc.p2p.cancel"; // RTC 取消
static NSString *QCCMDRTCP2PHangup = @"rtc.p2p.hangup"; // RTC 挂断

typedef void(^videoCallSupportInvoke)(QCChannel *channel,QCCallType callType); // 视频调用方法


// 群类型
typedef enum : uint8_t {
    QCGroupTypeCommon = 0, // 普通群
    QCGroupTypeSuper = 1 // 超级群
} QCGroupType;


#ifndef lim_dispatch_main_async_safe
#define lim_dispatch_main_async_safe(block)\
    if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(dispatch_get_main_queue())) {\
        block();\
    } else {\
        dispatch_async(dispatch_get_main_queue(), block);\
    }
#endif





typedef NSString* QCRichTextStyle;

static QCRichTextStyle QCBoldRichTextStyle = @"bold";
static QCRichTextStyle QCColorRichTextStyle = @"color";
static QCRichTextStyle QCImageRichTextStyle = @"img";
static QCRichTextStyle QCMentionRichTextStyle = @"mention";
static QCRichTextStyle QCLinkRichTextStyle = @"link";
static QCRichTextStyle QCItalicRichTextStyle = @"italic";
static QCRichTextStyle QCUnderlineRichTextStyle = @"underline";
static QCRichTextStyle QCStrikethroughRichTextStyle = @"strikethrough";
static QCRichTextStyle QCFontRichTextStyle = @"font";
