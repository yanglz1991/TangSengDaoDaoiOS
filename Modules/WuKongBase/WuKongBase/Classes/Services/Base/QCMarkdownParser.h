//
//  QCMarkdownParse.h
//  WuKongBase
//
//  Created by tt on 2022/4/28.
//

#import <Foundation/Foundation.h>
#import "QCMatchToken.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCMarkdownParser : NSObject

-(NSArray<id<QCMatchToken>>*) parseMarkdownIntoAttributedString:(NSString*)string;


@end

@interface QCMarkdownAttributeSet : NSObject

@property(nonatomic,strong) UIFont *font;
@property(nonatomic,strong) UIColor *textColor;
@property(nonatomic,strong) NSDictionary<NSAttributedStringKey,id> *attributes;

-(instancetype) initWithFont:(UIFont*)font textColor:(UIColor*)textColor attributes:(NSDictionary<NSAttributedStringKey,id>*)attributes;


@end

@interface QCMarkdownAttributes : NSObject

@property(nonatomic,strong) QCMarkdownAttributeSet *body;
@property(nonatomic,strong) QCMarkdownAttributeSet *bold;
@property(nonatomic,strong) QCMarkdownAttributeSet *link;
@property(nonatomic,copy)   NSDictionary<NSAttributedStringKey,id>*(^linkAttribute)(NSString*content) ;

@end

NS_ASSUME_NONNULL_END
