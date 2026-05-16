//
//  QCSearchMediaCell.m
//  QCCore
//
//  Created by tt on 2025/2/27.
//

#import "QCSearchMediaCell.h"

@implementation QCSearchMediaItem



@end

@implementation QCSearchMediaModel

- (Class)cell {
    return QCSearchMediaCell.class;
}

@end

@interface QCSearchMediaCell ()

@property(nonatomic,strong) NSMutableArray<UIView*> *itemViews;
@property(nonatomic,strong) QCSearchMediaModel *mediaModel;

@end

@implementation QCSearchMediaCell

+ (CGSize)sizeForModel:(QCSearchMediaModel *)model {
    CGFloat itemWidth = QCScreenWidth/model.numOfRow;
    return CGSizeMake(QCScreenWidth, itemWidth);
}

- (void)setupUI {
    [super setupUI];
    
    self.itemViews = [NSMutableArray array];
}

- (void)refresh:(QCSearchMediaModel *)model {
    [super refresh:model];
    self.mediaModel = model;
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSInteger i =0;
    for (QCSearchMediaItem *item in model.items) {
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

-(UIView*) itemView:(QCSearchMediaItem*)item index:(NSInteger)index{
    CGFloat itemWidth = self.lim_width/self.mediaModel.numOfRow;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, itemWidth, itemWidth)];
    
    if(item.type && [item.type isEqualToString:@"video"]) {
        // 优先使用 SmallVideo 模块提供的视频 view
        if([QCApp.shared hasMethod:QCPOINT_SEARCH_ITEM_VIDEO]) {
            UIView *videoView = [QCApp.shared invoke:QCPOINT_SEARCH_ITEM_VIDEO param:@{
                @"item": item,
            }];
            videoView.frame = view.frame;
            [view addSubview:videoView];
            return view;
        }
        // Fallback：本地自渲染（封面缩略图 + 中央播放三角图标 + 点击手势）
        UIImageView *coverView = [[UIImageView alloc] initWithFrame:view.bounds];
        if (item.url.length > 0) {
            [coverView sd_setImageWithURL:[NSURL URLWithString:item.url] placeholderImage:QCApp.shared.config.defaultPlaceholder];
        } else {
            coverView.image = QCApp.shared.config.defaultPlaceholder;
        }
        coverView.layer.masksToBounds = YES;
        coverView.clipsToBounds = YES;
        coverView.contentMode = UIViewContentModeScaleAspectFill;
        coverView.userInteractionEnabled = YES;
        coverView.tag = index;
        UITapGestureRecognizer *vtap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click:)];
        [coverView addGestureRecognizer:vtap];
        [view addSubview:coverView];

        // 中央播放图标：半透明黑色圆 + 白色三角
        CGFloat iconSize = MIN(itemWidth, 48.0f) * 0.5f;
        UIView *iconWrap = [[UIView alloc] initWithFrame:CGRectMake((itemWidth - iconSize)/2.0f,
                                                                     (itemWidth - iconSize)/2.0f,
                                                                     iconSize, iconSize)];
        iconWrap.userInteractionEnabled = NO;
        iconWrap.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.45f];
        iconWrap.layer.cornerRadius = iconSize / 2.0f;
        iconWrap.layer.masksToBounds = YES;

        CAShapeLayer *triangle = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPath];
        CGFloat tw = iconSize * 0.36f;     // 三角宽
        CGFloat th = iconSize * 0.42f;     // 三角高
        CGFloat ox = (iconSize - tw)/2.0f + iconSize * 0.05f; // 视觉上略偏右
        CGFloat oy = (iconSize - th)/2.0f;
        [path moveToPoint:CGPointMake(ox, oy)];
        [path addLineToPoint:CGPointMake(ox + tw, oy + th/2.0f)];
        [path addLineToPoint:CGPointMake(ox, oy + th)];
        [path closePath];
        triangle.path = path.CGPath;
        triangle.fillColor = [UIColor whiteColor].CGColor;
        [iconWrap.layer addSublayer:triangle];

        [view addSubview:iconWrap];
        return view;
    }
   
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:view.frame];
    if (item.url.length > 0) {
        [imgView sd_setImageWithURL:[NSURL URLWithString:item.url] placeholderImage:QCApp.shared.config.defaultPlaceholder];
    } else {
        imgView.image = QCApp.shared.config.defaultPlaceholder;
    }
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
    QCSearchMediaItem *item = self.mediaModel.items[index];

    // 优先走 onClick 回调（上层可把点击行为改为跳转到聊天窗口），避免直接弹 QCImageBrowser。
    if (item.onClick) {
        item.onClick();
        return;
    }

    if (item.url.length == 0) return; // 防御：空 URL 不弹预览，避免 [NSURL URLWithString:nil] 崩溃
    NSURL *imageURL = [NSURL URLWithString:item.url];
    if (imageURL == nil) return;
    
    QCImageBrowser *imageBrowser = [[QCImageBrowser alloc] init];
    imageBrowser.toolViewHandlers = @[];
    imageBrowser.webImageMediator = [QCDefaultWebImageMediator new];
    
    YBIBImageData *data = [YBIBImageData new];
    data.imageURL = imageURL;
    
    imageBrowser.dataSourceArray = @[data];
    
    [imageBrowser showToView:[QCApp.shared findWindow]];
}

@end
