//
//  QCChannelRequestQueue.m
//  QCIM
//
//  Created by tt on 2021/4/22.
//

#import "QCChannelRequestQueue.h"
#import "QCSDK.h"

typedef enum : NSUInteger {
    Wait,
    Success,
    Error,
    Cancel,
} QCRequestStatus;

@interface QCChannelRequest : NSObject

@property(nonatomic,strong) QCChannel *channel;
@property(nonatomic,strong) QCTaskOperator *operator;
@property(nonatomic,assign) QCRequestStatus status;

-(void) cancel;

@end

@implementation QCChannelRequest

-(void) cancel {
    self.operator.cancel();
    self.status = Cancel;
}

@end

@interface QCChannelRequestQueue ()

@property(nonatomic,strong) NSMutableArray<QCChannelRequest*> *requests;

@property(nonatomic,strong) NSMutableDictionary<NSString*,QCChannelRequest*> *requestDict;

@property(nonatomic,strong) NSRecursiveLock *lock; // 递归锁可被同一线程多次获取


@end

@implementation QCChannelRequestQueue


static QCChannelRequestQueue *_instance;
+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
+ (QCChannelRequestQueue *)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

-(NSString*) getChannelKey:(QCChannel*)channel {
    return [NSString stringWithFormat:@"%@-%d",channel.channelId,channel.channelType];
}

-(void) addRequest:(QCChannel*)channel complete:(void(^)(NSError *error,bool notifyBefore))complete{
    NSString *key = [self getChannelKey:channel];
    
    [self.lock lock];
    QCChannelRequest *request = [self.requestDict objectForKey:key];
    if(request) {
        NSInteger index = [self.requests indexOfObject:request];
        if(index != 0) {
            [self.requests removeObjectAtIndex:index];
            [self.requests insertObject:request atIndex:0];
        }
    }else {
        request = [self createRequest:channel complete:complete];
        [self.requestDict setObject:request forKey:key];
        [self.requests insertObject:request atIndex:0];
    }
    
    if(self.requests.count>[QCSDK shared].options.channelRequestMaxLimit) {
        QCChannelRequest *request = [self.requests lastObject];
        if(request) {
            NSString *key = [self getChannelKey:request.channel];
            [self.requests removeObject:request];
            [self.requestDict removeObjectForKey:[self getChannelKey:request.channel]];
            [request cancel];
            
            NSLog(@"移除频道请求！->%@",key);
            
        }
    }
    [self.lock unlock];
}

-(QCChannelRequest *) createRequest:(QCChannel*)channel complete:(void(^)(NSError *error,bool notifyBefore))complete{
    QCChannelRequest *request = [QCChannelRequest new];
    QCTaskOperator *operator = [QCSDK shared].channelInfoUpdate(channel, ^(NSError * _Nullable error,bool notifyBefore) {
        if(notifyBefore) {
            if(complete) {
                complete(nil,notifyBefore);
            }
            return;
        }
        if(error) {
            request.status = Error;
        }else {
            request.status = Success;
        }
        if(complete) {
            complete(error,notifyBefore);
        }
    });
    request.channel =channel;
    request.operator = operator;
    return request;
}

-(void) cancelRequest:(QCChannel*)channel {
    [self.lock lock];
    NSString *key = [self getChannelKey:channel];
    QCChannelRequest *request = [self.requestDict objectForKey:key];
    if(request) {
        [self.requests removeObject:request];
        [self.requestDict removeObjectForKey:[self getChannelKey:request.channel]];
        [request cancel];
    }
    [self.lock unlock];
}


- (NSMutableArray<QCChannelRequest *> *)requests {
    if(!_requests) {
        _requests = [NSMutableArray array];
    }
    return _requests;
}

- (NSMutableDictionary *)requestDict {
    if(!_requestDict) {
        _requestDict = [NSMutableDictionary dictionary];
    }
    return _requestDict;
}

- (NSRecursiveLock *)lock {
    if(!_lock) {
        _lock = [[NSRecursiveLock alloc] init];
    }
    return _lock;
}


@end
