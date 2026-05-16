//
//  QCHeader.m
//  WuKongIMSDK
//
//  Created by tt on 2019/11/25.
//

#import "QCHeader.h"

@implementation QCHeader

- (NSString *)description{
    
    return [NSString stringWithFormat:@"HEADER remainLength:%u packetType:%hhu showUnread:%u noPersist:%u syncOnce:%u",self.remainLength,self.packetType,self.showUnread,self.noPersist,self.syncOnce];
}

@end
