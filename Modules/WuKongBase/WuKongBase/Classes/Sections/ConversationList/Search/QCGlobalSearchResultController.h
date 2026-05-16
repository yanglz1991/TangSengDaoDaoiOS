//
//  QCGlobalSearchResultController.h
//  WuKongBase
//
//  Created by tt on 2020/4/24.
//

#import "QCBaseTableVC.h"
#import "QCGlobalSearchController.h"
NS_ASSUME_NONNULL_BEGIN



@interface QCGlobalSearchResultController : QCBaseTableVC

@property(nonatomic,assign) QCHistoryMessageSearchType searchType;

@property(nonatomic,copy) NSString *keyword; // 默认关键字

@property(nonatomic,strong) QCChannel *channel;

@end

NS_ASSUME_NONNULL_END
