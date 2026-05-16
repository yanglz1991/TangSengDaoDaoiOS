//
//  QCFileInfoVC.m
//  QCFile
//
//  Created by tt on 2020/7/16.
//

#import "QCFileInfoVC.h"
#import "QCFileCommon.h"
#import "QCFileContent.h"
#import "QCFileModule.h"
#import "QCCircleProgressView.h"
#import "QCFilePreviewVC.h"
@interface QCFileInfoVC ()<UIDocumentInteractionControllerDelegate>

@property(nonatomic,strong) UIView *fileHeader;
@property(nonatomic,strong) UIImageView *fileIconImgView;
@property (nonatomic, strong) QCCircleProgressView *progressBar;
@property(nonatomic,strong) UILabel *fileNameLbl;
@property(nonatomic,strong) UILabel *fileSizeLbl;

@property(nonatomic,strong) QCFileContent *fileContent;

// 下载任务
@property(nonatomic,strong) QCMessageFileDownloadTask *downloadTask;

@property(nonatomic,strong) UIButton *previewBtn; // 预览按钮
@property(nonatomic,strong) UIButton *otherAppBtn; // 其他app打开
@property(nonatomic,strong) UIDocumentInteractionController *documentController;

@end

@implementation QCFileInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationBar setBackgroundColor:[UIColor whiteColor]];
    self.fileContent = (QCFileContent*)self.fileMessage.content;
    [self.view addSubview:self.fileHeader];
    [self.fileHeader addSubview:self.fileIconImgView];
    [self.view addSubview:self.fileNameLbl];
    [self.view addSubview:self.fileSizeLbl];
    
    [self.view addSubview:self.progressBar];
    [self.view addSubview:self.previewBtn];
    [self.view addSubview:self.otherAppBtn];
    
    
    QCFileInfoModel *fileInfo = [[QCFileCommon shared] fileInfoWithName:self.fileContent.name];
    [self.fileHeader setBackgroundColor:fileInfo.fileColor];
    self.fileIconImgView.image = [self imageName:fileInfo.extendIcon];
    
    BOOL exist = [QCFileUtil fileIsExistOfPath:self.fileContent.localPath];
    if(exist) { // 已下载
        [self downed];
    }else { // 未下载
        // 先获取下载队列里是否正在下载，如果正在下载则监听下载状态
        // 如果下载队列里没有下载，则开启下载任务并监听下载状态
        self.downloadTask = [[QCSDK shared] getMessageDownloadTask:self.fileMessage.message];
        if(!self.downloadTask) {
            self.downloadTask = [[QCSDK shared].mediaManager download:self.fileMessage.message];
        }
        __weak typeof(self) weakSelf = self;
        if(self.downloadTask) {
            [self.downloadTask addListener:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf downing:weakSelf.downloadTask];
                });
                
            } target:self];
        }
    }
    
}
- (void)dealloc
{
    if(self.downloadTask) {
        [self.downloadTask removeListener:self];
    }
}

-(void) downing:(QCMessageFileDownloadTask*) task {
    if(task.status == QCTaskStatusProgressing) {
        self.progressBar.progress = task.progress;
    }else if(task.status == QCMediaDownloadStateSuccess) {
        [self downed];
    }else if (task.status == QCMediaDownloadStateFail) {
        [self.view showHUDWithHide:task.error.domain];
    }
}

// 已下载
-(void) downed {
    // 如果是已下载 则隐藏进度条，
    // 如果是支持的格式则直接打开预览，
    // 如果是不支持的格式则显示 其他应用打开的按钮
    
    self.progressBar.hidden = YES;
    bool support = [[QCFileCommon shared] support:self.fileContent.name];
    if(support) {
       QCFilePreviewVC *vc = [QCFilePreviewVC new];
        vc.fileName = self.fileContent.name;
        vc.url = [NSURL fileURLWithPath:self.fileContent.localPath];
        [[QCNavigationManager shared] replacePushViewController:vc animated:NO];
    }else {
        self.otherAppBtn.hidden = NO;
    }
    
}

- (UIImageView *)fileIconImgView {
    if(!_fileIconImgView) {
        _fileIconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.fileHeader.lim_width - 20.0f, self.fileHeader.lim_width - 20.0f)];
        _fileIconImgView.lim_top = self.fileHeader.lim_height/2.0f - _fileIconImgView.lim_height/2.0f;
        _fileIconImgView.lim_left = self.fileHeader.lim_width/2.0f - _fileIconImgView.lim_width/2.0f;
    }
    return _fileIconImgView;
}

-(UIView*) fileHeader {
    if(!_fileHeader) {
        _fileHeader = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.navigationBar.lim_bottom+80.0f, 70.0f, 70.0f)];
        _fileHeader.lim_left = self.view.lim_width/2.0f - _fileHeader.lim_width/2.0f;
    }
    return _fileHeader;
}

