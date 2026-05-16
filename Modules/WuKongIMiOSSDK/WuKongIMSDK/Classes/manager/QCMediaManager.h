//
//  QCMediaManager.h
//  WuKongIMSDK
//
//  Created by tt on 2020/1/13.
//

#import <Foundation/Foundation.h>
#import "QCMediaProto.h"
#import "QCMessage.h"
#import "QCTaskProto.h"
#import "QCTaskManager.h"
#import <CoreGraphics/CGBase.h>
#import <AVFoundation/AVFoundation.h>
#import "QCMessageFileDownloadTask.h"
NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    QCMediaUploadStateProcessing = 0,
    QCMediaUploadStateSuccess = 1,
    QCMediaUploadStateFail = 2,
} QCMediaUploadState;

typedef enum : NSUInteger {
    QCMediaDownloadStateProcessing = 0,
    QCMediaDownloadStateSuccess = 1,
    QCMediaDownloadStateFail = 2,
} QCMediaDownloadState;

@interface QCFileInfo : NSObject

@property(nonatomic,copy) NSString *fid; // 文件唯一id
@property(nonatomic,copy) NSString *name; // 文件名
@property(nonatomic,assign) long size;  // 文件大小（单位byte）
@property(nonatomic,copy) NSString *url; // 文件路径

@end

/**
 多媒体委托
 */
@protocol QCMediaManagerDelegate <NSObject>


/**
 媒体文件数据更新

 @param media 媒体文件
 */
-(void) mediaManageUpdate:(id<QCMediaProto>)media;


@end


/**
 多媒体上传任务提供者
 */
typedef id<QCTaskProto>_Nonnull(^QCMediaUploadTaskProvider)(QCMessage* message);

/**
 多媒体下载任务提供者
 */
typedef id<QCTaskProto>_Nonnull(^QCMediaDownloadTaskProvider)(QCMessage* message);

// 音频播放完成block
typedef void(^QCAudioPlayerDidFinishBlock)(AVAudioPlayer *player,BOOL successFlag);

// 音频播放进度
typedef void (^QCAudioPlayerDidProgressBlock)(AVAudioPlayer *player);

@interface QCMediaManager : NSObject

+ (QCMediaManager *)shared;

@property(nonatomic,strong) QCTaskManager *taskManager;
/**
 添加媒体委托
 
 @param delegate <#delegate description#>
 */
-(void) addDelegate:(id<QCMediaManagerDelegate>) delegate;


/**
 移除媒体委托
 
 @param delegate <#delegate description#>
 */
-(void)removeDelegate:(id<QCMediaManagerDelegate>) delegate;



/**
 下载任务提供者
 */
@property(nonatomic,copy) QCMediaDownloadTaskProvider downloadTaskProvider;
/**
上传任务提供者
 */
@property(nonatomic,copy) QCMediaUploadTaskProvider uploadTaskProvider;

/**
 上传消息里的多媒体

 @param message 消息
 */
-(void) upload:(QCMessage*) message;


/**
 下载消息的多媒体文件

 @param message <#message description#>
 */
-(QCMessageFileDownloadTask*) download:(QCMessage*)message;


/**
 下载消息的多媒体文件

 @param message 消息对象
 @param callback 下载回调
 */
-(QCMessageFileDownloadTask*) download:(QCMessage*)message callback:(void(^ __nullable)(QCMediaDownloadState state,CGFloat progress,NSError * __nullable error))callback;

///**
// 获取上传进度
//
// @param message 消息
// @return <#return value description#>
// */
//-(CGFloat) getUploadProgress:(QCMessage*)message;
//
//
///**
// 获取下载进度
//
// @param message 消息
// @return <#return value description#>
// */
//-(CGFloat) getDowloadProgress:(QCMessage*)message;



/**
 将音频消息的副本转换为源文件

 @param message <#message description#>
 */
-(void) voiceMessageThumbToSource:(QCMessage*)message;

/**
 *  是否正在播放音频
 *
 */
- (BOOL)isAudioPlaying;

/**
 *  播放音频文件
 *
 *  @param filePath 文件路径
 */
-(void) playAudio:(NSString *)filePath playerDidFinish:(QCAudioPlayerDidFinishBlock)finishBlock progress:(QCAudioPlayerDidProgressBlock)progressBlock;

/**
 *  停止播放音频
 */
- (void)stopAudioPlay;

/**
 暂停播放
 */
-(void) pauseAudioPlay;

/**
  继续播放
 */
-(void) continuePlay;

// 获取所有消息缓存大小
-(long long) messageCacheSize;

-(void) cleanMessageCache;

@end

NS_ASSUME_NONNULL_END
