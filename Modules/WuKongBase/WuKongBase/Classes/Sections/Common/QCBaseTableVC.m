//
//  QCBaseTableVC.m
//  WuKongBase
//
//  Created by tt on 2020/2/2.
//

#import "QCBaseTableVC.h"
#import "QCFormItemModel.h"
#import "QCFormItemCell.h"
#import "QCFormSection.h"
#import "QCBaseTableVM.h"
#import <MJRefresh/MJRefresh.h>
#define tipWidth (self.view.lim_width - 26.0f)

typedef enum : NSUInteger {
    UIStateLoading, // 加载中
    UIStateError, // 请求错误
    UIStateNoData, // 无数据
    UIStateHasData // 有数据
} UIState;

@interface QCBaseTableVC ()<UITableViewDelegate,UITableViewDataSource,QCTouchTableViewDelegate,QCBaseTableVMDelegate>
@property(nonatomic,strong) UIView *placeholderView; // 占位视图
@property(nonatomic,strong) UIView *noDataView; // 无数据视图
@property(nonatomic,strong) UIView *loadingView; // 加载中的视图

@end

@implementation QCBaseTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    self.items = [NSMutableArray array];
    [self.view addSubview:self.placeholderView];

    if(self.viewModel && [self.viewModel isKindOfClass:[QCBaseTableVM class]]) {
        QCBaseTableVM *baseVM = (QCBaseTableVM*)self.viewModel;
        baseVM.delegateR = self;
        [self reloadRemoteData];
        if(baseVM.enablePullup) {
            __weak typeof(baseVM) weakbBseVM = baseVM;
            __weak typeof(self) weakSelf = self;
           __block MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
               [weakSelf.tableView.mj_footer beginRefreshing];
                [weakbBseVM pullup:^(BOOL hasMore) {
                     [weakSelf reloadData];
                    [weakSelf.tableView.mj_footer endRefreshing];
                    if(!hasMore) {
                        [weakSelf.tableView.mj_footer setHidden:YES];
                    }
                }];
            }];
            footer.refreshingTitleHidden = YES;
            footer.stateLabel.hidden  = YES;
            self.tableView.mj_footer = footer;
        }
    }
}

// 重置上拉状态
-(void) resetPullupState {
    [self.tableView.mj_footer setHidden:NO];
}

-(void) reloadRemoteData {
    __weak typeof(self) weakSelf = self;
    [self refreshUIState:UIStateLoading];
    [(QCBaseTableVM*)self.viewModel requestData:^(NSError * _Nonnull error) {
        weakSelf.items = [NSMutableArray arrayWithArray:[(QCBaseTableVM*)self.viewModel tableSections]];
        if(!weakSelf.items || weakSelf.items.count<=0) {
            [weakSelf refreshUIState:UIStateNoData];
        }else {
            [weakSelf refreshUIState:UIStateHasData];
        }
        [weakSelf.tableView reloadData];
    }];
}

- (UITableView *)tableView{
    if (!_tableView) {
        // 如果自定义了tableView 直接返回自定义的
        _tableView = [self customTableView];
        if(!_tableView) {
           _tableView = [[QCTouchTableView alloc] initWithFrame:[self tableViewFrame] style:[self tableViewStyle]];
            UIEdgeInsets separatorInset = _tableView.separatorInset;
            separatorInset.right          = 0;
            ((QCTouchTableView*)_tableView).touchTableViewDelegate = self;
            _tableView.separatorInset = separatorInset;
            _tableView.backgroundColor=[UIColor clearColor];
            _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
            _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            _tableView.sectionHeaderHeight = 0.0f;
            _tableView.sectionFooterHeight = 0.0f;
            _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(-0.1f, 0.0f, 0.0f, 0.0f); // TODO: 这里必须要-0.1 要不然滚动条不能滚到顶部 why？？
            _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            _tableView.estimatedRowHeight = 0;
            _tableView.estimatedSectionHeaderHeight = 0;
            _tableView.estimatedSectionFooterHeight = 0;
            _tableView.tableHeaderView =  [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.001)];
            _tableView.tableFooterView = [[UIView alloc] init];
            [_tableView.tableHeaderView setBackgroundColor:[UIColor whiteColor]];
        }
      
       
        _tableView.dataSource = self;
        _tableView.delegate = self;
       
        
        
    }
    return _tableView;
}

