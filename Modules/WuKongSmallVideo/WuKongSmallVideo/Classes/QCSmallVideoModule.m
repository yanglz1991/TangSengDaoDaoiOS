//
//  QCSmallVideoModule.m
//  WuKongSmallVideo
//
//  Created by tt on 2020/4/29.
//

#import "QCSmallVideoModule.h"
#import "QCSmallVideoCell.h"
#import "QCSmallVideoContent.h"
#import "QCPanelCameraFuncItem.h"
#import "QCMergeForwardDetailVideoCell.h"
@QCModule(QCSmallVideoModule)
@implementation QCSmallVideoModule

+(NSString*) gmoduleId {
    return @"WuKongSmallVideo";
}

-(NSString*) moduleId {
    return [QCSmallVideoModule gmoduleId];
}

- (void)moduleInit:(QCModuleContext*)context{
    NSLog(@"【WuKongSmallVideo】模块初始化！");
    // 注册小视频消息
    [[QCApp shared] registerCellClass:QCSmallVideoCell.class forMessageContntClass:QCSmallVideoContent.class];
    
    [[QCApp shared] addMessageAllowForward:WK_SMALLVIDEO];
    
    // camera
    [self setMethod:QCPOINT_CATEGORY_PANELFUNCITEM_CAMERA handler:^id _Nullable(id  _Nonnull param) {
        QCPanelDefaultFuncItem *item = [[QCPanelCameraFuncItem alloc] init];
        item.sort = 4900;
        return item;
    } category:QCPOINT_CATEGORY_PANELFUNCITEM];
    
    // 发送视频消息
    [self setMethod:QCPOINT_SEND_VIDEO handler:^id _Nullable(id  _Nonnull param) {
        id<QCConversationContext> context = param[@"context"];
        NSData *coverData = param[@"cover_data"];
        NSData *videoData = param[@"video_data"];
        NSInteger second = param[@"second"] ?[ param[@"second"] integerValue]:0;
        if(!context || !coverData || !videoData) {
            return nil;
        }
        [context sendMessage: [QCSmallVideoContent smallVideoContent:videoData coverData:coverData second:second]];
        return nil;
    }];
    
    [[QCApp shared].endpointManager registerMergeForwardItem:WK_SMALLVIDEO cls:QCMergeForwardDetailVideoModel.class];
}

-(void) sendVideoMessage:(NSURL*)videoURL context:(id<QCConversationContext>)context {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    if(!asset) {
        return;
    }
    long long second = asset.duration.value/asset.duration.timescale;
    UIImage *coverImg =  [self getVideoPreViewImage:asset];
   
    [context sendMessage: [QCSmallVideoContent smallVideoContent:[NSData dataWithContentsOfURL:videoURL] coverData: UIImageJPEGRepresentation(coverImg, 0.8) second:second]];
}
//full 是否是原图
-(void) sendImageMessage:(UIImage*)image full:(BOOL)full context:(id<QCConversationContext>)context {
    QCImageContent *imageMessageContent = [QCImageContent initWithImage:image];
    [context sendMessage:imageMessageContent];
    
}

-(UIImage*) imageName:(NSString*)name {
    return [[QCApp shared] loadImage:name moduleID:[QCSmallVideoModule gmoduleId]];
}

// 获取视频第一帧
- (UIImage*) getVideoPreViewImage:(AVURLAsset *)asset
{
    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    assetGen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return videoImage;
}

@end
