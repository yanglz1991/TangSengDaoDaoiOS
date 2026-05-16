//
//  QCMergeForwardDetailCell.m
//  QCCore
//
//  Created by tt on 2020/10/12.
//

#import "QCMergeForwardDetailCell.h"
#import "QCApp.h"
#import "QCAvatarUtil.h"
#import "QCTimeTool.h"
#import <M80AttributedLabel/M80AttributedLabel.h>
#import "M80AttributedLabel+WK.h"
#import "UIImage+WK.h"
#import <YBImageBrowser/YBImageBrowser.h>
#import "QCDefaultWebImageMediator.h"
#import "QCBrowserToolbar.h"
#import "UIImageView+WK.h"

@interface QCMergeForwardDetailHeaderView ()


@property(nonatomic,strong) UIView *lineView1;
@property(nonatomic,strong) UILabel *titleLbl;
@property(nonatomic,strong) UIView *lineView2;
@end

@implementation QCMergeForwardDetailHeaderView

- (instancetype)initWithFrame:(CGRect)frame title:(NSString*)title
{
    self = [super initWithFrame:frame];
    if (self) {
//        [self setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:self.lineView1];
        [self addSubview:self.lineView2];
        [self addSubview:self.titleLbl];
        self.titleLbl.text = title;
        [self.titleLbl sizeToFit];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat leftSpace = 15.0f;
    CGFloat titleLeftSpace = 10.0f;
    
    self.lineView1.lim_centerY_parent = self;
    self.lineView1.lim_left = leftSpace;
    self.lineView1.lim_width = (self.lim_width - leftSpace*2 - self.titleLbl.lim_width - titleLeftSpace*2)/2.0f;
    
    self.titleLbl.lim_centerY_parent = self;
    self.titleLbl.lim_left = self.lineView1.lim_right + titleLeftSpace;
    
    self.lineView2.lim_centerY_parent = self;
    self.lineView2.lim_left = self.titleLbl.lim_right + titleLeftSpace;
    self.lineView2.lim_width = self.lineView1.lim_width;
    
    if([QCApp shared].config.style == QCSystemStyleDark) {
        self.lineView1.backgroundColor = [QCApp shared].config.cellBackgroundColor;
        self.lineView2.backgroundColor = [QCApp shared].config.cellBackgroundColor;
    }else{
        self.lineView1.backgroundColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
        self.lineView2.backgroundColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
    }
    
}

- (UIView *)lineView1 {
    if(!_lineView1) {
        _lineView1 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.5f)];
    }
    return _lineView1;
}

- (UILabel *)titleLbl {
    if(!_titleLbl) {
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.font = [[QCApp shared].config appFontOfSize:12.0f];
        _titleLbl.textColor = [QCApp shared].config.tipColor;
    }
    return _titleLbl;
}

- (UIView *)lineView2 {
    if(!_lineView2) {
        _lineView2 =  [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 1.0f)];
    }
    return _lineView2;
}

@end

@implementation QCMergeForwardDetailModel

+ (instancetype)message:(QCMessage *)message {
    QCMergeForwardDetailModel *model = QCMergeForwardDetailModel.new;
    model.message = message;
    return model;
}

- (Class)cell {
    return QCMergeForwardDetailCell.class;
}


@end

@interface QCMergeForwardDetailCell ()

@property(nonatomic,strong) UIImageView *avatarImgView; // 头像
@property(nonatomic,strong) UILabel *nameLbl; // 名字
@property(nonatomic,strong) UILabel *timeLbl; // 时间





@end

#define avatarTop 15.0f
#define namelHeight 17.0f
#define contentTop 8.0f

#define minContentHeight 80.0f - avatarTop - namelHeight - contentTop - 10.0f

#define contentMaxWidth QCScreenWidth - 15.0f*2 - [QCApp shared].config.messageAvatarSize.width

@implementation QCMergeForwardDetailCell


+ (CGSize)sizeForModel:(QCFormItemModel *)model {
    CGFloat contentHeight = [self contentHeightForModel:model maxWidth:contentMaxWidth];
    if(contentHeight<minContentHeight) {
        contentHeight = minContentHeight;
    }
    return CGSizeMake(QCScreenWidth, avatarTop + namelHeight + contentTop + 10.0f + contentHeight);
}

+(CGFloat) contentHeightForModel:(QCFormItemModel*)model maxWidth:(CGFloat)maxWidth {
    return 0.0f;
}

