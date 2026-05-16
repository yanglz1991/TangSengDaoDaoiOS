//
//  QCFileChooseUtil.m
//  QCContacts
//
//  Created by tt on 2020/7/16.
//

#import "QCFileChooseUtil.h"
#import <QCCore/QCCore.h>

@interface QCFileChooseUtil ()<UIDocumentPickerDelegate>
@property(nonatomic,copy) fileChooseComplete complete;

@property(nonatomic,copy) void(^onCancel)(void);

@end

@implementation QCFileChooseUtil

static QCFileChooseUtil *_instance;

+(instancetype) shared{
    if (_instance == nil) {
        _instance = [[super alloc]init];
    }
    return _instance;
}

- (void)chooseFile:(fileChooseComplete)complete onCancel:(void(^)(void))onCancel{
    self.complete = complete;
    self.onCancel = onCancel;
    NSArray * arr=@[(__bridge NSString *) kUTTypeContent,
                    (__bridge NSString *) kUTTypeData,
                    (__bridge NSString *) kUTTypePackage,
                    (__bridge NSString *) kUTTypeDiskImage,
                    @"com.apple.iwork.pages.pages",
                    @"com.apple.iwork.numbers.numbers",
                    @"com.apple.iwork.keynote.key"];
    
    UIDocumentPickerViewController *documentPickerViewController = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:arr inMode:UIDocumentPickerModeOpen];
    documentPickerViewController.delegate = self;
    [[QCNavigationManager shared].topViewController presentViewController:documentPickerViewController animated:YES completion:nil];
}

#pragma mark - UIDocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    //获取授权
    BOOL fileUrlAuthozied = [urls.firstObject startAccessingSecurityScopedResource];
    if (fileUrlAuthozied) {
        //通过文件协调工具来得到新的文件地址，以此得到文件保护功能
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
         NSError *error;
        [fileCoordinator coordinateReadingItemAtURL:urls.firstObject options:0 error:&error byAccessor:^(NSURL *newURL) {
             //读取文件
             NSString *fileName = [newURL lastPathComponent];
            NSError *error = nil;
             NSData *fileData = [NSData dataWithContentsOfURL:newURL options:NSDataReadingMappedIfSafe error:&error];
            if (!error) {
                if(self.complete) {
                    self.complete(fileName, fileData);
                }
            }
            [[QCNavigationManager shared].topViewController dismissViewControllerAnimated:YES completion:NULL];
        }];
         [urls.firstObject stopAccessingSecurityScopedResource];
    }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    if(self.onCancel) {
        self.onCancel();
    }
}

@end
