//
//  QCVoiceMessageCell.m
//  QCCore
//
//  Created by tt on 2020/1/16.
//

#import "QCVoiceMessageCell.h"
#import "QCResource.h"
#import "QCBadgeView.h"
#import "QCAudioWaveformView.h"
#import <QCCore/QCCore-Swift.h>
@interface QCVoiceMessageCell ()
@property(nonatomic, strong) UIImageView *voiceImageView;
@property(nonatomic, strong) UILabel *durationLabel;
@property(nonatomic,strong) QCBadgeView *badgeView;

@property(nonatomic,strong) UIView *playBtnBoxView;

@property(nonatomic,strong) UIImageView *playIconImgView;

@property(nonatomic,strong) UIView *audioWaveformWrapView;
@property(nonatomic,strong)QCAudioWaveformView *highlightedWaveformView;
@property(nonatomic,strong) QCAudioWaveformView *audioWaveformView;

// 进度是通过蒙层实现的，蒙层为不变色的波浪，底部为变色的波浪，蒙层的宽度就是进度
@property(nonatomic,strong) UIView *maskWaveformView;


@end

@implementation QCVoiceMessageCell

+ (CGSize)contentSizeForMessage:(QCMessageModel *)model {
    QCVoiceContent *voiceContent = (QCVoiceContent*)model.content;
    CGFloat value =
    2 * atan((voiceContent.second- 1) / 10.0) / M_PI;
    NSInteger audioContentMinWidth = (170);
    NSInteger audioContentMaxWidth = [QCApp shared].config.messageContentMaxWidth;
    NSInteger audioContentHeight = 50;
    return CGSizeMake(MIN((audioContentMaxWidth - audioContentMinWidth) * value +
                          audioContentMinWidth, audioContentMaxWidth),
                          audioContentHeight);
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

- (void)initUI {
    [super initUI];
    
    [self.messageContentView addSubview:self.playBtnBoxView];
    [self.playBtnBoxView addSubview:self.playIconImgView];
    [self.messageContentView addSubview:self.audioWaveformWrapView];
   
    
    [self.audioWaveformWrapView addSubview:self.audioWaveformView];
    [self.audioWaveformWrapView addSubview:self.highlightedWaveformView];
    self.audioWaveformView.lim_height = self.audioWaveformWrapView.lim_height;
    self.highlightedWaveformView.lim_height = self.audioWaveformWrapView.lim_height;
    
    self.highlightedWaveformView.maskView = self.maskWaveformView;
//    // 声音波纹图
//    self.voiceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 20.0f)];
//    self.voiceImageView.animationDuration = 1.0;
//    [self.messageContentView addSubview:self.voiceImageView];
//
    // 声音秒数
    self.durationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.durationLabel.font = [UIFont systemFontOfSize:10.0f];
    [self.messageContentView addSubview:self.durationLabel];
//
//    // 未读红点
//    self.badgeView = [QCBadgeView viewWithBadgeTip:@""];
//    [self.bubbleBackgroundView addSubview:self.badgeView];
    
}

-(void) tapLongTapOrDoubleTapGesture:(TapLongTapOrDoubleTapGestureRecognizerWrap*)recognizer {
    [super tapLongTapOrDoubleTapGesture:recognizer];
    if(recognizer.tapAction == QCTapLongTapOrDoubleTapGestureTap) {
        if([self playBtnBoxViewTapAtPoint:recognizer.tapPoint]) {
            [self playPress];
        }
    }
}

-(BOOL) playBtnBoxViewTapAtPoint:(CGPoint)point {
    CGRect rectInContentView = [self.contentView convertRect:self.playBtnBoxView.frame fromView:self.playBtnBoxView.superview];
    return CGRectContainsPoint(rectInContentView, point);
}
-(void) playPress {
    [self iteraPlayVoice:self.messageModel];
}


- (UIView *)playBtnBoxView {
    if(!_playBtnBoxView) {
        _playBtnBoxView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 45.0f, 45.0f)];
        _playBtnBoxView.layer.masksToBounds = YES;
        _playBtnBoxView.layer.cornerRadius = _playBtnBoxView.lim_height/2.0f;
        [_playBtnBoxView setBackgroundColor:[UIColor whiteColor]];
    }
    return _playBtnBoxView;
}
- (UIImageView *)playIconImgView {
    if(!_playIconImgView) {
        _playIconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 24.0f, 24.0f)];
    }
    return _playIconImgView;
}

