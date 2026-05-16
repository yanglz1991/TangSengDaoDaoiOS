//
//  QCPanelFileFuncItem.m
//  QCFile
//
//  Created by tt on 2022/5/4.
//

#import "QCPanelFileFuncItem.h"
#import "QCFileChooseUtil.h"
#import "QCFileContent.h"
@implementation QCPanelFileFuncItem

- (NSString *)sid {
    return @"apm.qx.file";
}


- (UIImage *)itemIcon {
    return [self imageName:@"Conversation/Toolbar/FileNormal"];
}

- (void)onPressed:(UIButton *)btn {
    id<QCConversationContext> context = self.inputPanel.conversationContext;
    __weak typeof(context) weakContext = context;
    [[QCFileChooseUtil shared] chooseFile:^(NSString * _Nonnull fileName, NSData * _Nonnull fileData) {
        btn.selected = false;
        [weakContext sendMessage:[QCFileContent initWithFileName:fileName fileData:fileData]];
    } onCancel:^{
        btn.selected = false;
    }];
}
- (NSString *)title {
    return LLang(@"文件");
}

-(UIImage*) imageName:(NSString*)name {
    return [[QCApp shared] loadImage:name moduleID:@"QCFile"];
}



@end
