//
//  QCBrowserToolbar.m
//  WuKongBase
//
//  Created by tt on 2021/3/24.
//

#import "QCBrowserToolbar.h"
#import "QCResource.h"
#import "UIView+WK.h"
#import "QCConstant.h"
#import "QCActionSheetView2.h"
#import "WuKongBase.h"
#import "QCVideoData.h"

@interface QCBrowserToolbar ()

@property (nonatomic, strong) UIButton *moreButton;

@end

@implementation QCBrowserToolbar

@synthesize yb_containerView = _yb_containerView;
@synthesize yb_currentData = _yb_currentData;
@synthesize yb_containerSize = _yb_containerSize;
@synthesize yb_currentOrientation = _yb_currentOrientation;

- (void)yb_containerViewIsReadied {
    [self.yb_containerView addSubview:self.moreButton];
    
    CGFloat topSafe = 0.0f;
    if (@available(iOS 11.0, *)) {
         topSafe = [UIApplication sharedApplication].keyWindow.safeAreaInsets.top;
        
    }
    self.moreButton.lim_top = topSafe + 20.0f;
    self.moreButton.lim_left = QCScreenWidth - self.moreButton.lim_width - 20.0f;
}

- (void)yb_hide:(BOOL)hide {
    self.moreButton.hidden = hide;
}

- (UIButton *)moreButton {
    if(!_moreButton) {
        _moreButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 44.0f, 44.0f)];
        [_moreButton setImage:[self getImageWithName:@"Common/Index/More"] forState:UIControlStateNormal];
        [_moreButton addTarget:self action:@selector(moreBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreButton;
}

-(void) moreBtnPressed {
    __weak typeof(self) weakSelf = self;
    
    
    QCMessageModel *message;
    QCMessageContent *messageContent;
    id<YBIBDataProtocol> currentData = self.yb_currentData();
    if([currentData isKindOfClass:[QCVideoData class]]) {
        QCVideoData *videoData = (QCVideoData*)currentData;
        if(videoData.extraData) {
            message = videoData.extraData[@"message"];
            if(videoData.extraData[@"messageContent"]) {
                messageContent = videoData.extraData[@"messageContent"];
            }
        }
    }else if([currentData isKindOfClass:[YBIBImageData class]]) {
        YBIBImageData *imageData = (YBIBImageData*)currentData;
        if(imageData.extraData) {
            message = imageData.extraData[@"message"];
            if(imageData.extraData[@"messageContent"]) {
                messageContent = imageData.extraData[@"messageContent"];
            }
        }
    }
        
    
    QCActionSheetView2 *sheetView = [QCActionSheetView2 initWithTip:nil];
    [sheetView addItem:[QCActionSheetButtonItem2 initWithTitle:LLang(@"保存到相册") onClick:^{
        [weakSelf saveDataToAlbum];
    }]];
    if(message) {
        [sheetView addItem:[QCActionSheetButtonItem2 initWithTitle:LLang(@"转发") onClick:^{
            if(weakSelf.browser) {
                [weakSelf.browser hide];
            }
            [[QCMessageActionManager shared] forwardMessages:@[message.message]];
        }]];
    }else if(messageContent) {
        [sheetView addItem:[QCActionSheetButtonItem2 initWithTitle:LLang(@"转发") onClick:^{
            if(weakSelf.browser) {
                [weakSelf.browser hide];
            }
            [[QCMessageActionManager shared] forwardContent:messageContent complete:nil];
        }]];
    }
    
    [sheetView show];
}

-(void) saveDataToAlbum {
   id<YBIBDataProtocol> dataProtocol = self.yb_currentData();
    if(dataProtocol && dataProtocol.yb_allowSaveToPhotoAlbum) {
        [dataProtocol yb_saveToPhotoAlbum];
    }
}


-(UIImage*) getImageWithName:(NSString*)name {
    return [QCApp.shared loadImage:name moduleID:@"WuKongBase"];
//    return [[QCResource shared] resourceForImage:name podName:@"WuKongBase_images"];
}
@end