- (void)setupUI {
    [super setupUI];
    [self.contentView addSubview:self.avatarImgView];
    [self.contentView addSubview:self.nameLbl];
    [self.contentView addSubview:self.timeLbl];
    [self.contentView addSubview:self.messageContentView];
    
    self.bottomLineView.hidden = NO;
    
}

- (void)refresh:(QCMergeForwardDetailModel *)model {
    [super refresh:model];
    self.model = model;
    
    self.avatarImgView.hidden = model.hideAvatar;
    
    [self.avatarImgView lim_setImageWithURL:[NSURL URLWithString:[QCAvatarUtil getAvatar:model.message.fromUid]] placeholderImage:[QCApp shared].config.defaultAvatar];
    if(model.message.from) {
        self.nameLbl.text = model.message.from.displayName;
    }else{
        [[QCSDK shared].channelManager fetchChannelInfo:[[QCChannel alloc] initWith:model.message.fromUid channelType:WK_PERSON]];
    }
    
    self.timeLbl.text = [QCTimeTool getTimeStringAutoShort2:[NSDate dateWithTimeIntervalSince1970:model.message.timestamp] mustIncludeTime:YES];
    [self.timeLbl sizeToFit];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat leftSpace = 15.0f;
    
    self.avatarImgView.lim_top = 15.0f;
    self.avatarImgView.lim_left = leftSpace;
    
    self.timeLbl.lim_left = self.lim_width - self.timeLbl.lim_width - leftSpace;
    self.timeLbl.lim_top = self.avatarImgView.lim_top + 2.0f;
    
    self.nameLbl.lim_top = self.avatarImgView.lim_top+2.0f;
    self.nameLbl.lim_height = 17.0f;
    self.nameLbl.lim_width = self.lim_width - self.avatarImgView.lim_right - 5.0f - self.timeLbl.lim_width - leftSpace;
    self.nameLbl.lim_left = self.avatarImgView.lim_right + 5.0f;
    
    self.messageContentView.lim_top = self.nameLbl.lim_bottom + contentTop;
    self.messageContentView.lim_left = self.nameLbl.lim_left;
    self.messageContentView.lim_width = contentMaxWidth;
    
    if([[self class] contentHeightForModel:self.model maxWidth:self.messageContentView.lim_width]<minContentHeight) {
        self.messageContentView.lim_height = minContentHeight;
    }else{
        self.messageContentView.lim_height = [[self class] contentHeightForModel:self.model maxWidth:contentMaxWidth];
    }
    
}

- (UIImageView *)avatarImgView {
    if(!_avatarImgView) {
        _avatarImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [QCApp shared].config.messageAvatarSize.width, [QCApp shared].config.messageAvatarSize.height)];
        _avatarImgView.layer.masksToBounds = YES;
        _avatarImgView.layer.cornerRadius = _avatarImgView.lim_height/2.0f;
    }
    return _avatarImgView;
}

- (UILabel *)nameLbl {
    if(!_nameLbl) {
        _nameLbl = [[UILabel alloc] init];
        _nameLbl.font = [[QCApp shared].config appFontOfSize:15.0f];
        _nameLbl.textColor = [UIColor grayColor];
    }
    return _nameLbl;
}

- (UILabel *)timeLbl {
    if(!_timeLbl) {
        _timeLbl = [[UILabel alloc] init];
        _timeLbl.font =  [[QCApp shared].config appFontOfSize:12.0f];
        _timeLbl.textColor = [QCApp shared].config.tipColor;
    }
    return _timeLbl;
}

- (UIView *)messageContentView {
    if (!_messageContentView) {
        _messageContentView = [UIView new];
        [_messageContentView setBackgroundColor:[UIColor clearColor]];
    }
    return _messageContentView;
}

@end


// ########## 文本cell ##########

@implementation QCMergeForwardDetailTextModel

- (Class)cell {
    return QCMergeForwardDetailTextCell.class;
}

@end

@interface QCMergeForwardDetailTextCell ()

@property(nonatomic,strong) M80AttributedLabel *textLbl;

@end

@implementation QCMergeForwardDetailTextCell

+ (CGFloat)contentHeightForModel:(QCMergeForwardDetailTextModel *)model maxWidth:(CGFloat)maxWidth{
    CGSize size = [self getTextLabelSize:model.message maxWidth:maxWidth];
    return size.height;
}

