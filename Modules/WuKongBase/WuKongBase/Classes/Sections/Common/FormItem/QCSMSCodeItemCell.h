//
//  QCSMSCodeItemCell.h
//  WuKongBase
//
//  Created by tt on 2020/10/26.
//

#import "QCFormItemCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface QCSMSCodeItemModel : QCFormItemModel

@property(nonatomic,copy) NSString *sendBtnTitle; // 发送按钮标题
@property(nonatomic,assign) BOOL disable; // 禁止发送
@property(nonatomic,copy) void(^onSend)(void);

@property(nonatomic,copy) void(^onChange)(NSString*value);

@end

@interface QCSMSCodeItemCell : QCFormItemCell

@end

NS_ASSUME_NONNULL_END
