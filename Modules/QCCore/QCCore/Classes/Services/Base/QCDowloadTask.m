//
//  QCURLSessionDataTask.m
//  QCCore
//
//  Created by tt on 2022/5/13.
//

#import "QCDowloadTask.h"
#import "QCCore.h"
@interface QCDowloadTask ()



@property(nonatomic,strong) NSURLSessionDownloadTask *task;

@end

@implementation QCDowloadTask
-(instancetype) initWithURL:(NSString*)url storePath:(NSString*)storePath{
    QCDowloadTask *task = [QCDowloadTask new];
    task.taskId = url;
    task.url = url;
    task.storePath = storePath;
    [task initTask];
    return task;
}

-(void) initTask {
    NSString *storeDir = [self.storePath stringByDeletingLastPathComponent];
    [QCFileUtil createDirectoryIfNotExist:storeDir];
    
    if([QCFileUtil fileIsExistOfPath:self.storePath]) {
        self.status = QCTaskStatusSuccess;
        [self update];
        return;
    }
    
    NSString *tempDir= NSTemporaryDirectory();
    NSString *tmpFile = [tempDir stringByAppendingPathComponent:[self uuidString]];
    
    __weak typeof(self) weakSelf = self;
  self.task =   [[QCAPIClient sharedClient] createDownloadTask:self.url storePath:tmpFile progress:^(NSProgress * _Nullable downloadProgress) {
        weakSelf.progress = downloadProgress.fractionCompleted;
        weakSelf.status = QCTaskStatusProgressing;
        [weakSelf update];
    } completeCallback:^(NSError * _Nullable error) {
        if(error) {
            weakSelf.status = QCTaskStatusError;
            weakSelf.error = error;
        }else {
            NSError *copyError;
            [[NSFileManager defaultManager] moveItemAtPath:tmpFile toPath:weakSelf.storePath error:&copyError];
            
            
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

- (NSString *)uuidString{
    
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    
    //去除UUID ”-“
    NSString *UUID = [[uuid lowercaseString] stringByReplacingOccurrencesOfString:@"-" withString:@""];

    return UUID;
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

@end