- (void)setupUI {
    [super setupUI];
    
    [self.messageContentView addSubview:self.textLbl];
    
    self.messageContentView.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    
    [self.messageContentView addGestureRecognizer:longPressGesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidHide) name:UIMenuControllerDidHideMenuNotification object:nil];
}

-(void) menuDidHide {
    [self.textLbl setBackgroundColor:[UIColor clearColor]];
}

- (void)refresh:(QCMergeForwardDetailTextModel *)model {
    [super refresh:model];
    
    QCTextContent *textContent = (QCTextContent*)[model.message content];
    
    [self.textLbl lim_setText:textContent.content mentionInfo:textContent.mentionedInfo];
    
    [self.textLbl setBackgroundColor:[UIColor clearColor]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize textLabelSize = [[self class] getTextLabelSize:self.model.message maxWidth:contentMaxWidth];
    
    self.textLbl.lim_width = textLabelSize.width;
    self.textLbl.lim_height = textLabelSize.height;
}


- (M80AttributedLabel *)textLbl {
    if(!_textLbl) {
        _textLbl = [[M80AttributedLabel alloc] init];
        _textLbl.underLineForLink = false;
//        _textLbl.delegate = self;
        [_textLbl setFont:[UIFont systemFontOfSize:[QCApp shared].config.messageTextFontSize]];
        [_textLbl setBackgroundColor:[UIColor clearColor]];
        [_textLbl setTextColor:[QCApp shared].config.defaultTextColor];
        _textLbl.numberOfLines = 0;
        _textLbl.lineBreakMode = kCTLineBreakByWordWrapping;
        
    }
    return _textLbl;
}

-(void) handleLongPressGesture:(UILongPressGestureRecognizer *)longPressGR {
    if (longPressGR.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        UIMenuItem *copyLink = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(customcopy:)];
        [[UIMenuController sharedMenuController]  setMenuItems:@[copyLink]];
        [[UIMenuController sharedMenuController] setTargetRect:self.textLbl.frame inView:self.textLbl.superview];
        [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
        self.textLbl.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.2f];
    }else {
        
    }
}


+ (CGSize)getTextLabelSize:(QCMessage *)message maxWidth:(CGFloat)maxWidth {
    static QCMemoryCache *memoryCache;
    static NSLock *memoryLock;
    if(!memoryLock) {
        memoryLock = [[NSLock alloc] init];
    }
    if(!memoryCache) {
        memoryCache = [[QCMemoryCache alloc] init];
        memoryCache.maxCacheNum = 500;
    }
   NSString *cacheKey = [NSString stringWithFormat:@"%llu",message.messageId];
    [memoryLock lock];
   NSString *cacheSizeStr =   [memoryCache getCache:cacheKey];
    [memoryLock unlock];
    if(cacheSizeStr) {
        return CGSizeFromString(cacheSizeStr);
    }
    static M80AttributedLabel *textLbl;
    if(!textLbl) {
        textLbl = [[M80AttributedLabel alloc] init];
        [textLbl setFont:[UIFont systemFontOfSize:[QCApp shared].config.messageTextFontSize]];
    }
    [textLbl lim_setText:((QCTextContent*)message.content).content];
    
    CGSize textSize = [textLbl sizeThatFits:CGSizeMake(maxWidth, CGFLOAT_MAX)];
    if(message.messageId !=0 ) {
         [memoryLock lock];
        [memoryCache setCache:NSStringFromCGSize(textSize) forKey:cacheKey];
         [memoryLock unlock];
    }
    return textSize;
}



#pragma mark - UIMenuController

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
//    // 自定义响应UIMenuItem Action，例如你可以过滤掉多余的系统自带功能（剪切，选择等），只保留复制功能。
    return (action == @selector(customcopy:));
}

- (void)customcopy:(id)sender
{
    [[UIPasteboard generalPasteboard] setString:self.textLbl.text];
}

@end


//----------图片cell ----------

@implementation QCMergeForwardDetailImageModel


- (Class)cell {
    return QCMergeForwardDetailImageCell.class;
}

@end


@interface QCMergeForwardDetailImageCell ()

@property(nonatomic,strong) UIImageView *messageImgView;

@end

@implementation QCMergeForwardDetailImageCell

+ (CGFloat)contentHeightForModel:(QCMergeForwardDetailImageModel *)model maxWidth:(CGFloat)maxWidth{
    QCImageContent *imageContent = (QCImageContent*)model.message.content;
    return [UIImage lim_sizeWithImageOriginSize:CGSizeMake(imageContent.width, imageContent.height) maxLength:maxWidth].height;
}

