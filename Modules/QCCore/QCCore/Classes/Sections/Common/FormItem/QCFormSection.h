//
//  QCFormSection.h
//  QCCore
//
//  Created by tt on 2020/1/21.
//

#import <Foundation/Foundation.h>
#import "QCFormItemModel.h"
NS_ASSUME_NONNULL_BEGIN
#define QCSectionHeight @(10.0f)
@interface QCFormSection : NSObject

+(instancetype) withItems:(NSArray<QCFormItemModel*>*)items height:(CGFloat)height;

+(instancetype) withItems:(NSArray<QCFormItemModel*>*)items height:(CGFloat)height headView:(UIView* __nullable)headView;

/**
 section下的items
 */
@property(nonatomic,strong) NSArray<QCFormItemModel*> *items;


/**
 头部视图
 */
@property(nonatomic,strong) UIView *headView;


/**
 头部高度
 */
@property(nonatomic,assign) CGFloat height;
// 标题
@property(nonatomic,copy) NSString *title;
//备注
@property(nonatomic,copy) NSString *remark;


@end

NS_ASSUME_NONNULL_END
