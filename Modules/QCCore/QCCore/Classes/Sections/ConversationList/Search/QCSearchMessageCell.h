//
//  QCSearchMessageCell.h
//  QCCore
//
//  Created by tt on 2020/5/10.
//

#import "QCFormItemCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface QCSearchMessageModel : QCFormItemModel

@property(nonatomic,strong) QCChannel *channel; // 显示的频道
@property(nonatomic,strong) NSNumber *messageCount; // 消息数量
@property(nonatomic,copy) NSString *content;
@property(nonatomic,copy) NSString *keyword;
@property(nonatomic,assign) NSInteger timestamp; // 消息时间


@end

@interface QCSearchMessageCell : QCFormItemCell

@end

NS_ASSUME_NONNULL_END
