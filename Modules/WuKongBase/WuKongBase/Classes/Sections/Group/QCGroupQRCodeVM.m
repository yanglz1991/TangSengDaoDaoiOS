//
//  QCGroupQRCodeVM.m
//  WuKongBase
//
//  Created by tt on 2020/4/3.
//

#import "QCGroupQRCodeVM.h"
#import "WuKongBase.h"

@implementation QCGroupQRCodeInfoModel

+ (QCModel *)fromMap:(NSDictionary *)dictory type:(ModelMapType)type {
    QCGroupQRCodeInfoModel *model = [QCGroupQRCodeInfoModel new];
    model.day = [dictory[@"day"] integerValue];
    model.expire = dictory[@"expire"];
    model.qrcode = dictory[@"qrcode"];
    return model;
}

@end

@interface QCGroupQRCodeVM ()

@property(nonatomic,strong) QCChannel *channel;
@end

@implementation QCGroupQRCodeVM

-(instancetype) initWithChannel:(QCChannel*)channel {
    if(self = [super init]) {
        self.channel = channel;
    }
    return self;
}

-(AnyPromise*) requestGetQRCodeInfo {
  return  [[QCAPIClient sharedClient] GET:[NSString stringWithFormat:@"groups/%@/qrcode",self.channel.channelId] parameters:nil model:QCGroupQRCodeInfoModel.class];
}

@end
