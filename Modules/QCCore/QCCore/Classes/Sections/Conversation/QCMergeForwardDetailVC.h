//
//  QCMergeForwardDetailVC.h
//  QCCore
//
//  Created by tt on 2020/10/12.
//

#import "QCMergeForwardDetailVM.h"
#import "QCBaseTableVC.h"
#import "QCMergeForwardContent.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCMergeForwardDetailVC : QCBaseTableVC<QCMergeForwardDetailVM*>

@property(nonatomic,strong)  QCMergeForwardContent *mergeForwardContent;

@end

NS_ASSUME_NONNULL_END
