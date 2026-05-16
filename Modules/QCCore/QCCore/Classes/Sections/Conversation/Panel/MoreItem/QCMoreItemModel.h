//
//  QCMoreItemModel.h
//  QCCore
//
//  Created by tt on 2020/1/12.
//

#import <Foundation/Foundation.h>
#import "QCPanel.h"
#import "QCConversationContext.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^onClickBlock)(id<QCConversationContext>  conversationContext);

@interface QCMoreItemModel : NSObject

@property(nonatomic,copy) onClickBlock oncClickBLock;
@property(nonatomic,strong) UIImage *image;
@property(nonatomic,copy) NSString *title;

+(QCMoreItemModel*) initWithImage:(UIImage*)image title:(NSString*)title onClick:(onClickBlock)onClickBlock;

+(Class) moreItemCellClass;

@end

NS_ASSUME_NONNULL_END
