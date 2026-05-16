//
//  QCContextMenusVC.h
//  QCCore
//
//  Created by tt on 2022/6/11.
//

#import <QCCore/QCCore.h>
NS_ASSUME_NONNULL_BEGIN


@interface QCMessageReactionModel : NSObject

@property(nonatomic,copy) NSString *reactionName;

@property(nonatomic,copy) NSString *reactionURL;

-(instancetype) initWithReactionName:(NSString*) reactionName reactionURL:(NSString*)reactionURL;

@end


@interface QCContextMenusVC : NSObject


@property(nonatomic,strong) UIView *focusedView; // 消息的view
// 回应item点击
@property(nonatomic,copy) void(^onReactionItem)(QCMessageReactionModel* model);

@property (nonatomic,copy) void(^disMissAction)(void);

@property(nonatomic,weak) id delegate;

//- (instancetype)initWithFocusedView:(UIView*)focusedView toolbarMenus:(NSArray<QCMessageLongMenusItem*>*)toolbarMenus conversationContext:(id<QCConversationContext>)conversationContext;

- (instancetype)initWithFocusedView:(UIView*)focusedView toolbarMenus:(NSArray<QCMessageLongMenusItem*>*)toolbarMenus conversationContext:(id<QCConversationContext>)conversationContext originalProjectedContentViewFrame:(CGRect)originalProjectedContentViewFrame;

-(void) presentOnWindow:(UIWindow*)window;

-(void) dismiss;

-(void) updateFocusedView:(UIView*)focusedView;

@end

NS_ASSUME_NONNULL_END
