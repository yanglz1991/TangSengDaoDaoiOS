//
//  QCFuncGroupEditItemModel.h
//  QCCore
//
//  Created by tt on 2022/5/6.
//

#import <Foundation/Foundation.h>
#import "QCPanelFuncItemProto.h"
NS_ASSUME_NONNULL_BEGIN

typedef enum : NSInteger {
    QCFuncGroupEditItemTypeFavorite, // 个人收藏
    QCFuncGroupEditItemTypeMore, // 更多app
} QCFuncGroupEditItemType;


@interface QCFuncGroupEditItemModel : NSObject

@property(nonatomic,copy) NSString *sid;
@property(nonatomic,strong) UIImage *itemIcon;
@property(nonatomic,copy) NSString *title;
@property(nonatomic,assign) BOOL allowEdit;
@property(nonatomic,assign) NSInteger sort;
@property(nonatomic,assign) BOOL disable;
@property(nonatomic,assign) QCFuncGroupEditItemType type; // 区域 0. 个人收藏 1.更多app
@property(nonatomic,assign) QCChannelType channelType;

-(instancetype) initWithFuncItem:(id<QCPanelFuncItemProto>)funcItem;

@end

NS_ASSUME_NONNULL_END
