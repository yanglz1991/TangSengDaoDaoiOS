//
//  QCConversationChannelHeader.h
//  QCCore
//
//  Created by tt on 2021/8/20.
//

#import <UIKit/UIKit.h>
#import "QCCore.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCConversationChannelHeader : UIView


@property(nonatomic,strong) UIButton *voiceCallBtn;

@property(nonatomic,strong) UIButton *videoCallBtn;

@property(nonatomic,assign) NSInteger memberCount; // 成员数量

@property(nonatomic,strong) QCChannelInfo *channelInfo; // 频道信息

@property(nonatomic,copy) void(^onInfo)(void); // 资料信息被点击

@property(nonatomic,copy) void(^onVoiceCall)(void); // 拨打语音
@property(nonatomic,copy) void(^onVideoCall)(void); // 拨打视频

- (void)viewConfigChange:(QCViewConfigChangeType)type;



@end

NS_ASSUME_NONNULL_END
