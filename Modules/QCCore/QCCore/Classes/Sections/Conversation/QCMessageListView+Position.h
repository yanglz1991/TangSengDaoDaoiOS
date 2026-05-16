//
//  QCMessageListView+Position.h
//  QCCore
//
//  Created by tt on 2022/5/18.
//

#import "QCMessageListView.h"

NS_ASSUME_NONNULL_BEGIN

@interface QCMessageListView (Position)

-(void) initPosition;

-(void) calcPositionAtBottom;

-(void) viewDidLayoutSubviewsOfPosition;

-(void) showScrollToBottomBarIfNeed;

-(void) handleNewMsgCountChange;

- (void)scrollViewDidScrollOfPosition:(UIScrollView *)scrollView;

-(void) layoutConversationPositionBarView;

-(void) updatePostionReminders:(NSArray<QCReminder*>*) reminders force:(BOOL)force;

@end

NS_ASSUME_NONNULL_END