-(UIImage*) getPlayIcon:(QCVoicePlayStatus)status {
    UIImage *img;
    if(status == QCVoicePlayStatusPlaying) {
        img = [self imageName:@"Conversation/Messages/PlayPause"];
        img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }else {
        img = [self imageName:@"Conversation/Messages/PlayIcon"];
        img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    return img;
}

-(QCAudioWaveformView*) audioWaveformView {
    if(!_audioWaveformView) {
        _audioWaveformView = [[QCAudioWaveformView alloc] init];
        [_audioWaveformView setBackgroundColor:[UIColor clearColor]];
    }
    return _audioWaveformView;
}
- (QCAudioWaveformView *)highlightedWaveformView {
    if(!_highlightedWaveformView) {
        _highlightedWaveformView = [[QCAudioWaveformView alloc] init];
        [_highlightedWaveformView setBackgroundColor:[UIColor clearColor]];
    }
    return _highlightedWaveformView;
}

-(UIView*) audioWaveformWrapView {
    if(!_audioWaveformWrapView) {
        _audioWaveformWrapView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 15.0f)];
        [_audioWaveformWrapView setBackgroundColor:[UIColor clearColor]];
    }
    return _audioWaveformWrapView;
}

- (UIView *)maskWaveformView {
    if(!_maskWaveformView) {
        _maskWaveformView = [[UIView alloc] init];
        [_maskWaveformView setBackgroundColor:[UIColor blackColor]];
    }
    return _maskWaveformView;
}


-(void) refresh:(QCMessageModel *)model {
    [super refresh:model];

    QCVoiceContent *voiceContent = (QCVoiceContent*)model.content;
   
    
    self.highlightedWaveformView.waveform = voiceContent.waveform;
    self.audioWaveformView.waveform = voiceContent.waveform;
    
    self.maskWaveformView.lim_height = self.audioWaveformView.lim_height;
    
    self.playIconImgView.image = [self getPlayIcon:self.messageModel.voicePlayStatus];
   
    if(model.voicePlayStatus == QCVoicePlayStatusPlaying || model.voicePlayStatus  == QCVoicePlayStatusPause) {
        [UIView animateWithDuration:0.1 animations:^{
            self.maskWaveformView.lim_width = (model.voicePlayProgress)*self.audioWaveformView.lim_width;
        }];
    }else {
        self.maskWaveformView.lim_width = 0.0f;
    }
    
   
//    [self.audioWaveformView updateProgress:model.voicePlayProgress];
   
//     QCVoiceContent *voiceContent = (QCVoiceContent*)model.content;
//    if(model.isSend) {
//        self.voiceImageView.image = [self imageName:@"SenderVoiceNodePlaying"];
//        self.voiceImageView.animationImages = [self senderVoiceAnimateImgs];
//        self.badgeView.hidden = YES; // 发送的消息没有红点
//    }else {
//        self.voiceImageView.image = [self imageName:@"ReceiverVoiceNodePlaying"];
//        self.voiceImageView.animationImages = [self revVoiceAnimateImgs];
//        if(!model.voiceReaded) {
//             self.badgeView.hidden = NO; // 显示红点
//        }else {
//             self.badgeView.hidden = YES;
//        }
//    }
    NSInteger remainingSecond = voiceContent.second - self.messageModel.voiceCurrentSecond;
    self.durationLabel.text = [NSString
                               stringWithFormat:@"%02ld:%02ld", remainingSecond/60,remainingSecond%60];
    [self.durationLabel sizeToFit];
    
    if(self.messageModel.isSend) {
        [self setSendStyle];
    }else{
        [self setRecvStyle];
    }

}

-(void) setSendStyle {
    self.highlightedWaveformView.tintColor = [UIColor whiteColor];
    self.audioWaveformView.tintColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.5f];
    self.playIconImgView.tintColor = [QCApp shared].config.themeColor;
    [self.playBtnBoxView setBackgroundColor:[UIColor whiteColor]];
    self.durationLabel.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.5f];
}

