//
//  NSString+Localized.h
//  WuKongBase
//
//  Created by tt on 2020/12/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCNoUse : NSObject
@end


@interface NSString (QCLocalized)

-(NSString* _Nonnull) Localized:(id)the;

-(NSString* _Nonnull) LocalizedWithClass:(Class)cls;

-(NSString* _Nonnull) LocalizedWithBundle:(NSBundle*)bundle;
@end

NS_ASSUME_NONNULL_END
