//
//  QCMoreItem.h
//  QCCore
//
//  Created by tt on 2020/1/12.
//

#import <UIKit/UIKit.h>
#import "QCConversationContext.h"
#import "QCMoreItemModel.h"
#import "QCPanel.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCMoreItemCell : UICollectionViewCell

@property(nonatomic,weak) id<QCConversationContext> conversatonContext;


+(NSString *)reuseIdentifier;

-(void) refresh:(QCMoreItemModel*)model;

@end

NS_ASSUME_NONNULL_END
