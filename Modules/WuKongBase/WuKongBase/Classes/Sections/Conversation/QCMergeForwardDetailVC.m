//
//  QCMergeForwardDetailVC.m
//  WuKongBase
//
//  Created by tt on 2020/10/12.
//

#import "QCMergeForwardDetailVC.h"

@interface QCMergeForwardDetailVC ()<QCChannelManagerDelegate>

@end

@implementation QCMergeForwardDetailVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [QCMergeForwardDetailVM new];
    }
    return self;
}

- (void)viewDidLoad {
    self.viewModel.mergeForwardContent = self.mergeForwardContent;
    [super viewDidLoad];
    
    self.title = self.mergeForwardContent.title;
    
    [[QCSDK shared].channelManager addDelegate:self];

}

- (void)dealloc {
    [[QCSDK shared].channelManager removeDelegate:self];
}

#pragma mark - QCChannelManagerDelegate

- (void)channelInfoUpdate:(QCChannelInfo *)channelInfo {
    [self.tableView reloadData];
}

@end
