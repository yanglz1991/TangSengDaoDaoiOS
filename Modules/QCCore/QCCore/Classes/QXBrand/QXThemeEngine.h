//
//  QXThemeEngine.h
//  QCCore
//
//  喜聊主题引擎。负责注册/切换主题，向订阅者广播主题变更，
//  并将主题描述持久化到 NSUserDefaults。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const QXThemeEngineDidChangeNotification;

@class QXThemeDescriptor;

@interface QXThemeDescriptor : NSObject
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, strong) UIColor *primaryColor;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *cellColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) BOOL    prefersDark;
@property (nonatomic, copy)   NSString *iconAsset;
+ (instancetype)descriptorWithIdentifier:(NSString *)identifier
                             displayName:(NSString *)name
                            primaryColor:(UIColor *)primary
                                    dark:(BOOL)dark;
@end

@interface QXThemeEngine : NSObject

+ (instancetype)sharedEngine;

@property (nonatomic, copy, readonly) NSArray<QXThemeDescriptor *> *registeredThemes;
@property (nonatomic, strong, readonly) QXThemeDescriptor *activeTheme;

- (void)registerTheme:(QXThemeDescriptor *)theme;
- (void)applyThemeWithIdentifier:(NSString *)identifier;
- (nullable QXThemeDescriptor *)themeForIdentifier:(NSString *)identifier;

- (void)addObserver:(id)observer selector:(SEL)selector;
- (void)removeObserver:(id)observer;

@end

NS_ASSUME_NONNULL_END
