//
//  QCTrailingView.m
//  QCCore
//
//  Created by tt on 2021/9/17.
//

#import "QCTrailingView.h"
#import "QCResource.h"
#import "QCMessageCell.h"
#import "QCTimeTool.h"
#import "QCApp.h"
@interface QCTrailingView ()

@property(nonatomic,strong) QCMessageModel *messageModel;

@end

@implementation QCTrailingView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

-(void) setupUI {
    
    [self addSubview:self.trailingContentView];
    [self.trailingContentView addSubview:self.securityLockImgView];
    [self.trailingContentView addSubview:self.pinnedImgView];
    [self.trailingContentView addSubview:self.editTipLbl];
    [self.trailingContentView addSubview:self.timeLbl];
    [self.trailingContentView addSubview:self.statusImgView];
    
}

-(void) updateStatus:(QCMessageModel*) messageModel {
    if([self needLoading:messageModel]) {
        self.statusImgView.image = [self getImageNameForBaseModule:@"Conversation/Messages/TimeWait"];
        self.statusImgView.image = [self.statusImgView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }else if(messageModel.isSend && messageModel.status == WK_MESSAGE_SUCCESS) {
        // 已读双勾仅在私聊显示，群聊不开启该功能
        BOOL canShowReceipt = messageModel.channel.channelType == WK_PERSON;
        if(canShowReceipt && messageModel.message.remoteExtra.readedCount>0) {
            self.statusImgView.image = [self getImageNameForBaseModule:@"Conversation/Messages/DoubleCheckmark"];
            self.statusImgView.image = [self.statusImgView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }else{
            self.statusImgView.image = [self getImageNameForBaseModule:@"Conversation/Messages/Checkmark"];
            self.statusImgView.image = [self.statusImgView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
    }
    self.statusImgView.tintColor =  [UIColor whiteColor];
    
}

-(void) refresh:(QCMessageModel*)messageModel {
    
    self.messageModel = messageModel;
    
    self.securityLockImgView.hidden = YES;
    self.pinnedImgView.hidden = !messageModel.remoteExtra.isPinned;
    
    self.editTipLbl.hidden = !messageModel.remoteExtra.isEdit;
    [self.editTipLbl sizeToFit];
    
    if(messageModel.isSend) {
        [self updateStatus:messageModel];
    }
    
    self.statusImgView.hidden = YES;
    if([messageModel isSend]) {
        self.statusImgView.hidden = NO;
    }
    if([messageModel isSend] || [QCApp shared].config.style == QCSystemStyleDark) {
        [self setElementColor:[QCApp shared].config.messageTipColor];
    }else {
        [self setElementColor:[QCApp shared].config.tipColor];
    }
   
    if(self.messageModel.remoteExtra.isEdit) {
        self.timeLbl.text = messageModel.editedAtStr;
    }else{
        self.timeLbl.text = messageModel.timeStr;
    }
    
    [self.timeLbl sizeToFit];
    
    
    [self layoutSubviews];
}

-(void) setElementColor:(UIColor*)color {
    self.statusImgView.tintColor =  color;
    self.timeLbl.textColor = color;
    self.securityLockImgView.tintColor = color;
    self.editTipLbl.textColor = color;
    
    self.pinnedImgView.tintColor = color;
}


+(CGSize) size:(QCMessageModel*)model {
    
    NSString *timeStr = model.timeStr;
    if(model.remoteExtra.isEdit) {
        timeStr = model.editedAtStr;
    }
    
    CGFloat timeWidth = [self  getWidthWithText:timeStr height:QCTimeHeight font:QCTimeFontSize];
    
    CGFloat trailingWidth = QCPinnedIconSize.width + QCSecurityLockSize.width + QCSecurityLockRight + timeWidth + QCStatusLeft + QCStatusSize.width;
    CGFloat trailingHeight = QCTimeHeight;
    
    bool hasStatus = false; // 是否有状态icon
    bool hasSecurityLock = false;
    if(!model.remoteExtra.isPinned) {
        trailingWidth -= QCPinnedIconSize.width;
    }
    if(model.isSend) {
        hasStatus = true;
    }
    hasSecurityLock  = false;
    
    if(!hasStatus) {
        trailingWidth-=QCStatusSize.width;
    }
    if(!hasSecurityLock) {
        trailingWidth -= (QCSecurityLockSize.width + QCSecurityLockRight);
    }
    if(model.remoteExtra.isEdit) {
        CGFloat editTipWidth =  [self getWidthWithText:[self editTip] height:QCEditTipHeight font:QCEditTipFontSize];
        trailingWidth += editTipWidth + QCTimeLeftSpace;
    }

   
    return CGSizeMake(trailingWidth, trailingHeight);
}

-(void) layoutSubviews {
    [super layoutSubviews];
    
    [self layoutTrailingView];
   
    if(self.tailWrap) {
        [self layoutTailWrap];
    }else {
        self.trailingContentView.lim_left = self.lim_width - self.trailingContentView.lim_width;
        self.trailingContentView.lim_top = self.lim_height - self.trailingContentView.lim_height;
    }
}

-(void) layoutTrailingView {
  
    self.trailingContentView.lim_size = [[self class] size:self.messageModel];
    
    UIView *preview;
    for (UIView *subview in self.trailingContentView.subviews) {
        if(subview.hidden) {
            continue;
        }
        subview.lim_centerY_parent = self.trailingContentView;
        if(preview) {
            subview.lim_left = preview.lim_right + QCTimeLeftSpace;
        }else {
            subview.lim_left = 0.0f;
        }
        preview = subview;
        
    }

//    self.trailingContentView.lim_size = [[self class] size:self.messageModel];
//    
//    // pinned
//    self.pinnedImgView.lim_left = 0.0f;
//    self.pinnedImgView.lim_centerY_parent = self.trailingContentView;
//    if(self.pinnedImgView.hidden) {
//        self.editTipLbl.lim_left = 0.0f;
//    }else {
//        self.editTipLbl.lim_left = self.pinnedImgView.lim_right + QCTimeLeftSpace;
//    }
//    
//
//    if(self.editTipLbl.hidden) {
//        self.securityLockImgView.lim_left = 0.0f;
//    }else {
//        self.securityLockImgView.lim_left = self.editTipLbl.lim_right;
//    }
//   
//    self.securityLockImgView.lim_centerY_parent = self.trailingContentView;
//    self.editTipLbl.lim_centerY_parent = self.trailingContentView;
//    self.editTipLbl.lim_top += 1.0f;
//    
//    
//    if(self.securityLockImgView.hidden) {
//        self.timeLbl.lim_left = 0.0f;
//    }else{
//        self.timeLbl.lim_left = self.securityLockImgView.lim_right + QCSecurityLockRight;
//    }
//    if(!self.editTipLbl.hidden) {
//        self.timeLbl.lim_left = self.editTipLbl.lim_right + QCTimeLeftSpace;
//    }
//   
//    self.timeLbl.lim_top = self.trailingContentView.lim_height/2.0f - self.timeLbl.lim_height/2.0f;
//    
//    self.statusImgView.lim_left = self.timeLbl.lim_right + QCStatusLeft;
//    self.statusImgView.lim_top = self.trailingContentView.lim_height/2.0f -  self.statusImgView.lim_height/2.0f;
    
}


-(void) layoutTailWrap {

    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = self.lim_height/2.0f;
    self.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.2f];
//
//
    
    [self setElementColor:[UIColor whiteColor]];
    self.trailingContentView.lim_centerX_parent = self;
    self.trailingContentView.lim_centerY_parent = self;
    
}
-(BOOL) needLoading:(QCMessageModel*)model {
    if(!model.isSend) {
        return false;
    }
    if(model.remoteExtra.isEdit && model.remoteExtra.uploadStatus != QCContentEditUploadStatusSuccess) { // 正文被编辑，状态改变
        return true;
    }
    
    if((model.status == WK_MESSAGE_WAITSEND || model.status == WK_MESSAGE_UPLOADING)) {
        return true;
    }
    return false;
}


- (UIImageView *)statusImgView {
    if(!_statusImgView) {
        _statusImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, QCStatusSize.width, QCStatusSize.height)];
    }
    return _statusImgView;
}

- (UILabel *)editTipLbl {
    if(!_editTipLbl) {
        _editTipLbl = [[UILabel alloc] init];
        _editTipLbl.text = [[self class] editTip];
        _editTipLbl.font = [UIFont italicSystemFontOfSize:QCEditTipFontSize];
        _editTipLbl.lim_height = QCEditTipHeight;
//        [_editTipLbl sizeToFit];
    }
    return _editTipLbl;
}

+(NSString*) editTip {
    return LLang(@"已编辑");
}

- (UIView *)trailingContentView {
    if(!_trailingContentView) {
        _trailingContentView = [[UIView alloc] init];
    }
    return _trailingContentView;
}

- (UIImageView *)securityLockImgView {
    if(!_securityLockImgView) {
        _securityLockImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, QCSecurityLockSize.width, QCSecurityLockSize.height)];
        UIImage *img = [self getImageNameForBaseModule:@"Conversation/Messages/SecurityLock"];
        _securityLockImgView.image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    return _securityLockImgView;
}


- (UILabel *)timeLbl {
    if(!_timeLbl) {
        _timeLbl = [[UILabel alloc] init];
        _timeLbl.lim_height =  QCTimeHeight;
        _timeLbl.font = [[QCApp shared].config appFontOfSize:QCTimeFontSize];
    }
    return _timeLbl;
}

- (UIImageView *)pinnedImgView {
    if(!_pinnedImgView) {
        _pinnedImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, QCPinnedIconSize.width, QCPinnedIconSize.height)];
        UIImage *img = [self getImageNameForBaseModule:@"Conversation/Messages/Pinned"];
        _pinnedImgView.image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    return _pinnedImgView;
}

+(CGFloat)getWidthWithText:(NSString*)text height:(CGFloat)height font:(CGFloat)font{
    CGRect rect = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:font]} context:nil];
    return rect.size.width;
    
}


-(UIImage*) getImageNameForBaseModule:(NSString*)name {
    return [QCApp.shared loadImage:name moduleID:@"QCCore"];
//    return [[QCResource shared] resourceForImage:name podName:@"QCCore_images"];
}
@end
