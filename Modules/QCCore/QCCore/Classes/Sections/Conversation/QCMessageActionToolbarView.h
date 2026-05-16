//
//  QCMessageActionToolbarView.h
//  QCCore
//
//  Created by tt on 2021/9/24.
//

#import <UIKit/UIKit.h>
#import <QCCore/QCCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCMessageActionToolbarView : UIView

-(instancetype) initWithToolbarMenus:(NSArray<QCMessageLongMenusItem*>*)toolbarMenus;

@property(nonatomic,copy) void(^onClick)(QCMessageLongMenusItem *menusItem);

@end

NS_ASSUME_NONNULL_END
