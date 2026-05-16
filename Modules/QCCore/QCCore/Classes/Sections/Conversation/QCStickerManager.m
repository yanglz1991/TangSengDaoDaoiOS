//
//  QCStickerManager.m
//  QCCore
//
//  Created by tt on 2021/9/27.
//

#import "QCStickerManager.h"
#import "QCCore.h"
@interface QCStickerManager ()


@property(nonatomic,assign) BOOL stickerUserCategoryLoadFinished;

/**
 *  用来存储所有添加j过的delegate
 *  NSHashTable 与 NSMutableSet相似，但NSHashTable可以持有元素的弱引用，而且在对象被销毁后能正确地将其移除。
 */
@property (strong, nonatomic) NSHashTable  *delegates;
/**
 *  delegateLock 用于给delegate的操作加锁，防止多线程同时调用
 */
@property (strong, nonatomic) NSLock  *delegateLock;

@end

@implementation QCStickerManager

+ (instancetype)shared{
    static QCStickerManager *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[QCStickerManager alloc] init];
    });
    
    return _shared;
}

-(void) setupIfNeed {
    if(!self.stickerUserCategoryLoadFinished && self.stickerProvider) {
        [self loadUserCategory];
    }else {
        [self callStickerUserCategoryLoadFinished];
    }
}


-(void) loadUserCategory {
    __weak typeof(self) weakSelf = self;
    
    if(self.stickerProvider) {
        [self.stickerProvider requestUserCategory:^(NSArray<QCStickerUserCategoryResp *> * _Nonnull data, NSError * _Nonnull error) {
            if(error) {
                QCLogError(@"用户表情类别加载失败！->%@",error);
                return;
            }
            weakSelf.stickerUserCategoryResps = data;
            weakSelf.stickerUserCategoryLoadFinished = true;
            [weakSelf callStickerUserCategoryLoadFinished];
        }];
    }
}

-(void) addStickerWithCategory:(NSString*)category callback:(void(^)(NSError *error))callback {
    
    if(self.stickerProvider) {
        [[QCNavigationManager shared].topViewController.view showHUD];
        [self.stickerProvider requestAddStickerCategory:category callback:^(NSError * _Nonnull error) {
            [[QCNavigationManager shared].topViewController.view hideHud];
            if(error) {
                [[QCNavigationManager shared].topViewController.view showHUDWithHide:error.domain];
            }
            if(callback) {
                callback(error);
            }
        }];
    }
}

-(void) removeStickerWithCategory:(NSString*)category callback:(void(^)(NSError *error))callback {
   
    if(self.stickerProvider) {
        [[QCNavigationManager shared].topViewController.view showHUD];
        [self.stickerProvider requestRemoveStickerCategory:category callback:^(NSError * _Nonnull error) {
            [[QCNavigationManager shared].topViewController.view hideHud];
            if(error) {
                [[QCNavigationManager shared].topViewController.view showHUDWithHide:error.domain];
            }
            if(callback) {
                callback(error);
            }
        }];
    }
}


-(void) callStickerUserCategoryLoadFinished {
    [self.delegateLock lock];
    NSHashTable *copyDelegates =  [self.delegates copy];
    [self.delegateLock unlock];
    for (id delegate in copyDelegates) {//遍历delegates ，call delegate
        if(!delegate) {
            continue;
        }
        if ([delegate respondsToSelector:@selector(stickerUserCategoryLoadFinished:)]) {
            if (![NSThread isMainThread]) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [delegate stickerUserCategoryLoadFinished:self];
                });
            }else {
                [delegate stickerUserCategoryLoadFinished:self];
            }
        }
    }
}


- (NSLock *)delegateLock {
    if (_delegateLock == nil) {
        _delegateLock = [[NSLock alloc] init];
    }
    return _delegateLock;
}

-(NSHashTable*) delegates {
    if (_delegates == nil) {
        _delegates = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return _delegates;
}



-(void) addDelegate:(id<QCStickerManagerDelegate>) delegate{
    [self.delegateLock lock];//防止多线程同时调用
    [self.delegates addObject:delegate];
    [self.delegateLock unlock];
}
- (void)removeDelegate:(id<QCStickerManagerDelegate>) delegate {
    [self.delegateLock lock];//防止多线程同时调用
    [self.delegates removeObject:delegate];
    [self.delegateLock unlock];
}

@end


@implementation QCStickerUserCategoryResp


+ (QCModel *)fromMap:(NSDictionary *)dictory type:(ModelMapType)type {
    QCStickerUserCategoryResp *resp = [QCStickerUserCategoryResp new];
    resp.category = dictory[@"category"];
    resp.cover = dictory[@"cover"];
    resp.desc = dictory[@"desc"];
    resp.title = dictory[@"title"];
    return resp;
}

@end
