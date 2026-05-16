//
//  QCFileCommon.m
//  WuKongFile
//
//  Created by tt on 2020/5/5.
//

#import "QCFileCommon.h"

@implementation QCFileInfoModel



@end

@interface QCFileCommon ()

@property(nonatomic,strong) NSArray *imgExtends;
@property(nonatomic,strong) NSArray *docExtends;
@property(nonatomic,strong) NSArray *xlsExtends;

@end

@implementation QCFileCommon

static QCFileCommon *_instance;


+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
+ (QCFileCommon *)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        
    });
    return _instance;
}

-(QCFileInfoModel*) fileInfoWithName:(NSString*)name {
    if(!name) {
        return nil;
    }
    QCFileInfoModel *fileInfoModel = [QCFileInfoModel new];
    QCFileType fileType = [self getFileType:name];
    switch (fileType) {
        case QCFileTypeWord:
            fileInfoModel.extendIcon = @"Word";
            fileInfoModel.fileColor = [UIColor colorWithRed:73.0f/255.0f green:126.0f/255.0f blue:247.0f/255.0f alpha:1.0f];
            break;
        case QCFileTypeExcel:
            fileInfoModel.extendIcon = @"Excel";
            fileInfoModel.fileColor = [UIColor colorWithRed:39.0f/255.0f green:204.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
            break;
        case QCFileTypePPT:
            fileInfoModel.extendIcon = @"Ppt";
            fileInfoModel.fileColor = [UIColor colorWithRed:255.0f/255.0f green:182.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
            break;
        case QCFileTypePDF:
            fileInfoModel.extendIcon = @"Pdf";
            fileInfoModel.fileColor = [UIColor colorWithRed:255.0f/255.0f green:91.0f/255.0f blue:16.0f/255.0f alpha:1.0f];
            break;
         case QCFileTypeZIP:
            fileInfoModel.extendIcon = @"Zip";
            fileInfoModel.fileColor = [UIColor colorWithRed:234.0f/255.0f green:156.0f/255.0f blue:112.0f/255.0f alpha:1.0f];
            break;
         case QCFileTypeRAR:
            fileInfoModel.extendIcon = @"Rar";
            fileInfoModel.fileColor = [UIColor colorWithRed:245.0f/255.0f green:180.0f/255.0f blue:80.0f/255.0f alpha:1.0f];
            break;
        default:
            fileInfoModel.extendIcon = @"File";
            fileInfoModel.fileColor = [UIColor colorWithRed:255.0f/255.0f green:182.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
            break;
    }
    return fileInfoModel;
}

-(QCFileType) getFileType:(NSString*)name {
   NSString *extension = [name pathExtension];
    extension = [extension lowercaseString];
    if([self.imgExtends containsObject:extension]) {
        return QCFileTypeImage;
    }
    if([self.docExtends containsObject:extension]) {
        return QCFileTypeWord;
    }
    if([self.xlsExtends containsObject:extension]) {
        return QCFileTypeExcel;
    }
    if([extension isEqualToString:@"zip"]) {
        return QCFileTypeZIP;
    }
    if([extension isEqualToString:@"rar"]) {
        return QCFileTypeRAR;
    }
    if([extension isEqualToString:@"ppt"]) {
        return QCFileTypePPT;
    }
    if([extension isEqualToString:@"pdf"]) {
        return QCFileTypePDF;
    }
    if([extension isEqualToString:@"pages"]) {
        return QCFileTypePages;
    }
    if([self.textExtends containsObject:extension]) {
        return QCFileTypeText;
    }
    return QCFileTypeUnknown;
}

- (NSArray *)imgExtends {
    return @[@"png",@"jpg",@"jpeg",@"bmp",@"gif"];
}

- (NSArray *)docExtends {
    return @[@"doc",@"docx"];
}

- (NSArray *)xlsExtends {
    return @[@"xls",@"xlsx"];
}
- (NSArray *)textExtends {
    return @[@"txt",@"log"];
}

-(NSString*) sizeFormat:(NSInteger)size {
   if (size < 1024) {
       return [NSString stringWithFormat:@"%ld B",(long)size];
    }
    if (size > 1024 && size < 1024 * 1024) {
        return [NSString stringWithFormat:@"%0.2f KB",size/1024.0f];
    }
    if (size > 1024 * 1024 && size < 1024 * 1024 * 1024) {
        return [NSString stringWithFormat:@"%0.2f M",size/(1024.0f*1024.0f)];
    }
    return [NSString stringWithFormat:@"%0.2f G",size/(1024.0f*1024.0f*1024.0f)];
}

-(BOOL) support:(NSString*)filename {
    QCFileType fileType = [self getFileType:filename];
    switch (fileType) {
        case QCFileTypePDF:
        case QCFileTypeText:
        case QCFileTypeImage:
        case QCFileTypeWord:
        case QCFileTypeExcel:
        case QCFileTypePages:
            return true;
        default:
            break;
    }
    return false;
}
@end
