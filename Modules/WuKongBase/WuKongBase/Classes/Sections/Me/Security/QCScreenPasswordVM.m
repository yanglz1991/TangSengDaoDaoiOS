//
//  QCScreenPasswordVM.m
//  WuKongBase
//
//  Created by tt on 2021/8/16.
//

#import "QCScreenPasswordVM.h"

@implementation QCScreenPasswordVM

-(AnyPromise*) requestCloseLock {
    return  [[QCAPIClient sharedClient] DELETE:@"user/lockscreenpwd" parameters:nil];
}

@end