-(void) setRecvStyle {
    if(self.messageModel.voiceReaded) {
        self.audioWaveformView.tintColor = [UIColor grayColor];
        self.highlightedWaveformView.tintColor = [QCApp shared].config.themeColor;
    }else{
        self.highlightedWaveformView.tintColor = [UIColor grayColor];
        self.audioWaveformView.tintColor = [QCApp shared].config.themeColor;
    }
    self.playIconImgView.tintColor = [UIColor whiteColor];
    [self.playBtnBoxView setBackgroundColor:[QCApp shared].config.themeColor];
    self.durationLabel.textColor = [QCApp shared].config.tipColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.playBtnBoxView.lim_left = 0.0f;
    
    self.playBtnBoxView.lim_centerY_parent = self.messageContentView;
    
    self.playIconImgView.lim_centerY_parent = self.playBtnBoxView;
    self.playIconImgView.lim_centerX_parent = self.playBtnBoxView;
    
    CGFloat durationTop = 2.0f;
    
   CGFloat waveformTop =  self.messageContentView.lim_height/2.0f - (self.audioWaveformView.lim_height + self.durationLabel.lim_height + durationTop)/2.0f;
    
    CGFloat waveformWrapLeft = 10.0f;
    
    self.audioWaveformWrapView.lim_width = self.messageContentView.lim_width - self.playBtnBoxView.lim_right - waveformWrapLeft;
    self.audioWaveformWrapView.lim_left = self.playBtnBoxView.lim_right+ waveformWrapLeft;
    self.audioWaveformWrapView.lim_top = waveformTop;
    
    self.audioWaveformView.frame = self.audioWaveformWrapView.bounds;
    self.highlightedWaveformView.frame = self.audioWaveformWrapView.bounds;

    self.durationLabel.lim_top = self.audioWaveformWrapView.lim_bottom + durationTop;
    self.durationLabel.lim_left = self.audioWaveformWrapView.lim_left;
    
}


// 声音点击
//-(void) onTap {
//    NSLog(@"Voice onTap");
//    [self iteraPlayVoice:self.messageModel];
//
//}



// 停止所有播放中的动画
-(void) stopAllPlayingUI {
    NSArray *voiceMessages = [self.conversationContext getMessagesWithContentType:WK_VOICE];
    if(voiceMessages) {
        for (QCMessageModel *voiceMessage in voiceMessages) {
            if(voiceMessage.voicePlayStatus == QCVoicePlayStatusPlaying) {
                voiceMessage.voicePlayStatus = QCVoicePlayStatusNoPlay;
                [self.conversationContext refreshCell:voiceMessage];
            }
        }
    }
}
// 获取正在播放中的消息model
-(QCMessageModel*) getPlayingMessageModel {
    NSArray *voiceMessages = [self.conversationContext getMessagesWithContentType:WK_VOICE];
    if(voiceMessages) {
        for (QCMessageModel *voiceMessage in voiceMessages) {
            if(voiceMessage.voicePlayStatus == QCVoicePlayStatusPlaying) {
                return voiceMessage;
            }
        }
    }
    return nil;
}

// 获取暂停的消息
-(QCMessageModel*) getPauseMessageModel {
    NSArray *voiceMessages = [self.conversationContext  getMessagesWithContentType:WK_VOICE];
    if(voiceMessages) {
        for (QCMessageModel *voiceMessage in voiceMessages) {
            if(voiceMessage.voicePlayStatus == QCVoicePlayStatusPause) {
                return voiceMessage;
            }
        }
    }
    return nil;
}
// 连播
-(void) iteraPlayVoice:(QCMessageModel*)messageModel {
    if(!messageModel || messageModel.contentType !=WK_VOICE) {
        return;
    }
    [self playOrDownloadPlay:messageModel complete:^{
        if(messageModel.nextMessageModel && messageModel.nextMessageModel.contentType == WK_VOICE && !messageModel.nextMessageModel.voiceReaded) {
            [self iteraPlayVoice:messageModel.nextMessageModel];
        }
    }];
}

