//
//  QCMoreItemClickEvent.h
//  WuKongBase
//
//  Created by tt on 2020/1/12.
//

#import <Foundation/Foundation.h>
#import "QCPanel.h"
#import "QCConversationContext.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCMoreItemClickEvent : NSObject

+ (QCMoreItemClickEvent *)shared;
/**
  图片
 */
-(void) onPhotoItemPressed:(id<QCConversationContext>)context;


/**
 拍照
 */
-(void) onCameraIPressed:(id<QCConversationContext>)context;

@end

NS_ASSUME_NONNULL_END
