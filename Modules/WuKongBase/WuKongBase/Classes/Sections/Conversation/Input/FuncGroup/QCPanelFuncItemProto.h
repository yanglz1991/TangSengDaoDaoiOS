//
//  QCPanelFuncItem.h
//  WuKongBase
//
//  Created by tt on 2020/2/23.
//

#import <Foundation/Foundation.h>
#import "QCConversationInputPanel.h"
#import "QCFuncItemButton.h"
NS_ASSUME_NONNULL_BEGIN

@protocol QCPanelFuncItemProto <NSObject>

-(NSString*) sid; // 唯一ID
/**
 item按钮

 @return <#return value description#>
 */
-(QCFuncItemButton*) itemButton:(QCConversationInputPanel*)inputPanel;

// 是否支持
-(BOOL) support:(id<QCConversationContext>)context;

-(NSString*) title;

-(UIImage*) itemIcon;

-(BOOL) allowEdit; // 是否允许编辑

-(NSInteger) sort;

-(BOOL) disable; // 是否禁用

-(QCChannelType) channelType; // 所属频道类型

@end


NS_ASSUME_NONNULL_END