-(void) playOrDownloadPlay:(QCMessageModel*)messageModel  complete:(void(^)(void))complete{
    __weak typeof(self) weakSelf = self;
    
    QCMessageModel *playingMessageModel =  [self getPlayingMessageModel];
    QCMessageModel *pauseMessageModel = [self getPauseMessageModel]; // 暂停的消息
    BOOL needPause = false; // 是否暂停
    if(playingMessageModel && playingMessageModel.clientSeq == messageModel.clientSeq) {
        needPause = true;
    }
    if(pauseMessageModel && pauseMessageModel.clientSeq != messageModel.clientSeq) {
        [self resetPlayStatus:pauseMessageModel];
        [[QCSDK shared].mediaManager stopAudioPlay];
        [self.conversationContext refreshCell:pauseMessageModel];
    }
    
    if(messageModel.voicePlayStatus == QCVoicePlayStatusPause) {
        [[QCSDK shared].mediaManager continuePlay];
        messageModel.voicePlayStatus = QCVoicePlayStatusPlaying;
        return;
    }
    
    if(needPause) {
        [[QCSDK shared].mediaManager pauseAudioPlay];
        messageModel.voicePlayStatus = QCVoicePlayStatusPause;
    }else {
        // 停止其他的语音播放
        [[QCSDK shared].mediaManager stopAudioPlay];
        // 停止其他所有播放
        [self stopAllPlayingUI];
    }
   
    // 更新消息为已读
    if(!messageModel.voiceReaded) {
        messageModel.voiceReaded = true;
        [[QCMessageManager shared] updateMessageVoiceReaded:messageModel complete:nil];
    }
    if(!needPause && messageModel.voicePlayStatus != QCVoicePlayStatusPlaying) {
        QCVoiceContent *voiceContent = (QCVoiceContent*)messageModel.content;
        if([[NSFileManager defaultManager] fileExistsAtPath:voiceContent.localPath]){ // 如果存在则播放，不存在则下载
            [self playVoice:messageModel complete:complete];
        }else {
            if([[NSFileManager defaultManager] fileExistsAtPath:voiceContent.thumbPath]){ // 是否存在副本，如果存在则转码成iOS支持的wav，否则下载
                [[QCSDK shared].mediaManager voiceMessageThumbToSource:messageModel.message];
                 [weakSelf playVoice:messageModel complete:complete];
            }else {
                // 下载音频文件
                [[QCSDK shared].mediaManager download:messageModel.message callback:^(QCMediaDownloadState state, CGFloat progress, NSError * _Nullable error) {
                    if(state == QCMediaDownloadStateSuccess) { // 下载成功则播放
                        [[QCSDK shared].mediaManager voiceMessageThumbToSource:messageModel.message];
                         [weakSelf playVoice:messageModel complete:complete];
                    }
                }];
            }
        }
    }
}

-(void) playVoice:(QCMessageModel*)messageModel complete:(void(^)(void))complete{
    messageModel.voicePlayStatus = QCVoicePlayStatusPlaying;
    [self.conversationContext refreshCell:messageModel];
    
    
    __weak typeof(self) weakSelf = self;
    QCVoiceContent *voiceContent = (QCVoiceContent*)messageModel.content;
    [[QCSDK shared].mediaManager playAudio:voiceContent.localPath playerDidFinish:^(AVAudioPlayer *player,BOOL successFlag) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf resetPlayStatus:messageModel];
        [strongSelf.conversationContext refreshCell:messageModel];
        if(complete) {
            complete();
        }
    } progress:^(AVAudioPlayer * _Nonnull player) {
        messageModel.voicePlayProgress = player.currentTime/player.duration;
        messageModel.voiceCurrentSecond = (NSInteger)player.currentTime;
        [weakSelf.conversationContext refreshCell:messageModel];
        
    }];
    
    messageModel.OnFlameFinished = ^{
        [[QCSDK shared].mediaManager stopAudioPlay];
        [weakSelf stopAllPlayingUI];
    };
    
    self.messageModel.startingFlameFlag = false;
    if(!self.messageModel.viewed) {
        [QCSDK.shared.flameManager didViewed:@[self.messageModel.message]];
    }
}

-(void) resetPlayStatus:(QCMessageModel*)messageModel {
    messageModel.voicePlayStatus = QCVoicePlayStatusNoPlay;
    messageModel.voicePlayProgress = 0.0f;
    messageModel.voiceCurrentSecond = 0;
}

-(void) playVoice:(QCMessageModel*)messageModel{
    [self playVoice:messageModel complete:nil];
}

-(NSURL*) getVoiceFullUrl:(NSString*)url{
    return [[QCApp shared] getFileFullUrl:url];
}

-(UIImage*) imageName:(NSString*)name {
    return [QCApp.shared loadImage:name moduleID:@"QCCore"];
//    return [[QCResource shared] resourceForImage:name podName:@"QCCore_images"];
}

@end
