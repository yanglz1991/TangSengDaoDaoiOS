//
//  QCPageView.h
//  WuKongBase
//
//  Created by tt on 2020/1/10.
//

#import <UIKit/UIKit.h>
@class QCPageView;

@protocol QCPageViewDataSource <NSObject>
- (NSInteger)numberOfPages: (QCPageView *)pageView;
- (UIView *)pageView: (QCPageView *)pageView viewInPage: (NSInteger)index;
@end

@protocol QCPageViewDelegate <NSObject>
@optional
- (void)pageViewScrollEnd: (QCPageView *)pageView
             currentIndex: (NSInteger)index
               totolPages: (NSInteger)pages;

- (void)pageViewDidScroll: (QCPageView *)pageView;
- (BOOL)needScrollAnimation;
@end


@interface QCPageView : UIView<UIScrollViewDelegate>
@property (nonatomic,strong)    UIScrollView   *scrollView;
@property (nonatomic,weak)    id<QCPageViewDataSource>  dataSource;
@property (nonatomic,weak)    id<QCPageViewDelegate>    pageViewDelegate;

@property(nonatomic,assign) BOOL preloadOff; // 是否关闭预加载
- (void)scrollToPage: (NSInteger)pages;
- (void)reloadData;
- (UIView *)viewAtIndex: (NSInteger)index;
- (NSInteger)currentPage;


//旋转相关方法,这两个方法必须配对调用,否则会有问题
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration;

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration;
@end
