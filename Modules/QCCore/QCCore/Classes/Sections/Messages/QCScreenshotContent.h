//
//  QCScreenshotContent.h
//  QCCore
//  截屏通知
//  Created by tt on 2020/10/16.
//

#import <QCIM/QCIM.h>
#import "QCConstant.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCScreenshotContent : QCMessageContent

@property(nonatomic,copy) NSString *tip;

@end

NS_ASSUME_NONNULL_END
