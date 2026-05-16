
#import "QCActionSheetItem.h"

@implementation QCActionSheetItem

+ (QCActionSheetItem *)itemWithTitle:(NSString *)title index:(NSInteger)index{
    
    QCActionSheetItem *sheetItem = [[QCActionSheetItem alloc] initWithTitle:title index:index];
    return sheetItem;
}

- (instancetype)initWithTitle:(NSString *)title index:(NSInteger)index {
    self = [super init];
    if(self) {
        _title = title;
        _index = index;
    }
    return self;
}


@end
