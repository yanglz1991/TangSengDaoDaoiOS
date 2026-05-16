//
//  QCConversationListCell.h
//  QCCore
//
//  Created by tt on 2019/12/22.
//

#import <Foundation/Foundation.h>
#import "QCConversationWrapModel.h"
#import "SwipeTableCell.h"
NS_ASSUME_NONNULL_BEGIN


@interface QCConversationListCell : SwipeTableCell

-(void) refreshWithModel:(QCConversationWrapModel*)model;
@end

NS_ASSUME_NONNULL_END
