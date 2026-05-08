//
//  WKConversationSelectVC.m
//  WuKongBase
//
//  Created by tt on 2020/2/2.
//

#import "WKConversationListSelectVC.h"
#import "WKConversationWrapModel.h"
#import <SDWebImage/SDWebImage.h>
#import "WKResource.h"
#import "UIView+WK.h"
#import "WKLabelItemCell.h"
#import "WKIconTitleItemCell.h"

#define TAB_HEIGHT 40.0f
#define BOTTOM_BAR_HEIGHT 56.0f

@interface WKConversationListSelectVC ()<WKChannelManagerDelegate,WKConversationListSelectVMDelegate>
@property(nonatomic,strong) UIView *tabContainer;
@property(nonatomic,strong) NSArray<UIButton*> *tabButtons;
@property(nonatomic,strong) NSArray<UIView*> *tabIndicators;
@property(nonatomic,strong) UIView *bottomBar;
@property(nonatomic,strong) UIButton *confirmBtn;
@end

@implementation WKConversationListSelectVC


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [WKConversationListSelectVM new];
        self.viewModel.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.title = LLang(@"选择会话");
    [self setupTabs];
    if (self.viewModel.multiple) {
        [self setupBottomBar];
        [self updateConfirmTitle];
    }
    [self addDelegates];
}

-(CGRect) tableViewFrame {
    CGRect r = [super tableViewFrame];
    r.origin.y += TAB_HEIGHT;
    r.size.height -= TAB_HEIGHT;
    if (self.viewModel.multiple) {
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
    self.tabContainer.backgroundColor = [WKApp shared].config.cellBackgroundColor;
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
    line.backgroundColor = [WKApp shared].config.lineColor;
    [self.tabContainer addSubview:line];
}

- (void)onTabTap:(UIButton*)btn {
    WKConversationListSelectTab tab = (WKConversationListSelectTab)btn.tag;
    [self.viewModel switchTab:tab];
    [self updateTabUI];
}

- (void)updateTabUI {
    UIColor *active = [WKApp shared].config.themeColor;
    UIColor *normal = [WKApp shared].config.tipColor ?: [UIColor grayColor];
    for (NSInteger i = 0; i < self.tabButtons.count; i++) {
        BOOL isActive = (self.viewModel.currentTab == (WKConversationListSelectTab)i);
        [self.tabButtons[i] setTitleColor:isActive ? active : normal forState:UIControlStateNormal];
        self.tabButtons[i].titleLabel.font = isActive ? [UIFont boldSystemFontOfSize:14] : [UIFont systemFontOfSize:14];
        self.tabIndicators[i].backgroundColor = isActive ? active : [UIColor clearColor];
    }
}

#pragma mark - Bottom Bar

- (void)setupBottomBar {
    CGFloat bottomInset = [self safeBottomInset];
    CGFloat y = self.view.lim_height - BOTTOM_BAR_HEIGHT - bottomInset;
    self.bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, y, self.view.lim_width, BOTTOM_BAR_HEIGHT + bottomInset)];
    self.bottomBar.backgroundColor = [WKApp shared].config.cellBackgroundColor;
    [self.view addSubview:self.bottomBar];

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.lim_width, 0.5)];
    line.backgroundColor = [WKApp shared].config.lineColor;
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
    UIColor *theme = [WKApp shared].config.themeColor;
    UIColor *disabled = [theme colorWithAlphaComponent:0.4];
    NSString *title = n > 0 ? [NSString stringWithFormat:@"%@(%ld)", LLang(@"确定"), (long)n] : LLang(@"确定");
    [self.confirmBtn setTitle:title forState:UIControlStateNormal];
    [self.confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.confirmBtn.backgroundColor = n > 0 ? theme : disabled;
    self.confirmBtn.userInteractionEnabled = n > 0;
}

-(void) addDelegates {
    // 频道信息监听
    [[[WKSDK shared] channelManager] addDelegate:self];
}

-(void) removeDelegates {
    // 移除频道监听
    [[[WKSDK shared] channelManager] removeDelegate:self];
}
-(void) dealloc {
    [self removeDelegates];
}

-(UIImage*) imageName:(NSString*)name {
    return [WKApp.shared loadImage:name moduleID:@"WuKongBase"];
}

#pragma mark WKConversationListSelectVMDelegate

- (void)conversationListSelectVM:(WKConversationListSelectVM *)vm didSelected:(NSArray<WKChannel *> *)channels {
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

- (void)conversationListSelectVM:(WKConversationListSelectVM *)vm selectedChanged:(NSArray<WKChannel *> *)channels {
    [self updateConfirmTitle];
}

#pragma mark -- WKChannelManagerDelegate
-(void) channelInfoUpdate:(WKChannelInfo*)channelInfo {
    [self reloadData];
}
@end

