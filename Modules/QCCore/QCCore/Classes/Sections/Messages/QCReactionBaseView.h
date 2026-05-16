//
//  QCReactionView.h
//  QCCore
//
//  Created by tt on 2021/9/13.
//

#import <UIKit/UIKit.h>
#import <QCIM/QCIM.h>
NS_ASSUME_NONNULL_BEGIN

@interface QCReactionBaseView : UIView

@property(nonatomic,assign) NSInteger reactionNum;

-(void) render:(NSArray<QCReaction*>*) reactions;


@end

NS_ASSUME_NONNULL_END
