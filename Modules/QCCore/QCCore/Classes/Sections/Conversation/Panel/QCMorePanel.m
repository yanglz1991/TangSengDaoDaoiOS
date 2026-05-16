//
//  QCMorePanel.m
//  QCCore
//
//  Created by tt on 2020/1/9.
//

#import "QCMorePanel.h"
#import "QCConstant.h"
#import "QCCollectionViewGridLayout.h"
#import "QCApp.h"
#import "QCMoreItemCell.h"
#import "QCConstant.h"
#import "QCMoreItemModel.h"
@interface QCMorePanel ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property(nonatomic,strong) UICollectionView *collectionView;

@property(nonatomic,strong) NSArray<QCMoreItemModel*> *moreItems;

@end
@implementation QCMorePanel

-(instancetype) initWithContext:(id<QCConversationContext>) context {
    self = [super initWithContext:context];
    if(self) {
        self.moreItems = [[QCApp shared] invokes:QCPOINT_CATEGORY_PANELMORE_ITEMS param:@{@"context":context}];
        [self addSubview:self.collectionView];
    }
    return self;
}

-(void) layoutPanel:(CGFloat)height {
    self.frame = CGRectMake(0, 0, QCScreenWidth,height);
     self.collectionView.frame = self.frame;
}


// grid布局
+(QCCollectionViewGridLayout *)newGridLayout
{
    QCCollectionViewGridLayout *layout = [QCCollectionViewGridLayout new];
    layout.itemSpacing = 20;
    layout.lineSpacing = 40;
    layout.lineSize = 0;
    layout.lineItemCount = 4;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.sectionsStartOnNewLine = NO;
    
    return layout;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

-(UICollectionView*) collectionView {
    if(!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) collectionViewLayout:[[self class] newGridLayout]];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView setBackgroundColor:[QCApp shared].config.backgroundColor];
        [_collectionView setContentInset:UIEdgeInsetsMake(40.0f, 20.0f, 20.0f, 20.0f)];
        if(self.moreItems) {
            for (QCMoreItemModel *model in self.moreItems) {
                 Class moreItemCellClass = [[model class] moreItemCellClass];
                [_collectionView registerClass:moreItemCellClass forCellWithReuseIdentifier:[moreItemCellClass reuseIdentifier]];
            }
        }
    }
    return _collectionView;
}


#pragma mark - UICollectionViewDataSource && UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.moreItems.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    QCMoreItemModel *model = [self.moreItems objectAtIndex:indexPath.row];
    Class moreItemCellClass = [[model class] moreItemCellClass];
    QCMoreItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[moreItemCellClass reuseIdentifier] forIndexPath:indexPath];
    cell.conversatonContext = self.context;
    
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(QCMoreItemCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
      QCMoreItemModel *model = [self.moreItems objectAtIndex:indexPath.row];
    [cell refresh:model];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    QCMoreItemModel *model = [self.moreItems objectAtIndex:indexPath.row];
    if(model.oncClickBLock) {
        model.oncClickBLock(self.context);
    }
}
@end
