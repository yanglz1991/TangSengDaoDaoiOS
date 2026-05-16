//
//  QCEmoticonService.m
//  QCCore
//
//  Created by tt on 2020/1/10.
//

#import "QCEmoticonService.h"
#import "QCApp.h"
#define kFaceIDKey          @"face_id"
#define kFaceNameKey        @"face_name"
#define kFaceImageNameKey   @"face_image_name"

#define kFaceRankKey        @"face_rank"
#define kFaceClickKey       @"face_click"

#define recentNum 7 // 最近表情最大数量

@implementation QCEmotion

@synthesize faceId;
@synthesize faceImageName;
@synthesize faceName;
@synthesize faceRank;

@end


@interface QCEmoticonService()

@property (strong, nonatomic) NSMutableArray *emojiFaceArrays;
@property (strong, nonatomic) NSMutableArray *recentFaceArrays;
@property (nonatomic,strong)    NSCache *tokens;

@property(nonatomic,copy) NSString *emojiReg;

@end


@implementation QCEmoticonService

static QCEmoticonService *_instance;
+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
+ (QCEmoticonService *)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        
    });
    return _instance;
}

- (instancetype)init{
    if (self = [super init]) {
        _tokens = [[NSCache alloc] init];
        _emojiFaceArrays = [NSMutableArray array];
        
        NSArray *faceArray = [NSArray arrayWithContentsOfFile:[self defaultEmojiFacePath]];
        NSDictionary *faceDic = faceArray[0];
        NSMutableArray *faceNames = [NSMutableArray array];
        [faceDic[@"data"] enumerateObjectsUsingBlock:^(NSDictionary* dic, NSUInteger idx, BOOL * _Nonnull stop) {
            QCEmotion *emotion = [QCEmotion new];
            emotion.faceId = dic[@"id"];
            emotion.faceName = dic[@"tag"];
            emotion.faceImageName = dic[@"file"];
            
            [self->_emojiFaceArrays addObject:emotion];
            
            [faceNames addObject:emotion.faceName];
        }];
        
        self.emojiReg = [NSString stringWithFormat:@"(%@)",[faceNames componentsJoinedByString:@"|"]];
        
        NSArray *recentArrays = [[NSUserDefaults standardUserDefaults] arrayForKey:@"recentFaceArrays"];
        if (recentArrays) {
            _recentFaceArrays = [NSMutableArray arrayWithArray:recentArrays];
        }else{
            _recentFaceArrays = [NSMutableArray array];
        }
    }
    return self;
}

+(instancetype) sharedInstance{
    static dispatch_once_t onceToken;
    static id shareInstance;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

- (NSString *)defaultEmojiFacePath{
    NSBundle *b= [QCApp.shared resourceBundle:@"QCCore"];
    return [b pathForResource:@"emoji" ofType:@"plist" inDirectory:@"emoji"];
}

-(NSArray<id<QCMatchToken>>*)parseEmotion:(NSString *)text{
    
    NSMutableArray<id<QCMatchToken>> *tokens = [_tokens objectForKey:text];
    if(tokens) {
        return tokens;
    }
    
    tokens = [NSMutableArray array];
    static NSRegularExpression *exp;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        exp = [NSRegularExpression regularExpressionWithPattern:self.emojiReg
                                                        options:NSRegularExpressionCaseInsensitive
                                                          error:nil];
    });
    
    __block NSInteger index = 0;
    [exp enumerateMatchesInString:text
                          options:0
                            range:NSMakeRange(0, [text length])
                       usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                           NSString *rangeText = [text substringWithRange:result.range];
                           for (QCEmotion *emotion in self->_emojiFaceArrays) {
                               if ([emotion.faceName  isEqualToString:rangeText]) {
                                   if (result.range.location > index){
                                       NSRange rawRange = NSMakeRange(index, result.range.location - index);
                                       NSString *rawText = [text substringWithRange:rawRange];
                                       [tokens addObject: [QCDefaultToken text:rawText range:rawRange type:WKatchTokenTypeText]];
                                   }
                                   QCEmotionToken *token = [QCEmotionToken new];
                                   token.text = rangeText;
                                   token.range = result.range;
                                   token.imageName = emotion.faceImageName;
                                   
                                   [tokens addObject:token];
                                   index = result.range.location + result.range.length;
                               }
                           }
                           
                       }];
    
    if (index < [text length])
    {
        NSRange range = NSMakeRange(index, [text length] - index);
        NSString *rawText = [text substringWithRange:range];
        [tokens addObject: [QCDefaultToken text:rawText range:range type:WKatchTokenTypeText]];
    }
    
    [_tokens setObject:tokens forKey:text];
    
    return tokens;
}


-(id<QCPEmotion>) emotionByFaceName:(NSString*)faceName{
    for (QCEmotion *emotion in self.emojiFaceArrays) {
        if([emotion.faceName isEqualToString:faceName]){
            return emotion;
        }
    }
    return nil;
}



-(UIImage*) imageNamed:(NSString*)name{
    return [QCApp.shared loadImage:name moduleID:@"QCCore"];
//    return [[QCResource shared] resourceForImage:name podName:@"QCCore_images"];
}

-(UIImage*) emojiImageNamed:(NSString*)imageName{
    
    
    return [self imageNamed:[NSString stringWithFormat:@"Conversation/Emoji/%@",imageName]];
}

- (NSArray<QCEmotion*> *)emotions {
    return _emojiFaceArrays;
}

-(NSArray<id<QCPEmotion>>*) recentEmotions {
    NSMutableArray<id<QCPEmotion>> *emotions = [NSMutableArray array];
    for (NSDictionary *emotionDict  in self.recentFaceArrays) {
        [emotions addObject:[self toEmotion:emotionDict]];
    }
    return emotions;
}

-(QCEmotion*) toEmotion:(NSDictionary*)emotionDict {
    QCEmotion *emotion = [QCEmotion new];
    emotion.faceId = emotionDict[@"faceId"]?:@"";
    emotion.faceName = emotionDict[@"faceName"]?:@"";
    emotion.faceImageName = emotionDict[@"faceImageName"]?:@"";
    return emotion;
}

-(NSDictionary*) toEmotionDict:(id<QCPEmotion>) emotion {
    return @{
        @"faceId": emotion.faceId,
        @"faceName": emotion.faceName,
        @"faceImageName": emotion.faceImageName,
    };
}


// 最近使用
-(BOOL) recentEmoji:(id<QCPEmotion>)emotion {
    NSMutableArray *recentFaceArrays = [NSMutableArray arrayWithArray:self.recentFaceArrays];
    if( recentFaceArrays.count>0) {
        NSInteger i=0;
        for (NSDictionary *recentEmotionDict in recentFaceArrays) {
            NSString *faceId= recentEmotionDict[@"faceId"];
            if([faceId isEqualToString:emotion.faceId]) {
                if(i==0) {
                    return NO;
                }else {
                    [recentFaceArrays removeObjectAtIndex:i];
                    break;
                }
            }
            i++;
        }
    }
    [recentFaceArrays insertObject:[self toEmotionDict:emotion] atIndex:0];
    
    if(recentFaceArrays.count>recentNum) {
        [recentFaceArrays removeLastObject];
    }
    [[NSUserDefaults standardUserDefaults] setObject:recentFaceArrays forKey:@"recentFaceArrays"];
    
    return YES;
}

@end
