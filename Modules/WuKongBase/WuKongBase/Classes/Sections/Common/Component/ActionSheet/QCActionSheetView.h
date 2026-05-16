

#import <UIKit/UIKit.h>

#import <UIKit/UIKit.h>
#import "QCActionSheetItem.h"

typedef void(^ClickBlock)(QCActionSheetItem *sheetItem);

@interface QCActionSheetView : UIView

@property (nonatomic,copy)ClickBlock clickBlock;


- (instancetype)initWithCancleTitle:(NSString *)cancleTitle
                        otherTitles:(NSString *)otherTitles,... NS_REQUIRES_NIL_TERMINATION;

- (instancetype)initWithCancleTitle:(NSString *)cancleTitle otherTitleArray:(NSArray *)otherTitleArray;
- (instancetype)initWithMessageTitle:(NSString*)msgTitle  CancleTitle:(NSString *)cancleTitle otherTitles:(NSString *)otherTitles, ...
NS_REQUIRES_NIL_TERMINATION;
- (void)show;


@end
