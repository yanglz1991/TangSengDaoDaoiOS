//
//  QCBaseTask.m
//  QCIM
//
//  Created by tt on 2020/1/16.
//

#import "QCBaseTask.h"

@interface QCBaseTask ()

@property(nonatomic,strong) NSMutableDictionary<NSString*,QCTaskListener> *listenerDic;


@end

@implementation QCBaseTask

@synthesize listeners;

@synthesize status;

@synthesize taskId;

- (void)addListener:(nonnull QCTaskListener)listener target:(id) target {
    NSString *key  = [NSString stringWithFormat:@"%@%@",NSStringFromClass([target class]),self.taskId];
    self.listenerDic[key] = listener;
}

- (void)removeListener:(id)target {
    NSString *key  = [NSString stringWithFormat:@"%@%@",NSStringFromClass([target class]),self.taskId];
    [self.listenerDic removeObjectForKey:key];
}
- (void)cancel {
    
}

- (void)resume {
    
}

- (void)suspend {
    
}

- (NSArray<QCTaskListener> *)listeners {
    return self.listenerDic.allValues;
}

-(void) update {
    if(self.listeners) {
        for (QCTaskListener listener in self.listeners) {
            listener();
        }
    }
}

- (NSMutableDictionary *)listenerDic {
    if(!_listenerDic) {
        _listenerDic = [NSMutableDictionary dictionary];
    }
    return _listenerDic;
}

@end
