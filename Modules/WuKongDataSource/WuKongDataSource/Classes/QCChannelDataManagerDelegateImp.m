//
//  QCChannelDataManagerDelegateImp.m
//  WuKongDataSource
//
//  Created by tt on 2022/12/2.
//

#import "QCChannelDataManagerDelegateImp.h"
#import <WuKongBase/WuKongBase.h>
#import "QCGroupManagerDelegateImp.h"
#import "QCDataSourceModel.h"
@implementation QCChannelDataManagerDelegateImp

- (void)channelDataManager:(QCChannelDataManager *)manager members:(QCChannel *)channel keyword:(NSString *)keyword page:(NSInteger)page limit:(NSInteger)limit complete:(void (^)(NSError * _Nullable, NSArray<QCChannelMember *> * __nullable))complete {
   
}

@end
