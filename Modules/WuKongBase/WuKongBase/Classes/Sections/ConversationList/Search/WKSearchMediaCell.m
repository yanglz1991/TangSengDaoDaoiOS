//
//  WKSearchMediaCell.m
//  WuKongBase
//
//  Created by tt on 2025/2/27.
//

#import "WKSearchMediaCell.h"

@implementation WKSearchMediaItem



@end

@implementation WKSearchMediaModel

- (Class)cell {
    return WKSearchMediaCell.class;
}

@end

@interface WKSearchMediaCell ()

@property(nonatomic,strong) NSMutableArray<UIView*> *itemViews;
@property(nonatomic,strong) WKSearchMediaModel *mediaModel;

@end

@implementation WKSearchMediaCell

+ (CGSize)sizeForModel:(WKSearchMediaModel *)model {
    CGFloat itemWidth = WKScreenWidth/model.numOfRow;
    return CGSizeMake(WKScreenWidth, itemWidth);
}

- (void)setupUI {
    [super setupUI];
    
    self.itemViews = [NSMutableArray array];
}

- (void)refresh:(WKSearchMediaModel *)model {
    [super refresh:model];
    self.mediaModel = model;
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSInteger i =0;
    for (WKSearchMediaItem *item in model.items) {
        [self addSubview:[self itemView:item index:i]];
        i++;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSArray<UIView*> *subviews = self.subviews;
    
    UIView *preview;
    for (UIView *view in subviews) {
        if(preview) {
            view.lim_left = preview.lim_right;
        }
        preview = view;
    }
}

-(UIView*) itemView:(WKSearchMediaItem*)item index:(NSInteger)index{
    CGFloat itemWidth = self.lim_width/self.mediaModel.numOfRow;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, itemWidth, itemWidth)];
    
    if(item.type && [item.type isEqualToString:@"video"]) {
        if([WKApp.shared hasMethod:WKPOINT_SEARCH_ITEM_VIDEO]) {
            UIView *videoView = [WKApp.shared invoke:WKPOINT_SEARCH_ITEM_VIDEO param:@{
                @"item": item,
            }];
            videoView.frame = view.frame;
            [view addSubview:videoView];
        }
        return view;
    }
   
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:view.frame];
    [imgView sd_setImageWithURL:[NSURL URLWithString:item.url] placeholderImage:WKApp.shared.config.defaultPlaceholder];
    imgView.layer.masksToBounds = YES;
    imgView.layer.cornerRadius = 0;
    imgView.clipsToBounds = YES;
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.userInteractionEnabled = YES;
    imgView.tag = index;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click:)];
    [imgView addGestureRecognizer:tap];
    [view addSubview:imgView];
    
    return view;
}

-(void) click:(UITapGestureRecognizer*)tapGest {
    
    UIView *view = tapGest.view;
    NSInteger index = view.tag;
    
    if (index < 0 || index >= self.mediaModel.items.count) return;
    WKSearchMediaItem *item = self.mediaModel.items[index];

    // 优先走 onClick 回调（上层可把点击行为改为跳转到聊天窗口），避免直接弹 WKImageBrowser。
    if (item.onClick) {
        item.onClick();
        return;
    }

    if (item.url.length == 0) return; // 防御：空 URL 不弹预览，避免 [NSURL URLWithString:nil] 崩溃
    NSURL *imageURL = [NSURL URLWithString:item.url];
    if (imageURL == nil) return;
    
    WKImageBrowser *imageBrowser = [[WKImageBrowser alloc] init];
    imageBrowser.toolViewHandlers = @[];
    imageBrowser.webImageMediator = [WKDefaultWebImageMediator new];
    
    YBIBImageData *data = [YBIBImageData new];
    data.imageURL = imageURL;
    
    imageBrowser.dataSourceArray = @[data];
    
    [imageBrowser showToView:[WKApp.shared findWindow]];
}

@end
