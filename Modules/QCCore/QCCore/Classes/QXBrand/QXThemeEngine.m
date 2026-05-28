//
//  QXThemeEngine.m
//  QCCore
//

#import "QXThemeEngine.h"
#import "QXBrandPalette.h"

NSString * const QXThemeEngineDidChangeNotification = @"QXThemeEngineDidChangeNotification";
static NSString * const kQXThemeEngineActiveKey = @"QXThemeEngine.active";

@implementation QXThemeDescriptor

+ (instancetype)descriptorWithIdentifier:(NSString *)identifier
                             displayName:(NSString *)name
                            primaryColor:(UIColor *)primary
                                    dark:(BOOL)dark {
    QXThemeDescriptor *d = [QXThemeDescriptor new];
    d.identifier      = identifier;
    d.displayName     = name;
    d.primaryColor    = primary;
    d.prefersDark     = dark;
    if (dark) {
        d.backgroundColor = [UIColor colorWithRed:16/255.0 green:16/255.0 blue:16/255.0 alpha:1.0];
        d.cellColor       = [UIColor colorWithRed:30/255.0 green:30/255.0 blue:30/255.0 alpha:1.0];
        d.textColor       = [UIColor colorWithWhite:0.92 alpha:1.0];
    } else {
        d.backgroundColor = [UIColor colorWithRed:247/255.0 green:248/255.0 blue:250/255.0 alpha:1.0];
        d.cellColor       = [UIColor whiteColor];
        d.textColor       = [UIColor colorWithRed:26/255.0 green:26/255.0 blue:26/255.0 alpha:1.0];
    }
    d.iconAsset = [NSString stringWithFormat:@"theme_%@", identifier];
    return d;
}

@end

@interface QXThemeEngine ()
@property (nonatomic, strong) NSMutableArray<QXThemeDescriptor *> *themes;
@property (nonatomic, strong) QXThemeDescriptor *activeTheme;
@end

@implementation QXThemeEngine

+ (instancetype)sharedEngine {
    static QXThemeEngine *e = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        e = [[QXThemeEngine alloc] initPrivate];
    });
    return e;
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        _themes = [NSMutableArray array];
        [self loadDefaultThemes];
        [self restoreActiveTheme];
    }
    return self;
}

- (void)loadDefaultThemes {
    QXBrandPalette *p = [QXBrandPalette sharedPalette];
    [self registerTheme:[QXThemeDescriptor descriptorWithIdentifier:@"classic"
                                                        displayName:@"经典蓝"
                                                       primaryColor:[p colorForRole:QXBrandColorRolePrimary darkMode:NO]
                                                               dark:NO]];
    [self registerTheme:[QXThemeDescriptor descriptorWithIdentifier:@"midnight"
                                                        displayName:@"午夜"
                                                       primaryColor:[p colorForRole:QXBrandColorRolePrimary darkMode:YES]
                                                               dark:YES]];
    [self registerTheme:[QXThemeDescriptor descriptorWithIdentifier:@"sunset"
                                                        displayName:@"日落橙"
                                                       primaryColor:[p colorForRole:QXBrandColorRoleSecondary darkMode:NO]
                                                               dark:NO]];
    [self registerTheme:[QXThemeDescriptor descriptorWithIdentifier:@"forest"
                                                        displayName:@"丛林绿"
                                                       primaryColor:[p colorForRole:QXBrandColorRoleSuccess darkMode:NO]
                                                               dark:NO]];
}

- (void)restoreActiveTheme {
    NSString *saved = [[NSUserDefaults standardUserDefaults] stringForKey:kQXThemeEngineActiveKey];
    QXThemeDescriptor *theme = [self themeForIdentifier:saved] ?: self.themes.firstObject;
    self.activeTheme = theme;
}

- (NSArray<QXThemeDescriptor *> *)registeredThemes {
    return [self.themes copy];
}

- (void)registerTheme:(QXThemeDescriptor *)theme {
    if (!theme.identifier.length) {
        return;
    }
    for (QXThemeDescriptor *existing in self.themes) {
        if ([existing.identifier isEqualToString:theme.identifier]) {
            return;
        }
    }
    [self.themes addObject:theme];
}

- (QXThemeDescriptor *)themeForIdentifier:(NSString *)identifier {
    if (!identifier.length) {
        return nil;
    }
    for (QXThemeDescriptor *t in self.themes) {
        if ([t.identifier isEqualToString:identifier]) {
            return t;
        }
    }
    return nil;
}

- (void)applyThemeWithIdentifier:(NSString *)identifier {
    QXThemeDescriptor *target = [self themeForIdentifier:identifier];
    if (!target) {
        return;
    }
    self.activeTheme = target;
    [[NSUserDefaults standardUserDefaults] setObject:identifier forKey:kQXThemeEngineActiveKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:QXThemeEngineDidChangeNotification
                                                        object:self
                                                      userInfo:@{@"identifier": identifier}];
}

- (void)addObserver:(id)observer selector:(SEL)selector {
    if (!observer || !selector) {
        return;
    }
    [[NSNotificationCenter defaultCenter] addObserver:observer
                                             selector:selector
                                                 name:QXThemeEngineDidChangeNotification
                                               object:nil];
}

- (void)removeObserver:(id)observer {
    if (!observer) {
        return;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:observer
                                                    name:QXThemeEngineDidChangeNotification
                                                  object:nil];
}

@end
