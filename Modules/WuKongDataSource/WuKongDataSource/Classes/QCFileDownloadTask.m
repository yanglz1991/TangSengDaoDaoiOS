//
//  QCFileDownloadTask.m
//  WuKongDataSource
//
//  Created by tt on 2020/1/16.
//

#import "QCFileDownloadTask.h"
#import <WuKongIMSDK/QCFileUtil.h>
#import <GZIP/GZIP.h>
@interface QCFileDownloadTask ()
@property(nonatomic,strong) NSURLSessionDownloadTask *task;
@end

@implementation QCFileDownloadTask

- (instancetype)initWithMessage:(QCMessage *)message {
    self = [super initWithMessage:message];
    if(self) {
        [self initTask];
    }
    return self;
}

-(void) initTask {
     id<QCMediaProto> media = [self getMessageMedia:self.message];
    if(!media) {
        QCLogDebug(@"不是多媒体消息！[QCFileDownloadTask]");
        self.status = QCTaskStatusError;
        self.error = [NSError errorWithDomain:@"不是多媒体消息！" code:101 userInfo:nil];
        [self update];
        return;
    }
    if(!media.remoteUrl) {
        QCLogWarn(@"remoteUrl为空，没啥东西下载的！😢");
        self.status = QCTaskStatusError;
        self.error = [NSError errorWithDomain:@"remoteUrl为空，没啥东西下载的！" code:102 userInfo:nil];
        [self update];
        return;
    }
    NSString *realLocalPath = media.thumbPath;
    if(self.message.contentType == WK_EMOJI_STICKER ||  self.message.contentType == WK_LOTTIE_STICKER) {
        realLocalPath = media.localPath;
    } if( self.message.contentType == WK_SMALLVIDEO || self.message.contentType == WK_FILE) {
        realLocalPath = media.localPath;
    }
    if([QCFileUtil fileIsExistOfPath:realLocalPath]) {
        self.status = QCTaskStatusSuccess;
        [self update];
        return;
    }
    
    NSString *downloadURL = media.remoteUrl;
    if(![downloadURL hasPrefix:@"http"]) {
        downloadURL = [[NSURL URLWithString:media.remoteUrl relativeToURL:[NSURL URLWithString:[QCApp shared].config.fileBaseUrl]] absoluteString];
    }
    NSString *storePath = [NSString stringWithFormat:@"%@_tmp",media.thumbPath];
    if(self.message.contentType == WK_SMALLVIDEO) { // 小视频直接下载视频文件。
        storePath = [NSString stringWithFormat:@"%@_tmp",media.localPath];
    }
    __weak typeof(self) weakSelf = self;
    NSString *channelDir = [storePath stringByDeletingLastPathComponent];
    [QCFileUtil createDirectoryIfNotExist:channelDir];
    self.task = [[QCAPIClient sharedClient] createDownloadTask:[[self getVoiceFullUrl:media.remoteUrl] absoluteString] storePath:storePath progress:^(NSProgress *  downloadProgress) {
        weakSelf.progress = downloadProgress.fractionCompleted;
        weakSelf.status = QCTaskStatusProgressing;
        [weakSelf update];
    } completeCallback:^(NSError * _Nullable error) {
        if(error) {
            weakSelf.status = QCTaskStatusError;
            weakSelf.error = error;
            QCLogError(@"download fail -> %@",error);
        }else {
            NSError *copyError;
            [[NSFileManager defaultManager] moveItemAtPath:storePath toPath:realLocalPath error:&copyError];
        
            if(copyError) {
                QCLogError(@"复制文件失败！%@",copyError);
                weakSelf.status = QCTaskStatusError;
                weakSelf.error = error;
            }else {
                weakSelf.status = QCTaskStatusSuccess;
                weakSelf.error = nil;
            }
           
        }
        [weakSelf update];
    }];
}

-(NSURL*) getVoiceFullUrl:(NSString*)url{
    return [[QCApp shared] getFileFullUrl:url];
}

-(void) resume {
    [self.task resume];
}

-(void) cancel {
     [self.task cancel];
}

- (void)suspend {
   [self.task suspend];
}

-(id<QCMediaProto>) getMessageMedia:(QCMessage*)message {
    
    if([message.content conformsToProtocol:@protocol(QCMediaProto)] ) {
        return (id<QCMediaProto>)message.content;
    }
    return nil;
}

@end