-(void) refreshUIState:(UIState)state {
    [self.loadingView removeFromSuperview];
    [self.noDataView removeFromSuperview];
    switch (state) {
        case UIStateLoading:
            [self.placeholderView addSubview:self.loadingView];
            break;
        case UIStateNoData:
            [self.placeholderView addSubview:self.noDataView];
            break;
        default:
            break;
    }
}

-(UIView*) noDataView {
    if(!_noDataView) {
        UILabel *lbl = [[UILabel alloc] init];
        lbl.text = [self noDataText];
        [lbl setFont:[[QCApp shared].config appFontOfSizeMedium:17.0f]];
        [lbl setTextAlignment:NSTextAlignmentCenter];
        [lbl sizeToFit];
        lbl.lim_top = self.placeholderView.lim_height/2.0f - lbl.lim_height/2.0f - 200.0f;
        lbl.lim_left = self.placeholderView.lim_width/2.0f - lbl.lim_width/2.0f;
        [lbl setTextColor:[UIColor grayColor]];
        _noDataView = lbl;
    }
   return _noDataView;
}

-(NSString*) noDataText {
    return LLangC(@"暂无数据",[QCBaseTableVC class]);
}
- (UIView *)loadingView {
    if(!_loadingView) {
        UILabel *lbl = [[UILabel alloc] init];
        lbl.text = [self loadingText];
        [lbl setFont:[[QCApp shared].config appFontOfSizeMedium:17.0f]];
        [lbl setTextAlignment:NSTextAlignmentCenter];
        [lbl sizeToFit];
        lbl.lim_top = self.placeholderView.lim_height/2.0f - lbl.lim_height/2.0f - 200.0f;
        lbl.lim_left = self.placeholderView.lim_width/2.0f - lbl.lim_width/2.0f;
        [lbl setTextColor:[UIColor grayColor]];
        _loadingView = lbl;
    }
    return _loadingView;
}

-(NSString*) loadingText {
    return LLangC(@"数据加载中",[QCBaseTableVC class]);
}

- (UIView *)placeholderView {
    if(!_placeholderView) {
        _placeholderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, [self visibleRect].origin.y, self.view.lim_width, [self visibleRect].size.height)];
    }
    return _placeholderView;
}

-(UITableView*) customTableView {
    return nil;
}

-(UITableViewStyle) tableViewStyle {
    return UITableViewStyleGrouped;
}

-(CGRect) tableViewFrame {
    return [self visibleRect];
}

-(NSArray<QCFormSection*>*) toSections:(NSArray<NSDictionary*>*) sectionArray {
    // NSDictionary *test = @[@{@"height":@(20.0f),@"items":@[@{@"class":@"QCLabelIemModel",@"label":@"群名称",@"value":@"测试"}]}];
    if(!sectionArray || sectionArray.count<=0) {
        return nil;
    }
    NSMutableArray<QCFormSection*> *sections = [NSMutableArray array];
    for (NSDictionary *sectionDict in sectionArray) {
        QCFormSection *section = [QCFormSection new];
        if(sectionDict[@"height"]) {
            section.height = [sectionDict[@"height"] floatValue];
        }
        if(sectionDict[@"items"]) {
            NSMutableArray *items = [NSMutableArray array];
            for (NSDictionary *itemDict in sectionDict[@"items"]) {
                Class formModelClass =  itemDict[@"class"];
                id object = [formModelClass new];
                for (NSString *key in itemDict.allKeys) {
                    if([key isEqualToString:@"class"]) {
                        continue;
                    }
                    [object setValue:itemDict[key] forKey:key];
                }
                [items addObject:object];
            }
            section.items = items;
        }
        [sections addObject:section];
    }
    return sections;
}

- (void)setItems:(NSMutableArray<QCFormSection *> *)items {
    _items = items;
    if(!items || items.count<=0) {
        [self.tableView setBackgroundView:self.placeholderView];
    }else {
        [self.tableView setBackgroundView:nil];
    }
}

- (void)reloadData {
    if(self.viewModel && [self.viewModel isKindOfClass:[QCBaseTableVM class]]) {
        QCBaseTableVM *tableVM = (QCBaseTableVM*)self.viewModel;
        self.items = [NSMutableArray arrayWithArray:[tableVM tableSections]];
        [self.tableView reloadData];
    }
}

