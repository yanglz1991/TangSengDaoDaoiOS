//
//  QCFMDatabaseQueue.m
//  WuKongIMSDK
//
//  Created by tt on 2021/8/26.
//

#import "QCFMDatabaseQueue.h"
#import "QCSDK.h"
@interface QCFMDatabaseQueue ()

@property(nonatomic,strong) FMDatabaseQueue *queue;

@end

@implementation QCFMDatabaseQueue


+(QCFMDatabaseQueue*) databaseQueue:(FMDatabaseQueue*)queue {
    QCFMDatabaseQueue *fMDatabaseQueue = [QCFMDatabaseQueue new];
    fMDatabaseQueue.queue = queue;
    return fMDatabaseQueue;
}


- (void)inDatabase:(void (NS_NOESCAPE^)(FMDatabase * _Nonnull db))block {
    
    if([QCSDK shared].options.traceDBLog) {
        NSArray *syms = [NSThread  callStackSymbols];
        if ([syms count] > 1) {
            NSLog(@"<%@ %p> %@ - caller: %@ ", [self class], self, NSStringFromSelector(_cmd),[syms objectAtIndex:1]);
            if([syms count]>2) {
                NSLog(@"%@ - caller: %@ ", NSStringFromSelector(_cmd),[syms objectAtIndex:2]);
            }
        } else {
             NSLog(@"<%@ %p> %@", [self class], self, NSStringFromSelector(_cmd));
        }
    }
   
    [self.queue inDatabase:^(FMDatabase *db){
        block(db);
    }];
}

- (void)inTransaction:(__attribute__((noescape)) void (^)(FMDatabase *db, BOOL *rollback))block {

    if([QCSDK shared].options.traceDBLog) {
        NSArray *syms = [NSThread  callStackSymbols];
        if ([syms count] > 1) {
            NSLog(@"<%@ %p> %@ - caller: %@ ", [self class], self, NSStringFromSelector(_cmd),[syms objectAtIndex:1]);
        } else {
             NSLog(@"<%@ %p> %@", [self class], self, NSStringFromSelector(_cmd));
        }
    }
   
    [self.queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        block(db,rollback);
    }];
}


-(void) close {
    [self.queue close];
}


@end
