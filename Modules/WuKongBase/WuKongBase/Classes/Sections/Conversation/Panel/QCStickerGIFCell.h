//
//  QCStickerGIFCell.h
//  WuKongBase
//
//  Created by tt on 2020/2/1.
//

#import "WuKongBase.h"
#import "QCStickerPackage.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCStickerGIFCell : UICollectionViewCell

@property(nonatomic,copy) void(^onCheck)(BOOL on);

@property(nonatomic,assign) BOOL allowLongPress; // 是否允许长按

+(NSString *)reuseIdentifier;

-(void) onWillDisplay;

-(void) onEndDisplay;

-(void) refresh:(QCSticker*)sticker;
@end

NS_ASSUME_NONNULL_END
