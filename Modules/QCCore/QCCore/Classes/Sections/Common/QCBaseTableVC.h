//
//  QCBaseTableVC.h
//  QCCore
//
//  Created by tt on 2020/2/2.
//

#import "QCCore.h"
#import "QCFormSection.h"
#import "QCTouchTableView.h"
NS_ASSUME_NONNULL_BEGIN


@interface QCBaseTableVC<__covariant VM:QCBaseVM*> : QCBaseVC<VM>

@property(nonatomic,strong) UITableView *tableView;

@property(nonatomic,strong) NSMutableArray<QCFormSection*> *items;


/// table的frame
-(CGRect) tableViewFrame;

/**
 将字典数据转换为WKFormSection

 @param sectionArray <#sectionArray description#>
 @return <#return value description#>
 */
-(NSArray<QCFormSection*>*) toSections:(NSArray<NSDictionary*>*) sectionArray;


/// 重新加载数据
-(void)reloadData;


/// 重新加载远程数据
-(void)reloadRemoteData;

/// 重置上拉状态
-(void) resetPullupState;


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath;

// head的背景颜色
-(UIColor*) headColor;


@end

NS_ASSUME_NONNULL_END
