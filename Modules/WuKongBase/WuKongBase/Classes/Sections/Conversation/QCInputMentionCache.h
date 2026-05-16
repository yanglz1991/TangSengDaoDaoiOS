//
//

#import <Foundation/Foundation.h>

#define QCInputAtStartChar  @"@"
#define QCInputAtEndChar    @"\u2004"

@interface QCInputMentionItem : NSObject

@property (nonatomic,copy) NSString *name;

@property (nonatomic,copy) NSString *uid;

@property (nonatomic,assign) NSRange range;

@end

@interface QCInputMentionCache : NSObject

@property (nonatomic,strong) NSMutableArray<QCInputMentionItem*> *items;

- (NSArray *)allMentionUid:(NSString *)sendText;

- (void)clean;

-(NSInteger) itemCount;

- (void)addMentionItem:(QCInputMentionItem *)item;

- (QCInputMentionItem *)item:(NSString *)name;

- (QCInputMentionItem *)removeName:(NSString *)name;

@end
