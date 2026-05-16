//
//  QCTouchTableView.h
//  WuKongMoment
//
//  Created by tt on 2020/11/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol QCTouchTableViewDelegate <NSObject>

@optional

- (void)tableView:(UITableView *)tableView touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

@end

@interface QCTouchTableView : UITableView

@property (nonatomic,weak) id<QCTouchTableViewDelegate> touchTableViewDelegate;

@end

NS_ASSUME_NONNULL_END
