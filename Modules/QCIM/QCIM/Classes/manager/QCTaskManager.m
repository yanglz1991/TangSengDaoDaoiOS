//
//  QCTaskManager.m
//  QCIM
//
//  Created by tt on 2020/1/15.
//

#import "QCTaskManager.h"

@interface QCTaskManager ()
@property(nonatomic,strong) NSLock *taskLock;
@property(nonatomic,strong) NSMutableDictionary *taskDic;

@end

@implementation QCTaskManager

- (void)add:(id<QCTaskProto>)task {
    if(!task || !task.taskId) {
        return;
    }
    [self.taskLock lock];
    self.taskDic[task.taskId] = task;
    [self.taskLock unlock];
    __weak typeof(task) weakTask = task;
    [task addListener:^{
        if(weakTask.status == QCTaskStatusProgressing) {
            [self callTaskProgressDelegate:weakTask];
        }
        if([self isComplete:weakTask]) {
            [self callTaskCompleteDelegate:weakTask];
            [self remove:weakTask];
        }
        
    } target:self];
    [task resume];
    
}

-(void) callTaskCompleteDelegate:(id<QCTaskProto>) task {
    if(self.delegate && [self.delegate respondsToSelector:@selector(taskComplete:)]) {
        
        if (![NSThread isMainThread]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate taskComplete:task];
            });
        }else {
            [self.delegate taskComplete:task];
        }
    }
}
-(void) callTaskProgressDelegate:(id<QCTaskProto>) task {
    if(self.delegate && [self.delegate respondsToSelector:@selector(taskProgress:)]) {
        
        if (![NSThread isMainThread]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate taskProgress:task];
            });
        }else {
            [self.delegate taskProgress:task];
        }
    }
}

-(BOOL) isComplete:(id<QCTaskProto>) task {
     return task.status !=QCTaskStatusWait && task.status != QCTaskStatusSuspend && task.status != QCTaskStatusProgressing;
}

- (id<QCTaskProto>)get:(NSString *)taskId {
    if(!taskId) {
        return nil;
    }
    [self.taskLock lock];
    id<QCTaskProto> task = self.taskDic[taskId];
    [self.taskLock unlock];
    return task;
}

- (void)remove:(id<QCTaskProto>)task {
    if(!task || !task.taskId) {
        return;
    }
    [self.taskLock lock];
    [self.taskDic removeObjectForKey:task.taskId];
    [self.taskLock unlock];
    [task removeListener:self];
}

-(NSMutableDictionary*) taskDic {
    if(!_taskDic) {
        _taskDic = [[NSMutableDictionary alloc] init];
    }
    return _taskDic;
}

- (NSLock *)taskLock {
    if(!_taskLock) {
        _taskLock = [[NSLock alloc] init];
    }
    return _taskLock;
}

@end
