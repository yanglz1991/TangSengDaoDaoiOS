//
//  WuKongBase.h
//  WuKongBase
//
//  Created by tt on 2019/12/1.
//

#import <WuKongIMSDK/WuKongIMSDK.h>

#import "QCApp.h"
#import "QCLoginInfo.h"
#import "QCBaseVM.h"
#import "QCBaseVC.h"
#import "QCWebViewVC.h"
#import "QCBaseService.h"
#import "QCBaseModule.h"
#import "QCModuleProtocol.h"
#import "QCModuleManager.h"
#import "QCAnnotation.h"
#import "QCNavigationManager.h"
#import "UIView+WK.h"
#import "UIView+QCCommon.h"
#import "QCAPIClient.h"
#import "QCModel.h"
#import "QCLogs.h"
#import "QCKitDB.h"
#import "QCDBMigration.h"
#import "QCSync.h"
#import "QCDBaseDB.h"
#import "QCConstant.h"
#import "QCCommon.h"
#import "QCFriendRequestDB.h"
#import "QCGroupManager.h"
#import "QCMessageBaseCell.h"
#import "QCContactsSelectVC.h"
#import "QCContactsSelectCell.h"
#import "QCSystemMessageHandler.h"
#import "QCMessageLongMenusItem.h"
#import "QCMessageManager.h"
#import "QCAlertUtil.h"
#import "QCBaseTableVC.h"
#import "QCBaseTableVM.h"
#import "QCScanHandler.h"
#import "QCMoneyUtil.h"
#import "QCVideoRecordUtil.h"
#import "QCVideoBrowserData.h"
#import "QCTouchTableView.h"
#import "QCLoadProgressView.h"
#import "QCTimeTool.h"
#import "QCChineseSort.h"
#import "QCLabelItemSelectCell.h"
#import "QCConversationAddItem.h"
#import "UIImageView+WK.h"
#import "QCAutoDeleteView.h"

#import "UIColor+WK.h"
#import "QCUserColorUtil.h"
#import "QCSimpleInput.h"

#import "QCMessageUtil.h"
#import "QCDefaultWebImageMediator.h"

// UIKit
#import "QCRemoteImageAttachment.h"
#import "QCConversationListVC.h"
#import "QCCell.h"
#import "QCImageView.h"
#import "QCResource.h"
#import "QCMoreItemModel.h"
#import "QCMessageCell.h"
#import "QCAvatarUtil.h"
#import "QCCorePasswordView.h"
#import "QCPwdKeyboardInputView.h"
#import "QCUserAvatar.h"
#import "QCMediaPickerController.h"
#import "QCInputVC.h"
#import "QCReactionBaseView.h"
#import "QCEmojiContentView.h"
#import "QCUserHandleVC.h"
#import "QCInputMentionCache.h"
#import "QCMentionUserCell.h"
#import "UIButton+WK.h"
#import "QCIconButton.h"
#import "QCIconSwitchButton.h"

#import "QCOfficialTag.h"
#import "QCActionSheetView2.h"

#import "QCButtonItemCell2.h"
#import "QCLabelCell.h"
#import "QCSMSCodeItemCell.h" // 短信验证码
#import "QCTextFieldItemCell.h"
#import "QCAnimateIconCell.h"

//extends
#import "QCContactsHeaderItem.h"
#import "QCContactsManager.h"

#import "QCCheckBox.h"
#import "QCMeItem.h"

#import "QCNetworkListener.h"
#import "QCPhotoService.h"

#import "QCModelConvert.h"


#import "UIDevice+Utils.h"

#import "UIImage+WK.h"

#import "QCEmoticonService.h"
#import "QCMentionService.h"
#import "M80AttributedLabel+WK.h"

#import "NSString+QCLocalized.h"
#import "QCBrowserToolbar.h"
#import "NSMutableAttributedString+WK.h"
#import "UILabel+WK.h"
#import "QCChannelUtil.h"
#import "QCChannelSettingManager.h"
#import "QCJsonUtil.h"
#import "QCPhotoBrowser.h"
#import "QCPermissionShowAlertView.h"

#import "QCUserHeaderCell.h"
#import "QCMultiLabelItemCell.h"
#import "QCImageBrowser.h"

#import "QCMessageActionManager.h"
#import "QCSchemaManager.h"

#import "QCPanelDefaultFuncItem.h"
#import "QCDowloadTask.h"
#import "QCGenerateImageUtils.h"

#import "QCStickerManager.h"
#import "QCStickerGIFContentView.h"

#import "QCMemberListVC.h"
#import "QCOnlineStatusManager.h"

#import "QCConversationVC.h"
#import "QCConversationView.h"
#import "QCMessageListView.h"
#import "QCConversationWrapModel.h"
#import "QCChannelDataManager.h"
#import "QCGrowingTextView.h"

#import "QCMergeForwardDetailCell.h"

#import "QCMessageList.h"
#import "QCThemeUtil.h"
#import "QCSearchMediaCell.h"
#import "QCSearchMessageCell.h"

#define LLang(a) [a Localized:self]
#define LLangW(a,w) [a Localized:w]
#define LLangC(a,c) [a LocalizedWithClass:c]
#define LLangB(a,b) [a LocalizedWithBundle:b]

#define LImage(name) [QCResource.shared imageNamed:name inClass:self.class]

#define QCFileHelperChannel [QCChannel personWithChannelID:@"fileHelper"] // 文件助手的频道
