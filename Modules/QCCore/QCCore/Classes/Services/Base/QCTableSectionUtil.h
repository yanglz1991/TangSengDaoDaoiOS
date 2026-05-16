//
//  QCTableSectionUtil.h
//  QCCore
//
//  Created by tt on 2020/3/1.
//

#import <Foundation/Foundation.h>
#import "QCFormSection.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCTableSectionUtil : NSObject


/// 将字典类型转换为Form对象
/// @param sectionArray <#sectionArray description#>
+(NSArray<QCFormSection*>*) toSections:(NSArray<NSDictionary*>*) sectionArray;
@end

NS_ASSUME_NONNULL_END
