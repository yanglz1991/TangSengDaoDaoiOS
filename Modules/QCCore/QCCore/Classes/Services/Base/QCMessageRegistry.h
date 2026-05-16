//
//  QCMessageRegistry.h
//  QCCore
//
//  Created by tt on 2019/12/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCMessageRegistry : NSObject

+ (QCMessageRegistry *)shared;


/**
 注册消息

 @param cellClass 消息cell
 @param messageContentClass 消息正文
 */
-(void) registerCellClass:(Class)cellClass forMessageContentClass:(Class)messageContentClass;


/// 注册消息
/// @param cellClass 消息cell
/// @param contentType 消息正文类型
-(void) registerCellClass:(Class)cellClass forContentType:(NSInteger)contentType;


/**
 通过消息正文类型获取消息的cell

 @param contentType 正文类型
 @return <#return value description#>
 */
-(Class) getMessageCell:(NSInteger)contentType;


/**
 通过正文类型获取消息的正文对象class

 @param contentType 正文类型
 @return <#return value description#>
 */
-(Class) getMessageConent:(NSInteger)contentType;

@end

NS_ASSUME_NONNULL_END
