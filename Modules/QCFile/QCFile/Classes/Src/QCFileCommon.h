//
//  QCFileCommon.h
//  QCFile
//
//  Created by tt on 2020/5/5.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    QCFileTypeUnknown,
    QCFileTypeWord,
    QCFileTypeImage,
    QCFileTypeExcel,
    QCFileTypePPT,
    QCFileTypePDF,
    QCFileTypeZIP,
    QCFileTypeRAR,
    QCFileTypeText,
    QCFileTypePages,
} QCFileType;

NS_ASSUME_NONNULL_BEGIN

@interface QCFileInfoModel : NSObject

@property(nonatomic,copy) NSString *extendIcon;
@property(nonatomic,strong) UIColor *fileColor;

@end

@interface QCFileCommon : NSObject

+ (QCFileCommon *)shared;

-(QCFileInfoModel*) fileInfoWithName:(NSString*)name;

-(NSString*) sizeFormat:(NSInteger)size;


/// 是否支持的格式
/// @param filename <#filename description#>
-(BOOL) support:(NSString*)filename;

@end

NS_ASSUME_NONNULL_END
