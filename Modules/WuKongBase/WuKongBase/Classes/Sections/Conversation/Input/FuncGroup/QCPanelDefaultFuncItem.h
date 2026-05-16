//
//  QCPanelDefaultFuncItem.h
//  WuKongBase
//
//  Created by tt on 2020/2/23.
//

#import <Foundation/Foundation.h>
#import "QCPanelFuncItemProto.h"
#import "QCFuncGroupEditItemModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCPanelDefaultFuncItem : NSObject<QCPanelFuncItemProto>

@property(nonatomic,weak) QCConversationInputPanel *inputPanel;

@property(nonatomic,assign) NSInteger sort; // 排序

@property(nonatomic,assign) BOOL disable; // 是否禁用

@property(nonatomic,assign) QCFuncGroupEditItemType type;

@property(nonatomic,assign) QCChannelType channelType; // 所属频道类型

-(NSString*) sid; // 唯一ID

-(UIImage*) itemIcon;

-(NSString*) panelID;

-(void) onPressed:(UIButton*)btn;

-(UIImage*) getImageNameForBase:(NSString*)name;

-(NSString*) title;





@end

@interface QCPanelEmojiFuncItem : QCPanelDefaultFuncItem

@end

@interface QCPanelMentionFuncItem : QCPanelDefaultFuncItem

@end

@interface QCPanelVoiceFuncItem : QCPanelDefaultFuncItem

@end

@interface QCPanelImageFuncItem : QCPanelDefaultFuncItem

@end

@interface QCPanelMoreFuncItem : QCPanelDefaultFuncItem

@end

@interface QCPanelCardFuncItem : QCPanelDefaultFuncItem

@end



NS_ASSUME_NONNULL_END
