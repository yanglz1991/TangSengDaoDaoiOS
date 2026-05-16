//
//  QCGifResultPanel.h
//  QCCore
//
//  Created by tt on 2021/11/9.
//

#import <UIKit/UIKit.h>
#import "QCResultPanel.h"
#import "QCInlineQueryResult.h"
#import "QCCore.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCGifResultPanel : QCResultPanel

+(instancetype) result:(QCInlineQueryResult*)result context:(id<QCConversationContext>)context;

@end

@interface QCGifResultCell : UICollectionViewCell

-(void) refresh:(QCGifResult*)result;

@end

NS_ASSUME_NONNULL_END
