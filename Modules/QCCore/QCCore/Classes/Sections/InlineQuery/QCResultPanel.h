//
//  QCResultPanel.h
//  QCCore
//
//  Created by tt on 2021/11/9.
//

#import <UIKit/UIKit.h>

#import "QCInlineQueryResult.h"



NS_ASSUME_NONNULL_BEGIN

typedef void(^QCLoadMoreCallback)(QCInlineQueryResult *result,NSError *error);

@interface QCResultPanel : UIView

@property(nonatomic,copy) void(^loadMore)(NSString *nextOffset,QCLoadMoreCallback  callback);

@end

NS_ASSUME_NONNULL_END
