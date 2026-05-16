//
//  QCSearchMediaCell.h
//  WuKongBase
//
//  Created by tt on 2025/2/27.
//

#import <WuKongBase/WuKongBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCSearchMediaItem : NSObject


@property(nonatomic,copy) NSString *url; // 资源地址
@property(nonatomic,copy) NSString *type; // 资源类型 image,video
@property(nonatomic,strong) NSDictionary *extra;

// 点击回调（可选）。若设置，则点击时优先执行该回调而不弹出图片预览，
// 用于把点击行为改为跳转到聊天窗口等其它跳转逻辑。
@property(nonatomic,copy,nullable) void(^onClick)(void);

@end

@interface QCSearchMediaModel : QCFormItemModel
@property(nonatomic,assign) NSInteger numOfRow; // 每行数量
@property(nonatomic,strong) NSArray<QCSearchMediaItem*> *items;


@end

@interface QCSearchMediaCell : QCFormItemCell

@end

NS_ASSUME_NONNULL_END
