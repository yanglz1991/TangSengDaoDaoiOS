//
//  QCModelConvert.h
//  QCCore
//
//  Created by tt on 2020/1/24.
//

#import <Foundation/Foundation.h>
#import "QCContactsSelectCell.h"
#import "QCCore.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCModelConvert : NSObject

+(QCContactsSelect*) toContactsSelect:(QCChannelMember*)channelMember;
@end

NS_ASSUME_NONNULL_END
