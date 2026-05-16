//
//  QCCardCell.m
//  WuKongBase
//
//  Created by tt on 2020/5/5.
//

#import "QCCardCell.h"
#import "QCResource.h"
#import "QCCardContent.h"
#import "QCAvatarUtil.h"

#define QCCardTopContainerHeight 68.0f
#define QCCardBottomContainerHeight 20.0f

@interface QCCardCell ()
@property(nonatomic,strong) UIView *cardTopContainer;
@property(nonatomic,strong) UIView *cardBottomContainer;
@property(nonatomic,strong) UIImageView *recommendAvatarImgView;
@property(nonatomic,strong) UILabel *recommendNameLbl;
@property(nonatomic,strong) UILabel *flagLbl;
@property(nonatomic,strong) UIView *lineView;
@end

@implementation QCCardCell

+ (CGSize)contentSizeForMessage:(QCMessageModel *)model {
    return CGSizeMake(250.0f,QCCardTopContainerHeight+QCCardBottomContainerHeight);
}



- (void)initUI {
    [super initUI];
    

    self.messageContentView.layer.masksToBounds = YES;
    self.messageContentView.layer.cornerRadius = 4.0f;
    
    self.cardTopContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, QCCardTopContainerHeight)];
    self.cardTopContainer.userInteractionEnabled = NO; // 设为NO 让事件传递下去
    [self.messageContentView addSubview:self.cardTopContainer];
    
    self.cardBottomContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, QCCardBottomContainerHeight)];
    self.cardBottomContainer.userInteractionEnabled = NO;
    [self.messageContentView addSubview:self.cardBottomContainer];
    
    self.recommendAvatarImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 48.0f, 48.0f)];
    self.recommendAvatarImgView.layer.masksToBounds = YES;
    self.recommendAvatarImgView.layer.cornerRadius = 2.0f;
    [self.cardTopContainer addSubview:self.recommendAvatarImgView];
    
    self.recommendNameLbl = [[UILabel alloc] init];
    [self.cardTopContainer addSubview:self.recommendNameLbl];
    
    self.flagLbl = [[UILabel alloc] init];
    self.flagLbl.text = LLang(@"个人名片");
    [self.flagLbl setFont:[UIFont systemFontOfSize:10.0f]];
    [self.flagLbl setTextColor:[UIColor grayColor]];
    [self.flagLbl sizeToFit];
    [self.cardBottomContainer addSubview:self.flagLbl];
    
    self.lineView = [[UIView alloc] init];
    self.lineView.lim_height = 0.5f;
    [self.cardBottomContainer addSubview:self.lineView];
    
}

- (void)refresh:(QCMessageModel *)model {
    [super refresh:model];
    if([QCApp shared].config.style != QCSystemStyleDark) {
        self.trailingView.timeLbl.textColor = [QCApp shared].config.tipColor;
        self.trailingView.statusImgView.tintColor = [QCApp shared].config.tipColor;
    }
    QCCardContent *content = (QCCardContent*)model.content;
    
    if(!content.avatar || [content.avatar isEqualToString:@""]) { // 头像
         [self.recommendAvatarImgView lim_setImageWithURL:[NSURL URLWithString:[QCAvatarUtil getAvatar:content.uid]]];
    } else {
        [self.recommendAvatarImgView lim_setImageWithURL:[NSURL URLWithString:[QCAvatarUtil getFullAvatarWIthPath:content.avatar]]];
    }
   
    self.recommendNameLbl.text = content.name;
    
    [self.messageContentView setBackgroundColor:[QCApp shared].config.cellBackgroundColor];
    if([QCApp shared].config.style == QCSystemStyleDark) {
        [self.lineView setBackgroundColor:[UIColor colorWithRed:16.0f/255.0f green:16.0f/255.0f blue:16.0f/255.0f alpha:1.0f]];
    }else{
        [self.lineView setBackgroundColor:[UIColor colorWithRed:250.0f/255.0f green:250.0f/255.0f blue:250.0f/255.0f alpha:1.0]];
    }
    
    self.recommendNameLbl.textColor = [QCApp shared].config.messageRecvTextColor;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.cardTopContainer.lim_width = self.messageContentView.lim_width;
    
    self.cardBottomContainer.lim_width = self.messageContentView.lim_width;
    self.cardBottomContainer.lim_top = self.cardTopContainer.lim_bottom;
    
    self.recommendAvatarImgView.lim_top = self.cardTopContainer.lim_height/2.0f - self.recommendAvatarImgView.lim_height/2.0f;
    self.recommendAvatarImgView.lim_left = 10.0f;
    
    CGFloat nameLeftSpace = 10.0f;
    CGFloat nameRightSpace = 10.0f;
    self.recommendNameLbl.lim_height = 20.0f;
    self.recommendNameLbl.lim_top = self.cardTopContainer.lim_height/2.0f - self.recommendNameLbl.lim_height/2.0f;
    self.recommendNameLbl.lim_left = self.recommendAvatarImgView.lim_right + nameLeftSpace;
    self.recommendNameLbl.lim_width = self.messageContentView.lim_width - self.recommendAvatarImgView.lim_right - nameLeftSpace - nameRightSpace;

    
    self.lineView.lim_top = 0.0f;
    self.lineView.lim_left = self.recommendAvatarImgView.lim_left;
    self.lineView.lim_width = self.messageContentView.lim_width - 20.0f;
    
    self.flagLbl.lim_top = self.lineView.lim_bottom + 4.0f;
    self.flagLbl.lim_left = self.lineView.lim_left;
    
}


- (BOOL)respondContentSingleTap {
    return true;
}


- (void)onTap {
    [super onTap];
    if(!self.messageModel) {
        return;
    }
    QCCardContent *content = (QCCardContent*)self.messageModel.content;
    [[QCApp shared] invoke:QCPOINT_USER_INFO param:@{
        @"channel":self.messageModel.channel,
        @"uid": content.uid?:@"",
        @"vercode": content.vercode?:@"",
    }];
}

-(UIImage*) imageName:(NSString*)name {
    return [QCApp.shared loadImage:name moduleID:@"WuKongBase"];
//    return [[QCResource shared] resourceForImage:name podName:@"WuKongBase_images"];
}


+(BOOL) hiddenBubble {
    return YES;
}
@end
