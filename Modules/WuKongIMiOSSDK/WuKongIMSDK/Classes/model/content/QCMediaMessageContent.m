//
//  QCMediaMessageContent.m
//  WuKongIMSDK
//
//  Created by tt on 2020/1/13.
//

#import "QCMediaMessageContent.h"
#import "QCFileUtil.h"
#import "QCSDK.h"
#import "QCMediaUtil.h"

@interface QCMediaMessageContent ()

@property(nonatomic,strong) NSMutableDictionary *extraData;

@end

@implementation QCMediaMessageContent

@synthesize localPath;
@synthesize remoteUrl;
@synthesize message;
@synthesize extension;
@synthesize thumbExtension;
@synthesize thumbPath;


- (void)writeDataToLocalPath {
    // 创建频道目录
      NSString *uid = [QCSDK shared].options.connectInfo.uid;
    NSString *channelDir = [NSString stringWithFormat:@"%@/%@/%@",[QCSDK shared].options.messageFileRootDir,uid,[QCMediaUtil getChannelDir:self.message.channel]];
    [QCFileUtil createDirectoryIfNotExist:channelDir];
}

- (nullable id)getExtra:(nonnull NSString *)key {
   return [self.extraData objectForKey:key];
}

- (void)setExtra:(nonnull NSString *)value key:(nonnull NSString*)key {
    [self.extraData setValue:value forKey:key];
}

- (NSMutableDictionary *)extraData {
    if(!_extraData) {
        _extraData = [[NSMutableDictionary alloc] init];
    }
    return _extraData;
}


- (NSString *)localPath {
    NSString *uid = [QCSDK shared].options.connectInfo.uid;
    return   [NSString stringWithFormat:@"%@/%@/%@",[QCSDK shared].options.messageFileRootDir,uid, [QCMediaUtil getLocalPath:self]];
}

- (NSString *)thumbPath {
    NSString *uid = [QCSDK shared].options.connectInfo.uid;
    return  [NSString stringWithFormat:@"%@/%@/%@",[QCSDK shared].options.messageFileRootDir,uid, [QCMediaUtil getThumbLocalPath:self]];
}



@end
