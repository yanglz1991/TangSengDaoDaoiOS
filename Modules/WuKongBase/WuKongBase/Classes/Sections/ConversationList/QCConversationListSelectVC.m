//
//  QCConversationSelectVC.m
//  WuKongBase
//
//  Created by tt on 2020/2/2.
//

#import "QCConversationListSelectVC.h"
#import "QCConversationWrapModel.h"
#import <SDWebImage/SDWebImage.h>
#import "QCResource.h"
#import "UIView+WK.h"
#import "QCLabelItemCell.h"
#import "QCIconTitleItemCell.h"

#define TAB_HEIGHT 40.0f
#define SELECT_ALL_BAR_HEIGHT 36.0f
#define BOTTOM_BAR_HEIGHT 56.0f

@interface QCConversationListSelectVC ()<QCChannelManagerDelegate,QCConversationListSelectVMDelegate>
@property(nonatomic,strong) UIView *tabContainer;
@property(nonatomic,strong) NSArray<UIButton*> *tabButtons;
@property(nonatomic,strong) NSArray<UIView*> *tabIndicators;
@property(nonatomic,strong) UIView *selectAllBar;     // 多选下显示的全选/取消全选工具行
@property(nonatomic,strong) UIButton *selectAllBtn;
@property(nonatomic,strong) UILabel *selectAllCountLbl;
@property(nonatomic,strong) UIView *bottomBar;
@property(nonatomic,strong) UIButton *confirmBtn;
@end

@implementation QCConversationListSelectVC


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [QCConversationListSelectVM new];
        self.viewModel.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.title = LLang(@"选择会话");
    [self setupTabs];
    if (self.viewModel.multiple) {
        [self setupSelectAllBar];
        [self setupBottomBar];
        [self updateConfirmTitle];
        [self updateSelectAllBar];
    }
    [self addDelegates];
}

-(CGRect) tableViewFrame {
    CGRect r = [super tableViewFrame];
    r.origin.y += TAB_HEIGHT;
    r.size.height -= TAB_HEIGHT;
    if (self.viewModel.multiple) {
        // 多选模式下顶部多一行全选工具栏，底部多一行确认栏
        r.origin.y += SELECT_ALL_BAR_HEIGHT;
        r.size.height -= SELECT_ALL_BAR_HEIGHT;
        r.size.height -= (BOTTOM_BAR_HEIGHT + [self safeBottomInset]);
    }
    return r;
}

- (CGFloat)safeBottomInset {
    if (@available(iOS 11.0, *)) {
        return self.view.safeAreaInsets.bottom;
    }
    return 0;
}

#pragma mark - Tabs

- (void)setupTabs {
    CGFloat top = self.navigationBar.lim_bottom;
    self.tabContainer = [[UIView alloc] initWithFrame:CGRectMake(0, top, self.view.lim_width, TAB_HEIGHT)];
    self.tabContainer.backgroundColor = [QCApp shared].config.cellBackgroundColor;
    [self.view addSubview:self.tabContainer];

    NSArray<NSString*> *titles = @[LLang(@"最近聊天"), LLang(@"群组"), LLang(@"好友")];
    NSMutableArray *btns = [NSMutableArray array];
    NSMutableArray *indicators = [NSMutableArray array];
    CGFloat btnW = self.view.lim_width / titles.count;
    for (NSInteger i = 0; i < titles.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(btnW * i, 0, btnW, TAB_HEIGHT - 2);
        btn.tag = i;
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn addTarget:self action:@selector(onTabTap:) forControlEvents:UIControlEventTouchUpInside];
        [self.tabContainer addSubview:btn];
        [btns addObject:btn];

        UIView *ind = [[UIView alloc] initWithFrame:CGRectMake(btnW * i + (btnW - 24)/2, TAB_HEIGHT - 2, 24, 2)];
        ind.layer.cornerRadius = 1;
        [self.tabContainer addSubview:ind];
        [indicators addObject:ind];
    }
    self.tabButtons = btns;
    self.tabIndicators = indicators;
    [self updateTabUI];

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, TAB_HEIGHT - 0.5, self.view.lim_width, 0.5)];
    line.backgroundColor = [QCApp shared].config.lineColor;
    [self.tabContainer addSubview:line];
}

- (void)onTabTap:(UIButton*)btn {
    QCConversationListSelectTab tab = (QCConversationListSelectTab)btn.tag;
    [self.viewModel switchTab:tab];
    [self updateTabUI];
    [self updateSelectAllBar];
}

- (void)updateTabUI {
    UIColor *active = [QCApp shared].config.themeColor;
    UIColor *normal = [QCApp shared].config.tipColor ?: [UIColor grayColor];
    for (NSInteger i = 0; i < self.tabButtons.count; i++) {
        BOOL isActive = (self.viewModel.currentTab == (QCConversationListSelectTab)i);
        [self.tabButtons[i] setTitleColor:isActive ? active : normal forState:UIControlStateNormal];
        self.tabButtons[i].titleLabel.font = isActive ? [UIFont boldSystemFontOfSize:14] : [UIFont systemFontOfSize:14];
        self.tabIndicators[i].backgroundColor = isActive ? active : [UIColor clearColor];
    }
}

#pragma mark - SelectAll Bar

