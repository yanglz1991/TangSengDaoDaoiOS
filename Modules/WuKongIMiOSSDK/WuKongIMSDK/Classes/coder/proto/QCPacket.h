//
//  QCPacket.h
//  WuKongIMSDK
//
//  Created by tt on 2019/11/25.
//

#import <Foundation/Foundation.h>
#import "QCHeader.h"
typedef NSString* (^Encode)(void);

@interface QCPacket : NSObject

@property(nonatomic,strong) QCHeader *header;


@end
