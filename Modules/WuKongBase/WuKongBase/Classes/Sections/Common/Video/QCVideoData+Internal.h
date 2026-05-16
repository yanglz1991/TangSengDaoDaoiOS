//
//  YBIBVideoData+Internal.h
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2019/7/11.
//  Copyright © 2019 杨波. All rights reserved.
//

#import "QCVideoData.h"

NS_ASSUME_NONNULL_BEGIN

@class QCVideoData;

@protocol QCVideoDataDelegate <NSObject>
@required

- (void)yb_startLoadingAVAssetFromPHAssetForData:(QCVideoData *)data;

- (void)yb_finishLoadingAVAssetFromPHAssetForData:(QCVideoData *)data;

- (void)yb_startLoadingFirstFrameForData:(QCVideoData *)data;

- (void)yb_finishLoadingFirstFrameForData:(QCVideoData *)data;

- (void)yb_videoData:(QCVideoData *)data downloadingWithProgress:(CGFloat)progress;

- (void)yb_finishDownloadingForData:(QCVideoData *)data;

- (void)yb_videoData:(QCVideoData *)data readyForThumbImage:(UIImage *)image;

- (void)yb_videoData:(QCVideoData *)data readyForAVAsset:(AVAsset *)asset;

- (void)yb_videoIsInvalidForData:(QCVideoData *)data;

@end

@interface QCVideoData ()

@property (nonatomic, assign, getter=isLoadingAVAssetFromPHAsset) BOOL loadingAVAssetFromPHAsset;

@property (nonatomic, assign, getter=isLoadingFirstFrame) BOOL loadingFirstFrame;

@property (nonatomic, assign, getter=isDownloading) BOOL downloading;

@property (nonatomic, weak) id<QCVideoDataDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
