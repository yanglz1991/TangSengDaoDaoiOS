//
//  WKGroupApprovalListVC.m
//  WuKongGroupManager
//

#import "WKGroupApprovalListVC.h"
#import "WKAPIClient.h"
#import "WKWebViewVC.h"
#import "WKNavigationManager.h"
#import "UIView+WKCommon.h"

@interface WKGroupApprovalListVC ()<WKGroupApprovalListVMDelegate>

@end

@implementation WKGroupApprovalListVC

- (instancetype)init {
    self = [super init];
    if (self) {
        self.viewModel = [WKGroupApprovalListVM new];
        self.viewModel.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    self.viewModel.channel = self.channel;
    [super viewDidLoad];
}

- (NSString *)langTitle {
    return LLang(@"审批记录");
}

- (NSString *)noDataText {
    return LLang(@"暂无待审批的入群邀请");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 从详情页（H5 审核结果）返回时刷新列表
    if (self.viewModel) {
        [self reloadRemoteData];
    }
}

#pragma mark - WKGroupApprovalListVMDelegate

- (void)groupApprovalListVM:(WKGroupApprovalListVM *)vm didSelectInviteNo:(NSString *)inviteNo {
    if (!inviteNo || inviteNo.length == 0) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[WKAPIClient sharedClient] GET:[NSString stringWithFormat:@"groups/%@/member/h5confirm?invite_no=%@", self.channel.channelId, inviteNo] parameters:nil].then(^(NSDictionary *resultDic) {
        if (resultDic && resultDic[@"url"]) {
            WKWebViewVC *vc = [[WKWebViewVC alloc] init];
            vc.url = [NSURL URLWithString:resultDic[@"url"]];
            [[WKNavigationManager shared] pushViewController:vc animated:YES];
        }
    }).catch(^(NSError *error) {
        [weakSelf.view showMsg:error.domain];
    });
}

@end
