//
//  QCStickerHotContentView.m
//  QCCore
//
//  Created by tt on 2020/1/10.
//

#import "QCStickerGIFContentView.h"
#import "QCCollectionViewGridLayout.h"
#import "QCStickerGIFCell.h"
#import "QCResource.h"
#import "UIView+WK.h"
#import "QCGIFContent.h"
#import "QCLottieStickerContent.h"
#import "QCStickerPackage.h"





@interface QCStickerGIFContentView ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property(nonatomic,strong) UICollectionView *collectionView;
@property(nonatomic,strong) QCStickerPackage *stickerPackage;
@property(nonatomic,copy) NSString *keyword;

@property(nonatomic,strong) UIView *tabView;

@property(nonatomic,strong) NSURL *tabIconURL;

@property(nonatomic,assign) BOOL selectedInner;

@end

static NSMutableDictionary *cacheGifDict;

@implementation QCStickerGIFContentView

-(instancetype) initWithKeyword:(NSString*)keyword tabIconURL:(NSURL*)tabIconURL
{
    self = [super init];
    if (self) {
        self.keyword = keyword;
        self.tabIconURL = tabIconURL;
        [self addSubview:self.collectionView];
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    BOOL change = self.selectedInner != selected;
    self.selectedInner = selected;
    if(self.selectedInner) {
        NSLog(@"keyword--->%@",self.keyword);
    }
    if(change) {
        [self.collectionView reloadData];
    }
    if(!selected) {
       NSArray<QCStickerGIFCell*> *cells = self.collectionView.visibleCells;
        for (QCStickerGIFCell *cell in cells) {
            [cell onEndDisplay];
        }
    }
}

- (BOOL)selected {
    return self.selectedInner;
}

- (void)loadData {
    [self requestHotGif];
}

-(void) requestHotGif {
    NSString *keyword = self.keyword;
    if(!self.keyword) {
        keyword = LLang(@"热图");
    }
    if(!cacheGifDict) {
        cacheGifDict = [NSMutableDictionary dictionary];
    }
    id stickerPackage = cacheGifDict[keyword];
    if(stickerPackage) {
        self.stickerPackage = stickerPackage;
        [self.collectionView reloadData];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [[QCAPIClient sharedClient] GET:@"sticker/user/sticker" parameters:@{@"category":keyword} model:QCStickerPackage.class].then(^(QCStickerPackage *stickerPackage){
        weakSelf.stickerPackage = stickerPackage;
        cacheGifDict[keyword] = stickerPackage;
        [weakSelf.collectionView reloadData];
    });
}

- (UIView *)customTabView {
    if(!_tabView) {
        UIImageView *icon = [[UIImageView alloc] init];
        [icon lim_setImageWithURL:self.tabIconURL];
        _tabView= icon;
    }
    return _tabView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if([self.customTabView isKindOfClass:[UILabel class]]) {
        UILabel *lbl = (UILabel*)self.customTabView;
        lbl.textColor = [QCApp shared].config.defaultTextColor;
    }
    self.collectionView.lim_size = self.lim_size;
}

// grid布局
+(QCCollectionViewGridLayout *)newGridLayout
{
    QCCollectionViewGridLayout *layout = [QCCollectionViewGridLayout new];
    layout.itemSpacing = 10;
    layout.lineSpacing = 10;
    layout.lineSize = 0;
    layout.lineItemCount = 5;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.sectionsStartOnNewLine = NO;
    
    return layout;
}

-(UICollectionView*) collectionView {
    if(!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) collectionViewLayout:[[self class] newGridLayout]];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView setBackgroundColor:[UIColor clearColor]];
        [_collectionView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f,0.0f)];
        [_collectionView registerClass:[QCStickerGIFCell class] forCellWithReuseIdentifier:[QCStickerGIFCell reuseIdentifier]];
    }
    return _collectionView;
}


#pragma mark - UICollectionViewDataSource && UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(self.stickerPackage && self.stickerPackage.list) {
        return self.stickerPackage.list.count;
    }
    return 0;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    QCStickerGIFCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[QCStickerGIFCell reuseIdentifier] forIndexPath:indexPath];
   
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(QCStickerGIFCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
   QCSticker *resp =  self.stickerPackage.list[indexPath.row];
    resp.isPlay = self.selected;
    if(self.selected) { // true为当前被选中的面板
        NSLog(@"self.isPlay--->%d",resp.isPlay?1:0);
    }
    [cell refresh:resp];
    
    [cell onWillDisplay];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(QCStickerGIFCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [cell onEndDisplay];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    QCSticker *resp =  self.stickerPackage.list[indexPath.row];
    QCLottieStickerContent *content = [QCLottieStickerContent new];
    content.url = resp.path;
    content.category =  resp.category;
    content.placeholder = resp.placeholder;
    content.format = resp.format;
    [self.context sendMessage:content];
}


- (void)dealloc
{
    QCLogDebug(@"%s",__func__);
}

@end

