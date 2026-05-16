//
//  QCGlobalSearchResultController.m
//  WuKongBase
//
//  Created by tt on 2020/4/24.
//
#import "QCGlobalSearchVM.h"
#import "QCGlobalSearchResultController.h"
#import "QCTabbar.h"
#define searchBarHeight 36.0f
@interface QCGlobalSearchResultController ()<QCChannelManagerDelegate>
@property(nonatomic,strong) QCGlobalSearchVM *vm; // 搜索逻辑

@property(nonatomic,strong) UITextField *searchBarInput; // 搜索输入框
@property(nonatomic,strong) UIView *searchBarView; // 输入框的bar

@property(nonatomic,strong) QCTabbar *tabbar; // 顶部搜索类型的tabbar



@end

@implementation QCGlobalSearchResultController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.vm = [QCGlobalSearchVM new];
        self.vm.enablePullup = true;
        self.viewModel = self.vm;
    }
    return self;
}

- (void)viewDidLoad {
    
    self.vm.searchType = self.searchType;
    self.vm.channel = self.channel;
    
    [super viewDidLoad];
   
    [self.navigationBar addSubview:self.searchBarView];
    [self.searchBarView addSubview:self.searchBarInput];
    [self.view addSubview:self.tabbar];
    
    [self.searchBarInput becomeFirstResponder];
    
    self.searchBarInput.text = self.keyword;
    self.vm.keyword = self.keyword;
    
    [[QCSDK shared].channelManager addDelegate:self];
    
    self.tabbar.lim_bottom = self.tableView.lim_top;
    
}
- (CGRect)tableViewFrame {
    CGRect rect = [self visibleRect];
    return CGRectMake(0.0f, rect.origin.y + self.tabbar.lim_height + 4.0f, rect.size.width, rect.size.height - self.tabbar.lim_height - 4.0f);
}

- (void)dealloc {
    [[QCSDK shared].channelManager removeDelegate:self];
}

- (UITextField *)searchBarInput {
    if(!_searchBarInput) {
        _searchBarInput = [[UITextField alloc] initWithFrame:CGRectMake(26.0f, 0.0f, self.searchBarView.lim_width - 26.0f, searchBarHeight)];
        _searchBarInput.placeholder = LLang(@"搜索");
        [_searchBarInput addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
        
    }
    return _searchBarInput;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}



- (UIView *)searchBarView {
    if(!_searchBarView) {
        CGFloat statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
        _searchBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.lim_width - 70.0f, searchBarHeight)];
        _searchBarView.lim_left = 45.0f;
        [_searchBarView setBackgroundColor:[QCApp shared].config.cellBackgroundColor];
        _searchBarView.layer.masksToBounds = YES;
        _searchBarView.layer.cornerRadius = 4.0f;
        _searchBarView.lim_top = (self.navigationBar.lim_height-statusHeight)/2.0f - _searchBarView.lim_height/2.0f + statusHeight;
        
        UIImageView *iconImgView = [[UIImageView alloc] initWithImage: [self imageName:@"Common/Index/IconSearch2"]];
        iconImgView.frame = CGRectMake(6.0f, 0.0f, 16.0f, 16.0f);
        iconImgView.lim_top = _searchBarView.lim_height/2.0f - iconImgView.lim_height/2.0f;
        [_searchBarView addSubview:iconImgView];
    }
    return _searchBarView;
}

- (QCTabbar *)tabbar {
    if(!_tabbar) {
        __weak typeof(self) weakSelf = self;
        NSMutableArray<QCTabbarItem*> *items = [NSMutableArray array];
        
        BOOL existFileModule = [QCApp.shared hasMethod:QCPOINT_SEARCH_ITEM_FILE]; // 是否存在文件模块
        [items addObject:[[QCTabbarItem alloc] initWithTitle:LLang(@"聊天") onClick:^{
            [weakSelf.vm changeTabType:@"all"];
        }]];
        
        if(!self.vm.searchInChannel) {
            [items addObject:[[QCTabbarItem alloc] initWithTitle:LLang(@"联系人") onClick:^{
                [weakSelf.vm changeTabType:@"contacts"];
            }]];
            [items addObject:[[QCTabbarItem alloc] initWithTitle:LLang(@"群组") onClick:^{
                [weakSelf.vm changeTabType:@"group"];
            }]];
        }
       
        
        if(self.vm.searchInChannel) { // 在频道内搜才有这个
            [items addObject:[[QCTabbarItem alloc] initWithTitle:LLang(@"图片/视频") onClick:^{
                [weakSelf.vm changeTabType:@"media"];
            }]];
        }
        
        
        // 文件 tab 仅在频道内搜索时显示（频道内走本地 QCMessageDB 查询，可用）。
        // 首页全局搜索的"文件"依赖未启用的 WuKongIM 全文搜索插件 wk.plugin.search/usersearch，
        // 实际搜不到结果，因此从首页搜索入口移除该 tab。
        if(existFileModule && self.vm.searchInChannel) {
            [items addObject:[[QCTabbarItem alloc] initWithTitle:LLang(@"文件") onClick:^{
                [weakSelf.vm changeTabType:@"file"];
            }]];
        }
        
        CGFloat space = 15.0f;
        _tabbar = [[QCTabbar alloc] initWithItems:items width:QCScreenWidth - space*2];
        
        _tabbar.lim_left = space;
    
    }
    return _tabbar;
}



- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
     [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

-(void) viewConfigChange:(QCViewConfigChangeType)type {
    [super viewConfigChange:type];
    if(type == QCViewConfigChangeTypeStyle) {
        [_searchBarView setBackgroundColor:[QCApp shared].config.cellBackgroundColor];
    }
}


#pragma mark -- 事件

- (void)textFieldEditingChanged:(UITextField *)textField {
    [self.vm changeKeyword:textField.text];
}

// 重写返回事件
-(void) backPressed {
    [[QCNavigationManager shared] popViewControllerAnimated:NO];
}

#pragma mark -- 其他

-(UIImage*) imageName:(NSString*)name {
    return [QCApp.shared loadImage:name moduleID:@"WuKongBase"];
//    return [[QCResource shared] resourceForImage:name podName:@"WuKongBase_images"];
}

// 频道内聊天 tab 未输入关键字时，列表保持空白，不显示"暂无数据"四字。
- (NSString *)noDataText {
    if (self.vm && ![self.vm shouldShowNoDataText]) {
        return @"";
    }
    // 与 QCBaseTableVC 默认文案保持一致
    return LLangC(@"暂无数据", [QCBaseTableVC class]);
}

#pragma mark -- QCChannelManagerDelegate

- (void)channelInfoUpdate:(QCChannelInfo *)channelInfo {
    [self reloadData];
}
@end