- (void)setupUI {
    [super setupUI];
    [self.messageContentView addSubview:self.messageImgView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
    self.messageImgView.userInteractionEnabled = YES;
    [self.messageImgView addGestureRecognizer:tap];
    
    
}

- (void)refresh:(QCMergeForwardDetailImageModel *)model {
    [super refresh:model];
    QCImageContent *imageContent = (QCImageContent*)model.message.content;
    
    NSURL *url = [[QCApp shared] getImageFullUrl:imageContent.remoteUrl];
    [self.messageImgView lim_setImageWithURL:url placeholderImage:[QCApp shared].config.defaultPlaceholder];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    QCImageContent *imageContent = (QCImageContent*)self.model.message.content;
    CGSize size =[UIImage lim_sizeWithImageOriginSize:CGSizeMake(imageContent.width, imageContent.height) maxLength:contentMaxWidth];
    
    self.messageImgView.lim_size = size;
}

-(void) onTap {
    
    QCImageContent *imageContent = (QCImageContent*)self.model.message.content;
    
    YBIBImageData *data = [YBIBImageData new];
    data.imageURL = [[QCApp shared] getImageFullUrl:imageContent.remoteUrl];
    data.projectiveView = self.messageImgView;
    
    YBImageBrowser *imageBrowser = [[YBImageBrowser alloc] init];
    imageBrowser.webImageMediator = [QCDefaultWebImageMediator new];
    imageBrowser.toolViewHandlers = @[QCBrowserToolbar.new];
    
    imageBrowser.dataSourceArray = @[data];
    [imageBrowser show];
   
    
    
}


- (UIImageView *)messageImgView {
    if(!_messageImgView) {
        _messageImgView = [[UIImageView alloc] init];
        _messageImgView.layer.masksToBounds = YES;
        _messageImgView.layer.cornerRadius = 4.0f;
    }
    return _messageImgView;
}


@end

//----------其他cell ----------

@implementation QCMergeForwardDetailOtherModel


- (Class)cell {
    return QCMergeForwardDetailOtherCell.class;
}
@end

@interface QCMergeForwardDetailOtherCell ()

@property(nonatomic,strong) UILabel *textLbl;

@end

@implementation QCMergeForwardDetailOtherCell


+ (CGFloat)contentHeightForModel:(QCMergeForwardDetailTextModel *)model maxWidth:(CGFloat)maxWidth{
    NSString *conversationDigest = [model.message.content conversationDigest];
    CGSize size = [self getTextSize:conversationDigest maxWidth:maxWidth fontSize:[QCApp shared].config.messageTextFontSize];
    return size.height;
}

- (void)setupUI {
    [super setupUI];
    
    [self.messageContentView addSubview:self.textLbl];
}

- (void)refresh:(QCMergeForwardDetailTextModel *)model {
    [super refresh:model];
    
    NSString *conversationDigest = [model.message.content conversationDigest];
    if(conversationDigest && ![conversationDigest isEqualToString:@""]) {
        self.textLbl.text = conversationDigest;
    }else{
        self.textLbl.text = @"[未知消息]";
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textLbl.lim_top = 0.0f;
    self.textLbl.lim_size = self.messageContentView.lim_size;
}


- (UILabel *)textLbl {
    if(!_textLbl) {
        _textLbl = [[UILabel alloc] init];
//        _textLbl.delegate = self;
        [_textLbl setFont:[UIFont systemFontOfSize:[QCApp shared].config.messageTextFontSize]];
        _textLbl.numberOfLines = 0;
        _textLbl.lineBreakMode = NSLineBreakByWordWrapping;
//        _textLbl.backgroundColor = [UIColor redColor];
    //    [self.textLbl setTextColor:[QCApp shared].config.defaultTextColor];
    }
    return _textLbl;
}

+ (CGSize) getTextSize:(NSString*) text maxWidth:(CGFloat)maxWidth fontSize:(CGFloat)fontSize{
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineBreakMode = NSLineBreakByWordWrapping;
    style.alignment = NSTextAlignmentCenter;
    NSAttributedString *string = [[NSAttributedString alloc]initWithString:text attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize], NSParagraphStyleAttributeName:style}];
    CGSize size =  [string boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    return size;
}


@end