- (void)setupSelectAllBar {
    CGFloat top = self.tabContainer.lim_bottom;
    self.selectAllBar = [[UIView alloc] initWithFrame:CGRectMake(0, top, self.view.lim_width, SELECT_ALL_BAR_HEIGHT)];
    self.selectAllBar.backgroundColor = [QCApp shared].config.cellBackgroundColor;
    [self.view addSubview:self.selectAllBar];

    self.selectAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.selectAllBtn.frame = CGRectMake(15, 0, 100, SELECT_ALL_BAR_HEIGHT);
    self.selectAllBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    self.selectAllBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.selectAllBtn setTitleColor:[QCApp shared].config.themeColor forState:UIControlStateNormal];
    [self.selectAllBtn setTitleColor:[[QCApp shared].config.themeColor colorWithAlphaComponent:0.4] forState:UIControlStateDisabled];
    [self.selectAllBtn addTarget:self action:@selector(onSelectAllTap) forControlEvents:UIControlEventTouchUpInside];
    [self.selectAllBar addSubview:self.selectAllBtn];

    self.selectAllCountLbl = [[UILabel alloc] initWithFrame:CGRectMake(self.view.lim_width - 165, 0, 150, SELECT_ALL_BAR_HEIGHT)];
    self.selectAllCountLbl.font = [UIFont systemFontOfSize:12];
    self.selectAllCountLbl.textAlignment = NSTextAlignmentRight;
    self.selectAllCountLbl.textColor = [QCApp shared].config.tipColor ?: [UIColor grayColor];
    [self.selectAllBar addSubview:self.selectAllCountLbl];

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, SELECT_ALL_BAR_HEIGHT - 0.5, self.view.lim_width, 0.5)];
    line.backgroundColor = [QCApp shared].config.lineColor;
    [self.selectAllBar addSubview:line];
}

- (void)onSelectAllTap {
    [self.viewModel toggleSelectAllCurrentTab];
    [self updateSelectAllBar];
    [self updateConfirmTitle];
}

- (void)updateSelectAllBar {
    if (!self.viewModel.multiple) return;
    NSInteger total = [self.viewModel currentTabSelectableCount];
    NSInteger selected = [self.viewModel currentTabSelectedCount];
    BOOL allSelected = [self.viewModel isCurrentTabAllSelected];
    NSString *title = allSelected ? LLang(@"取消全选") : LLang(@"全选");
    [self.selectAllBtn setTitle:title forState:UIControlStateNormal];
    self.selectAllBtn.enabled = total > 0;
    self.selectAllCountLbl.text = [NSString stringWithFormat:@"%@ %ld / %ld", LLang(@"已选"), (long)selected, (long)total];
}

#pragma mark - Bottom Bar

- (void)setupBottomBar {
    CGFloat bottomInset = [self safeBottomInset];
    CGFloat y = self.view.lim_height - BOTTOM_BAR_HEIGHT - bottomInset;
    self.bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, y, self.view.lim_width, BOTTOM_BAR_HEIGHT + bottomInset)];
    self.bottomBar.backgroundColor = [QCApp shared].config.cellBackgroundColor;
    [self.view addSubview:self.bottomBar];

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.lim_width, 0.5)];
    line.backgroundColor = [QCApp shared].config.lineColor;
    [self.bottomBar addSubview:line];

    self.confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat btnW = self.view.lim_width - 30;
    self.confirmBtn.frame = CGRectMake(15, 6, btnW, BOTTOM_BAR_HEIGHT - 12);
    self.confirmBtn.layer.cornerRadius = 8;
    self.confirmBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [self.confirmBtn addTarget:self action:@selector(onConfirmTap) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar addSubview:self.confirmBtn];
}

- (void)onConfirmTap {
    [self.viewModel commitSelection];
}

- (void)updateConfirmTitle {
    NSInteger n = self.viewModel.selectedChannelsArray.count;
    UIColor *theme = [QCApp shared].config.themeColor;
    UIColor *disabled = [theme colorWithAlphaComponent:0.4];
    NSString *title = n > 0 ? [NSString stringWithFormat:@"%@(%ld)", LLang(@"确定"), (long)n] : LLang(@"确定");
    [self.confirmBtn setTitle:title forState:UIControlStateNormal];
    [self.confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.confirmBtn.backgroundColor = n > 0 ? theme : disabled;
    self.confirmBtn.userInteractionEnabled = n > 0;
}

-(void) addDelegates {
    // 频道信息监听
    [[[QCSDK shared] channelManager] addDelegate:self];
}

-(void) removeDelegates {
    // 移除频道监听
    [[[QCSDK shared] channelManager] removeDelegate:self];
}
-(void) dealloc {
    [self removeDelegates];
}

-(UIImage*) imageName:(NSString*)name {
    return [QCApp.shared loadImage:name moduleID:@"WuKongBase"];
}

#pragma mark QCConversationListSelectVMDelegate

- (void)conversationListSelectVM:(QCConversationListSelectVM *)vm didSelected:(NSArray<QCChannel *> *)channels {
    if (vm.multiple) {
        if (self.onSelectChannels) {
            self.onSelectChannels(channels);
        } else if (self.onSelect && channels.count > 0) {
            // 兼容回退
            self.onSelect(channels.firstObject);
        }
    } else {
        if (self.onSelect && channels.count > 0) {
            self.onSelect(channels.firstObject);
        }
    }
}

- (void)conversationListSelectVM:(QCConversationListSelectVM *)vm selectedChanged:(NSArray<QCChannel *> *)channels {
    [self updateConfirmTitle];
    [self updateSelectAllBar];
}

#pragma mark -- QCChannelManagerDelegate
-(void) channelInfoUpdate:(QCChannelInfo*)channelInfo {
    [self reloadData];
    [self updateSelectAllBar];
}
@end

