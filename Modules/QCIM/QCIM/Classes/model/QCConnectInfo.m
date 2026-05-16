//
//  QCConnectInfo.m
//  QCIM
//
//  Created by tt on 2020/2/7.
//

#import "QCConnectInfo.h"

@implementation QCConnectInfo

+(instancetype) initWithUID:(NSString*)uid token:(NSString*)token name:(NSString*)name avatar:(NSString*)avatar {
    QCConnectInfo *connectInfo = [QCConnectInfo new];
    connectInfo.uid = uid;
    connectInfo.name = name;
    connectInfo.token = token;
    connectInfo.avatar = avatar;
    return connectInfo;
}
@end
