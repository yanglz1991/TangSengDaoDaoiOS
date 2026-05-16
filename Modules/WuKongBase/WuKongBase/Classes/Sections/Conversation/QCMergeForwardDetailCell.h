//
//  QCMergeForwardDetailCell.h
//  WuKongBase
//
//  Created by tt on 2020/10/12.
//

#import "QCFormItemCell.h"
#import <WuKongIMSDK/WuKongIMSDK.h>
NS_ASSUME_NONNULL_BEGIN

@interface QCMergeForwardDetailHeaderView : UIView

- (instancetype)initWithFrame:(CGRect)frame title:(NSString*)title;

@end

//---------- 基础框架cell ----------
@interface QCMergeForwardDetailModel : QCFormItemModel

@property(nonatomic,strong) QCMessage *message;

@property(nonatomic,assign) BOOL hideAvatar; // 隐藏头像


@end

@interface QCMergeForwardDetailCell : QCFormItemCell

+(CGFloat) contentHeightForModel:(QCFormItemModel*)model maxWidth:(CGFloat)maxWidth;

@property(nonatomic,strong) QCMergeForwardDetailModel *model;

@property(nonatomic,strong) UIView *messageContentView;

@end

//---------- 文本cell ----------

@interface QCMergeForwardDetailTextModel : QCMergeForwardDetailModel

@end

@interface QCMergeForwardDetailTextCell : QCMergeForwardDetailCell

@end

//----------图片cell ----------

@interface QCMergeForwardDetailImageModel : QCMergeForwardDetailModel

@end

@interface QCMergeForwardDetailImageCell : QCMergeForwardDetailCell

@end



//----------其他cell ----------

@interface QCMergeForwardDetailOtherModel : QCMergeForwardDetailModel

@end

@interface QCMergeForwardDetailOtherCell : QCMergeForwardDetailCell

@end

NS_ASSUME_NONNULL_END