- (UILabel *)fileNameLbl {
    if(!_fileNameLbl) {
        _fileNameLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, QCScreenWidth - 80.0f, 0.0f)];
        _fileNameLbl.text = self.fileContent.name;
        _fileNameLbl.lineBreakMode = NSLineBreakByWordWrapping;
        _fileNameLbl.numberOfLines = 0;
        [_fileNameLbl setFont:[[QCApp shared].config appFontOfSizeMedium:18.0f]];
        [_fileNameLbl sizeToFit];
        _fileNameLbl.lim_top = self.fileHeader.lim_bottom + 20.0f;
        _fileNameLbl.lim_left = self.view.lim_width/2.0f - _fileNameLbl.lim_width/2.0f;
        
    }
    return _fileNameLbl;
}

- (UILabel *)fileSizeLbl {
    if(!_fileSizeLbl) {
        _fileSizeLbl = [[UILabel alloc] init];
        [_fileSizeLbl setFont:[[QCApp shared].config appFontOfSize:17.0f]];
        _fileSizeLbl.text = [NSString stringWithFormat:LLang(@"文件大小：%@"),[[QCFileCommon shared] sizeFormat:self.fileContent.size]];
        [_fileSizeLbl sizeToFit];
        _fileSizeLbl.lim_top = self.fileNameLbl.lim_bottom + 20.0f;
        _fileSizeLbl.lim_left = self.view.lim_width/2.0f - _fileSizeLbl.lim_width/2.0f;
    }
    return _fileSizeLbl;
}

- (QCCircleProgressView *)progressBar {
    if(!_progressBar) {
        _progressBar = [[QCCircleProgressView alloc] initWithFrame:CGRectMake(0.0f, self.fileSizeLbl.lim_bottom + 120.0f, 60.0f, 60.0f)];
        _progressBar.lim_left = self.view.lim_width/2.0f - _progressBar.lim_width/2.0f;
        _progressBar.progerssColor = [QCApp shared].config.themeColor;
        _progressBar.progerssBackgroundColor = [QCApp shared].config.backgroundColor;
        _progressBar.hiddenPercentage = YES;
        UIImageView *pauseIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 20.0f)];
        [pauseIcon setImage:[self imageName:@"Pause"]];
        [_progressBar addSubview:pauseIcon];
        pauseIcon.lim_left = _progressBar.lim_width/2.0f - pauseIcon.lim_width/2.0f;
        pauseIcon.lim_top = _progressBar.lim_height/2.0f - pauseIcon.lim_height/2.0f;
    }
    return _progressBar;
}

- (UIButton *)previewBtn {
    if(!_previewBtn) {
        _previewBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 44.0f)];
        [_previewBtn setTitle:LLang(@"预览") forState:UIControlStateNormal];
        [_previewBtn setBackgroundColor:[QCApp shared].config.themeColor];
        _previewBtn.layer.masksToBounds = YES;
        _previewBtn.layer.cornerRadius = 4.0f;
        _previewBtn.lim_left = self.view.lim_width/2.0f - _previewBtn.lim_width/2.0f;
        _previewBtn.hidden = YES;
    }
    return _previewBtn;
}

- (UIButton *)otherAppBtn {
    if(!_otherAppBtn) {
        _otherAppBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 44.0f)];
        [_otherAppBtn setTitle:LLang(@"其他应用打开") forState:UIControlStateNormal];
         _otherAppBtn.lim_left = self.view.lim_width/2.0f - _otherAppBtn.lim_width/2.0f;
        _otherAppBtn.lim_top = self.progressBar.lim_top;
        _otherAppBtn.hidden = YES;
        [_otherAppBtn setBackgroundColor:[QCApp shared].config.themeColor];
        _otherAppBtn.layer.masksToBounds = YES;
        _otherAppBtn.layer.cornerRadius = 4.0f;
        [_otherAppBtn addTarget:self action:@selector(otherAppBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _otherAppBtn;
}

-(UIImage*) imageName:(NSString*)name {
    return [[QCApp shared] loadImage:name moduleID:[QCFileModule gmoduleId]];
}

#pragma mark -- 事件

-(void) otherAppBtnPressed {
    _documentController = [UIDocumentInteractionController
                                                           interactionControllerWithURL:[NSURL fileURLWithPath:self.fileContent.localPath]];
    BOOL canOpen = [_documentController presentOpenInMenuFromRect:CGRectZero
                                                            inView:self.view
                                                          animated:YES];
    _documentController.delegate = self;
     if (!canOpen) {
         QCLogDebug(@"沒有程序可以打開要分享的文件");
     }
}

#pragma mark----delegate
- (UIViewController *)documentInteractionControllerViewControllerForPreview:
    (UIDocumentInteractionController *)controller {
  return self;
}
- (UIView *)documentInteractionControllerViewForPreview:
    (UIDocumentInteractionController *)controller {
  return self.view;
}

- (CGRect)documentInteractionControllerRectForPreview:
    (UIDocumentInteractionController *)controller {
  return self.view.frame;
}

//点击预览窗口的“Done”(完成)按钮时调用
- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller {
    
}

@end
