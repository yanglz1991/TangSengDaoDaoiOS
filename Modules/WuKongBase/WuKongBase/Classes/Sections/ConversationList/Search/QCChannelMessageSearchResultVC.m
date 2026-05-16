//
//  QCChannelMessageSearchResultVC.m
//  WuKongBase
//
//  Created by tt on 2020/8/10.
//

#import "QCChannelMessageSearchResultVC.h"
#import "QCChannelMessageSearchVM.h"

@interface QCChannelMessageSearchResultVC ()<QCChannelManagerDelegate>

@property(nonatomic,strong) QCChannelInfo *channelInfo;

@end

@implementation QCChannelMessageSearchResultVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [QCChannelMessageSearchVM new];
    }
    return self;
}

- (void)viewDidLoad {
    self.viewModel.channel = self.channel;
    self.viewModel.keyword = self.keyword;
    [super viewDidLoad];
    
     [[QCChannelManager shared] addDelegate:self];
    
    self.channelInfo = [[QCChannelInfoDB shared] queryChannelInfo:self.channel];
    if(self.channelInfo) {
        self.title = self.channelInfo.displayName;
    }
    
}

- (void)dealloc
{
     [[QCChannelManager shared] removeDelegate:self];
}

- (void)channelInfoUpdate:(QCChannelInfo *)channelInfo {
    [self reloadData];
}


@end
