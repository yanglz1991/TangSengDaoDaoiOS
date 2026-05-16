//
//  QCGroupApprovalCell.m
//  WuKongGroupManager
//

#import "QCGroupApprovalCell.h"
#import <WuKongBase/WuKongBase.h>
#import "UIView+WK.h"
#import "QCConstant.h"
#import "QCApp.h"
#import "UIImageView+WK.h"

@implementation QCGroupApprovalModel

- (Class)cell {
    return QCGroupApprovalCell.class;
}

@end

@interface QCGroupApprovalCell ()

@property(nonatomic, strong) UIImageView *avatarImgView;
@property(nonatomic, strong) UILabel *nameLbl;
@property(nonatomic, strong) UILabel *timeLbl;
@property(nonatomic, strong) UILabel *statusLbl;
@property(nonatomic, strong) UILabel *contentLbl;
@property(nonatomic, strong) UILabel *remarkLbl;

@end

@implementation QCGroupApprovalCell

+ (CGSize)sizeForModel:(QCGroupApprovalModel *)model {
    CGFloat maxWidth = QCScreenWidth - 30.0f;
    CGFloat height = 12.0f + 40.0f; // top padding + avatar
    CGSize contentSize = CGSizeZero;
    if (model.content && model.content.length > 0) {
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:model.content attributes:@{NSFontAttributeName: [[QCApp shared].config appFontOfSize:14.0f]}];
        contentSize = [str boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
        height += 8.0f + contentSize.height;
    }
    if (model.remark && model.remark.length > 0) {
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:model.remark attributes:@{NSFontAttributeName: [[QCApp shared].config appFontOfSize:13.0f]}];
        CGSize remarkSize = [str boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
        height += 4.0f + remarkSize.height;
    }
    height += 12.0f; // bottom padding
    return CGSizeMake(QCScreenWidth, height);
}

- (void)setupUI {
    [super setupUI];

    self.avatarImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
    self.avatarImgView.layer.masksToBounds = YES;
    self.avatarImgView.layer.cornerRadius = 6.0f;
    [self addSubview:self.avatarImgView];

    self.nameLbl = [[UILabel alloc] init];
    self.nameLbl.font = [[QCApp shared].config appFontOfSizeMedium:16.0f];
    [self addSubview:self.nameLbl];

    self.timeLbl = [[UILabel alloc] init];
    self.timeLbl.font = [[QCApp shared].config appFontOfSize:12.0f];
    self.timeLbl.textColor = [UIColor grayColor];
    [self addSubview:self.timeLbl];

    self.statusLbl = [[UILabel alloc] init];
    self.statusLbl.font = [[QCApp shared].config appFontOfSize:14.0f];
    self.statusLbl.textColor = [QCApp shared].config.themeColor;
    self.statusLbl.text = LLang(@"待审批");
    [self addSubview:self.statusLbl];

    self.contentLbl = [[UILabel alloc] init];
    self.contentLbl.font = [[QCApp shared].config appFontOfSize:14.0f];
    self.contentLbl.numberOfLines = 0;
    [self addSubview:self.contentLbl];

    self.remarkLbl = [[UILabel alloc] init];
    self.remarkLbl.font = [[QCApp shared].config appFontOfSize:13.0f];
    self.remarkLbl.textColor = [UIColor grayColor];
    self.remarkLbl.numberOfLines = 0;
    [self addSubview:self.remarkLbl];
}

- (void)refresh:(QCGroupApprovalModel *)model {
    [super refresh:model];

    [self.nameLbl setTextColor:[QCApp shared].config.defaultTextColor];
    [self.contentLbl setTextColor:[QCApp shared].config.defaultTextColor];

    if (model.avatarURL && model.avatarURL.length > 0) {
        [self.avatarImgView lim_setImageWithURL:[NSURL URLWithString:model.avatarURL] placeholderImage:[QCApp shared].config.defaultAvatar];
    } else {
        [self.avatarImgView setImage:[QCApp shared].config.defaultAvatar];
    }
    self.nameLbl.text = model.inviterName ?: @"";
    self.timeLbl.text = model.createdAt ?: @"";
    self.contentLbl.text = model.content ?: @"";
    if (model.remark && model.remark.length > 0) {
        self.remarkLbl.hidden = NO;
        self.remarkLbl.text = [NSString stringWithFormat:@"\"%@\"", model.remark];
    } else {
        self.remarkLbl.hidden = YES;
        self.remarkLbl.text = @"";
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat leftPad = 15.0f;
    CGFloat rightPad = 15.0f;
    CGFloat topPad = 12.0f;

    self.avatarImgView.frame = CGRectMake(leftPad, topPad, 40.0f, 40.0f);

    [self.statusLbl sizeToFit];
    self.statusLbl.lim_left = self.lim_width - rightPad - self.statusLbl.lim_width;
    self.statusLbl.lim_top = topPad + 20.0f - self.statusLbl.lim_height / 2.0f;

    [self.nameLbl sizeToFit];
    self.nameLbl.lim_left = self.avatarImgView.lim_right + 10.0f;
    self.nameLbl.lim_top = topPad + 2.0f;

    [self.timeLbl sizeToFit];
    self.timeLbl.lim_left = self.avatarImgView.lim_right + 10.0f;
    self.timeLbl.lim_top = self.nameLbl.lim_bottom + 4.0f;

    CGFloat contentWidth = self.lim_width - leftPad - rightPad;
    self.contentLbl.frame = CGRectMake(leftPad, self.avatarImgView.lim_bottom + 8.0f, contentWidth, 0.0f);
    [self.contentLbl sizeToFit];
    self.contentLbl.lim_width = contentWidth;

    if (!self.remarkLbl.hidden) {
        self.remarkLbl.frame = CGRectMake(leftPad, self.contentLbl.lim_bottom + 4.0f, contentWidth, 0.0f);
        [self.remarkLbl sizeToFit];
        self.remarkLbl.lim_width = contentWidth;
    }
}

@end