-(void) viewConfigChange:(QCViewConfigChangeType)type {
    [super viewConfigChange:type];
    [self reloadData];
}

#pragma mark -  UITableViewDelegate && UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    QCFormItemModel *itemModel =  self.items[indexPath.section].items[indexPath.row];
    Class cellClass = [itemModel cell];
    NSString *identifier = [cellClass cellId];
    QCFormItemCell *cell  = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell) {
        cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)tableCell forRowAtIndexPath:(NSIndexPath *)indexPath {
    QCFormItemModel *itemModel =  self.items[indexPath.section].items[indexPath.row];
    QCFormItemCell *cell = (QCFormItemCell*)tableCell;
    [cell refresh:itemModel];
    if([cell respondsToSelector:@selector(onWillDisplay)]) {
        [cell onWillDisplay];
    }
    
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)tableCell forRowAtIndexPath:(NSIndexPath *)indexPath {
    QCFormItemCell *cell = (QCFormItemCell*)tableCell;
    if([cell respondsToSelector:@selector(onEndDisplay)]) {
        [cell onEndDisplay];
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.items[section].items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    QCFormItemModel *itemModel =  self.items[indexPath.section].items[indexPath.row];
    return [[itemModel cell] sizeForModel:itemModel].height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    QCFormSection *formSection = self.items[section];
    UIView *view = formSection.headView;
    if(view) {
        return view;
    }
    if(formSection.title && ![formSection.title isEqualToString:@""]) {
         return [self getTipView:formSection.title top:formSection.height];
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    QCFormSection *formSection = self.items[section];
    if(formSection.title && ![formSection.title isEqualToString:@""]) {
        CGSize size = [QCBaseTableVC getTextSize:formSection.title maxWidth:tipWidth];
        return size.height+10.0f+formSection.height;
    }
    return formSection.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    QCFormSection *formSection = self.items[section];
    if(formSection.remark && ![formSection.remark isEqualToString:@""]) {
       CGSize size = [QCBaseTableVC getTextSize:formSection.remark maxWidth:tipWidth];
        return size.height+10.0f;
    }
    return 0.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
     QCFormSection *formSection = self.items[section];
     if(formSection.remark && ![formSection.remark isEqualToString:@""]) {
         
         return [self getTipView:formSection.remark top:0.0f];
     }
    return nil;
}


-(UIView*) getTipView:(NSString*)tip top:(CGFloat)top {
    CGSize size = [QCBaseTableVC getTextSize:tip maxWidth:tipWidth];
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.lim_width, 0.0f)];
    v.backgroundColor = [self headColor];
    UILabel *tipLbl = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 5.0f+top, size.width, size.height)];
    tipLbl.text = tip;
    tipLbl.numberOfLines = 0;
    tipLbl.lineBreakMode = NSLineBreakByWordWrapping;
    [tipLbl setTextColor:[QCApp shared].config.tipColor];
    tipLbl.font = [[QCApp shared].config appFontOfSize:[QCApp shared].config.footerTipFontSize];
    [v addSubview:tipLbl];
//    [tipLbl setBackgroundColor:[UIColor redColor]];
    return v;
}

-(UIColor*) headColor {
    return [UIColor clearColor];
}

+ (CGSize) getTextSize:(NSString*) text maxWidth:(CGFloat)maxWidth{
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineBreakMode = NSLineBreakByWordWrapping;
//    style.alignment = NSTextAlignmentCenter;
    NSAttributedString *string = [[NSAttributedString alloc]initWithString:text attributes:@{NSFontAttributeName:[[QCApp shared].config appFontOfSize:[QCApp shared].config.footerTipFontSize], NSParagraphStyleAttributeName:style}];
    CGSize size =  [string boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    return size;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.items.count;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    QCFormItemModel *itemModel =  self.items[indexPath.section].items[indexPath.row];
    if(itemModel) {
        if(itemModel.onClick) {
            itemModel.onClick(itemModel,indexPath);
        }
    }
}


#pragma mark -- QCTouchTableViewDelegate

- (void)tableView:(UITableView *)tableView touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)baseTableReloadData:(QCBaseTableVM *)vm {
    [self reloadData];
}

- (void)baseTableReloadRemoteData:(QCBaseTableVM *)vm {
    [self reloadRemoteData];
}

-(void) baseTableResetPullupState:(QCBaseTableVM *)vm {
    [self resetPullupState];
}

@end
