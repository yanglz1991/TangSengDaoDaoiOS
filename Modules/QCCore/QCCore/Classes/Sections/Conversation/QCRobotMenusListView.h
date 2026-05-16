//
//  QCRobotMenusListView.h
//  QCCore
//
//  Created by tt on 2021/10/18.
//

#import "QCDragModalView.h"
@class QCRobotMenusItem;

NS_ASSUME_NONNULL_BEGIN

@interface QCRobotMenusItemCell : UITableViewCell

-(void) refresh:(QCRobotMenusItem*)item;

@end

@interface QCRobotMenusItem : NSObject

@property(nonatomic,copy) NSString *cmd;
@property(nonatomic,copy) NSString *iconURL;
@property(nonatomic,copy) NSString *remark;
@property(nonatomic,copy) void(^onClick)(void);

+(QCRobotMenusItem*) cmd:(NSString*)cmd iconURL:(NSString*)iconURL remark:(NSString*)remark onClick:(void(^)(void)) onClick;

@end

@interface QCRobotMenusListView : QCDragModalView

+(instancetype) initItems:(NSArray<QCRobotMenusItem*>*)items;

@end

NS_ASSUME_NONNULL_END
