//
//  QCUserHandleVC.h
//  WuKongBase
//
//  Created by tt on 2021/11/3.
//

#import <UIKit/UIKit.h>
#import "WuKongBase.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCUserHandleVC : UITableViewController

@property(nonatomic,strong) NSArray<QCFormItemModel*> *items;

// 注册cell
@property(nonatomic,copy) void(^registerCellBlock)(UITableView *tableView,NSString *reuseIdentifier);

// 选中
@property(nonatomic,copy) void(^onSelect)(QCFormItemModel*model);

// 行高
@property(nonatomic,assign) CGFloat rowHeight;


// 加载数据
-(void) reload:(NSArray<QCFormItemModel*>*)items;


@end

@interface QCUserHandleTableHeaderView : UIView


@end

@interface QCUserHandleTableFooterView : UIView

@end

NS_ASSUME_NONNULL_END
