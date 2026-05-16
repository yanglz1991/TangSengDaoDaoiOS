//
//  QCAnnotation.h
//  QCCore
//
//  Created by tt on 2019/12/1.
//

#import <Foundation/Foundation.h>

#define QCModuleSectName "QCMods"


#define QCDATA(sectname) __attribute((used, section("__DATA,"#sectname" ")))


#define QCModule(name) \
class BeeHive; char * k##name##_mod QCDATA(QCMods) = ""#name"";

NS_ASSUME_NONNULL_BEGIN



@interface QCAnnotation : NSObject

@end

NS_ASSUME_NONNULL_END
