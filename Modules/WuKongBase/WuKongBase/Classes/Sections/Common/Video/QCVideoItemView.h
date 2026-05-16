//
//  YBIBVideoView.h
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2019/7/11.
//  Copyright © 2019 杨波. All rights reserved.
//

#import "QCVideoActionBar.h"
#import "QCVideoTopBar.h"

NS_ASSUME_NONNULL_BEGIN

@class QCVideoItemView;

@protocol QCVideoItemViewDelegate <NSObject>
@required

- (BOOL)yb_isFreezingForVideoView:(QCVideoItemView *)view;

- (void)yb_preparePlayForVideoView:(QCVideoItemView *)view;

- (void)yb_startPlayForVideoView:(QCVideoItemView *)view;

- (void)yb_finishPlayForVideoView:(QCVideoItemView *)view;

- (void)yb_didPlayToEndTimeForVideoView:(QCVideoItemView *)view;

- (void)yb_playFailedForVideoView:(QCVideoItemView *)view;

- (void)yb_respondsToTapGestureForVideoView:(QCVideoItemView *)view;

- (void)yb_cancelledForVideoView:(QCVideoItemView *)view;

- (CGSize)yb_containerSizeForVideoView:(QCVideoItemView *)view;

- (void)yb_autoPlayCountChanged:(NSUInteger)count;

@end

@interface QCVideoItemView : UIView

@property (nonatomic, strong) UIImageView *thumbImageView;

@property (nonatomic, weak) id<QCVideoItemViewDelegate> delegate;

- (void)updateLayoutWithExpectOrientation:(UIDeviceOrientation)orientation containerSize:(CGSize)containerSize;

@property (nonatomic, strong, nullable) AVAsset *asset;

@property (nonatomic, assign, readonly, getter=isPlaying) BOOL playing;

@property (nonatomic, assign, readonly, getter=isPlayFailed) BOOL playFailed;

@property (nonatomic, assign, readonly, getter=isPreparingPlay) BOOL preparingPlay;

@property (nonatomic, strong, readonly) UITapGestureRecognizer *tapGesture;

- (void)reset;

- (void)hideToolBar:(BOOL)hide;

- (void)hidePlayButton;

- (void)preparPlay;

@property (nonatomic, assign) BOOL needAutoPlay;

@property (nonatomic, assign) NSUInteger autoPlayCount;

@property (nonatomic, strong, readonly) QCVideoTopBar *topBar;
@property (nonatomic, strong, readonly) QCVideoActionBar *actionBar;


@end

NS_ASSUME_NONNULL_END
