//
//  QCMessageRegistry.m
//  WuKongBase
//
//  Created by tt on 2019/12/28.
//

#import "QCMessageRegistry.h"
#import <WuKongIMSDK/WuKongIMSDK.h>
#import "QCUnkownMessageCell.h"
#import "QCSystemMessageCell.h"
@interface QCMessageRegistry ()
@property(nonatomic,strong) NSMutableDictionary *messageCellDict;
@property(nonatomic,strong) NSLock *messageCellDictLock;
@end

@implementation QCMessageRegistry

static QCMessageRegistry *_instance;


+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
+ (QCMessageRegistry *)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        
    });
    return _instance;
}

-(NSMutableDictionary*) messageCellDict {
    if (!_messageCellDict) {
        _messageCellDict = [NSMutableDictionary new];
    }
    return _messageCellDict;
}

-(NSLock*) messageCellDictLock {
    if(!_messageCellDictLock) {
        _messageCellDictLock = [[NSLock alloc] init];
    }
    return _messageCellDictLock;
}


-(void) registerCellClass:(Class)cellClass forMessageContentClass:(Class)messageContentClass {
    [[QCSDK shared] registerMessageContent:messageContentClass];
    NSNumber *contentType = [messageContentClass contentType];
    [self registerCellClass:cellClass forContentType:contentType.integerValue];
}


-(void) registerCellClass:(Class)cellClass forContentType:(NSInteger)contentType {
    [self.messageCellDictLock lock];
    [self.messageCellDict setObject:cellClass forKey:[NSString stringWithFormat:@"%li",(long)contentType]];
    [self.messageCellDictLock unlock];
}



-(Class) getMessageCell:(NSInteger)contentType {
    [self.messageCellDictLock lock];
    Class  clas = [self.messageCellDict objectForKey:[NSString stringWithFormat:@"%li",(long)contentType]];
    [self.messageCellDictLock unlock];
    if(!clas) {
        if([[QCSDK shared] isSystemMessage:contentType]) {
            clas = [QCSystemMessageCell class];
        }else {
            clas = [QCUnkownMessageCell class];
        }
        
    }
    return clas;
}

-(Class) getMessageConent:(NSInteger)contentType {
    return [[QCSDK shared] getMessageContent:contentType];
}
@end
