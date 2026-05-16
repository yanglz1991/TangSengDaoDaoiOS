//
//  QCMarkdownParse.m
//  QCCore
//
//  Created by tt on 2022/4/28.
//

#import "QCMarkdownParser.h"
#import "QCMatchToken.h"

@implementation QCMarkdownAttributeSet


-(instancetype) initWithFont:(UIFont*)font textColor:(UIColor*)textColor attributes:(NSDictionary<NSAttributedStringKey,id>*)attributes {
    QCMarkdownAttributeSet *p = [[QCMarkdownAttributeSet alloc] init];
    p.font = font;
    p.textColor = textColor;
    p.attributes = attributes;
    return p;
}

@end

@implementation QCMarkdownAttributes

-(instancetype) initBody:(QCMarkdownAttributeSet*)body bold:(QCMarkdownAttributeSet*)bold link:(QCMarkdownAttributeSet*)link linkAttribute:(NSDictionary<NSAttributedStringKey,id>*(^)(NSString*content))linkAttribute {
    QCMarkdownAttributes *attr = [[QCMarkdownAttributes alloc] init];
    attr.body = body;
    attr.bold = bold;
    attr.link = link;
    attr.linkAttribute = linkAttribute;
    return attr;
}


@end

@interface QCMarkdownParser ()

@property(nonatomic,copy) NSCharacterSet *controlStartCharactersSet;
@property(nonatomic,copy) NSCharacterSet *controlCharactersSet;



@end

@implementation QCMarkdownParser


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.controlStartCharactersSet =[NSCharacterSet characterSetWithCharactersInString:@"[*"];
        self.controlCharactersSet = [NSCharacterSet characterSetWithCharactersInString:@"[]()*_-\\"];
    }
    return self;
}

-(NSParagraphStyle*) paragraphStyleWithAlignment:(NSTextAlignment)alignment {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = alignment;
    return paragraphStyle;
}

-(NSArray<id<QCMatchToken>>*) parseMarkdownIntoAttributedString:(NSString*)string{
    NSString *nsString = [string copy];
    NSRange wholeRange = NSMakeRange(0, nsString.length);
    __block NSRange remainingRange = wholeRange;
   
    NSMutableArray *tokens = [NSMutableArray array];
    while (true) {
        NSRange range = [nsString rangeOfCharacterFromSet:self.controlStartCharactersSet options:0 range:remainingRange];
        if(range.location == NSNotFound) {
            break;
        }
        if(range.location != remainingRange.location) {
            remainingRange = NSMakeRange(range.location, remainingRange.location + remainingRange.length - range.location);
        }
        unichar character = [nsString characterAtIndex:range.location];
        if (character == '[') {
            remainingRange = NSMakeRange(range.location + range.length, remainingRange.location + remainingRange.length - (range.location + range.length));
            
           __block NSRange contentRange;
            __block NSString *contentText;
           QCLinkToken *token = [self parseLink:nsString remainingRange:remainingRange remainingRangeBlock:^(NSRange newRemainingRange) {
                remainingRange = newRemainingRange;
               contentRange = NSMakeRange(range.location, newRemainingRange.location - range.location);
               contentText = [nsString substringWithRange:contentRange];
            }];
            if(token) {
                token.range = contentRange;
                token.text = contentText;
                [tokens addObject:token];
            }
        }else if (character == '*') {
            if (range.location + 1 != wholeRange.length) {
                unichar nextCharacter = [nsString characterAtIndex:range.location+1];
                if (nextCharacter == character) {
                    remainingRange = NSMakeRange(range.location + range.length + 1, remainingRange.location + remainingRange.length - (range.location + range.length + 1));
                    
                    __block NSRange contentRange;
                     __block NSString *contentText;
                  QCBoldToken *token =  [self parseBold:nsString remainingRange:remainingRange remainingRangeBlock:^(NSRange newRemainingRange) {
                        remainingRange = newRemainingRange;
                       contentRange = NSMakeRange(range.location, newRemainingRange.location - range.location);
                       contentText = [nsString substringWithRange:contentRange];
                    }];
                    if(token) {
                        token.range = contentRange;
                        token.text = contentText;
                        [tokens addObject:token];
                    }else {
                        remainingRange = NSMakeRange(range.location + 1, remainingRange.length - 1);
                    }
                }else {
                    remainingRange = NSMakeRange(range.location + 1, remainingRange.length - 1);
                }
               
            }else {
                remainingRange = NSMakeRange(range.location + 1, remainingRange.length - 1);
            }
        }
    }
    
    return tokens;
}


-(QCLinkToken*) parseLink:(NSString*)string remainingRange:(NSRange)remainingRange remainingRangeBlock:(void(^)(NSRange newRemainingRange))remainingRangeBlock{
    NSRange localRemainingRange = remainingRange;
    NSRange closingSquareBraceRange  = [string rangeOfString:@"]" options:0 range:localRemainingRange];
    if(closingSquareBraceRange.location != NSNotFound) {
        localRemainingRange = NSMakeRange(closingSquareBraceRange.location + closingSquareBraceRange.length, remainingRange.location + remainingRange.length - (closingSquareBraceRange.location + closingSquareBraceRange.length));
        NSRange openingRoundBraceRange = [string rangeOfString:@"(" options:0 range:localRemainingRange];
        NSRange closingRoundBraceRange = [string rangeOfString:@")" options:0 range:localRemainingRange];
        
        if(openingRoundBraceRange.location == closingSquareBraceRange.location + closingSquareBraceRange.length && closingRoundBraceRange.location != NSNotFound && openingRoundBraceRange.location < closingRoundBraceRange.location) {
            
            QCLinkToken *token = [QCLinkToken new];
            
           NSString *linkText =  [string substringWithRange:NSMakeRange(remainingRange.location, closingSquareBraceRange.location - remainingRange.location)];
            NSString *linkContents = [string substringWithRange:NSMakeRange(openingRoundBraceRange.location + openingRoundBraceRange.length, closingRoundBraceRange.location - (openingRoundBraceRange.location + openingRoundBraceRange.length))];
            
            token.linkText = linkText;
            
            token.linkContent = linkContents;
            remainingRange = NSMakeRange(closingRoundBraceRange.location + closingRoundBraceRange.length, remainingRange.location + remainingRange.length - (closingRoundBraceRange.location + closingRoundBraceRange.length));
            if(remainingRangeBlock) {
                remainingRangeBlock(remainingRange);
            }
            
            return token;
        }
    }
    return nil;
}

-(QCBoldToken*) parseBold:(NSString*)string remainingRange:(NSRange)remainingRange remainingRangeBlock:(void(^)(NSRange newRemainingRange))remainingRangeBlock{
    NSRange localRemainingRange = remainingRange;
    NSRange closingRange = [string rangeOfString:@"**" options:0 range:localRemainingRange];
    if (closingRange.location != NSNotFound) {
        QCBoldToken *token = [QCBoldToken new];
        localRemainingRange = NSMakeRange(closingRange.location + closingRange.length, remainingRange.location + remainingRange.length - (closingRange.location + closingRange.length));
        NSString *result = [string substringWithRange:NSMakeRange(remainingRange.location, closingRange.location - remainingRange.location)];
        token.boldText = result;
        if(remainingRangeBlock) {
            remainingRangeBlock(localRemainingRange);
        }
        return token;
    }
    return nil;
}

@end
