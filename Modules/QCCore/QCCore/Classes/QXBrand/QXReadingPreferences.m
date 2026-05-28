//
//  QXReadingPreferences.m
//  QCCore
//

#import "QXReadingPreferences.h"

NSString * const QXReadingPreferencesDidChangeNotification = @"QXReadingPreferencesDidChangeNotification";

static NSString * const kQXFontScale       = @"QXReadingPrefs.fontScale";
static NSString * const kQXLineSpacing     = @"QXReadingPrefs.lineSpacing";
static NSString * const kQXBubbleRadius    = @"QXReadingPrefs.bubbleRadius";
static NSString * const kQXDensity         = @"QXReadingPrefs.density";
static NSString * const kQXMonoTimestamps  = @"QXReadingPrefs.monoTimestamps";
static NSString * const kQXBoldNicknames   = @"QXReadingPrefs.boldNicknames";

@interface QXReadingPreferences ()
@property (nonatomic, assign) BOOL didLoad;
@end

@implementation QXReadingPreferences

+ (instancetype)sharedPreferences {
    static QXReadingPreferences *p = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        p = [QXReadingPreferences new];
    });
    return p;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self load];
    }
    return self;
}

- (void)load {
    if (self.didLoad) {
        return;
    }
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    _fontScale          = [d objectForKey:kQXFontScale]    ? [[d objectForKey:kQXFontScale]    doubleValue] : 1.0;
    _lineSpacing        = [d objectForKey:kQXLineSpacing]  ? [[d objectForKey:kQXLineSpacing]  doubleValue] : 2.0;
    _bubbleCornerRadius = [d objectForKey:kQXBubbleRadius] ? [[d objectForKey:kQXBubbleRadius] doubleValue] : 12.0;
    _density            = [d objectForKey:kQXDensity]      ? [[d objectForKey:kQXDensity]      integerValue]: QXReadingDensityRegular;
    _monoTimestamps     = [d objectForKey:kQXMonoTimestamps] ? [[d objectForKey:kQXMonoTimestamps] boolValue] : YES;
    _boldNicknames      = [d objectForKey:kQXBoldNicknames]  ? [[d objectForKey:kQXBoldNicknames]  boolValue] : NO;
    self.didLoad = YES;
}

#pragma mark - setters

- (void)setFontScale:(CGFloat)fontScale {
    if (fontScale < 0.85) fontScale = 0.85;
    if (fontScale > 1.40) fontScale = 1.40;
    if (fabs(fontScale - _fontScale) < 0.001) return;
    _fontScale = fontScale;
    [[NSUserDefaults standardUserDefaults] setDouble:fontScale forKey:kQXFontScale];
    [self emit];
}

- (void)setLineSpacing:(CGFloat)lineSpacing {
    if (lineSpacing < 0) lineSpacing = 0;
    if (lineSpacing > 8) lineSpacing = 8;
    if (fabs(lineSpacing - _lineSpacing) < 0.001) return;
    _lineSpacing = lineSpacing;
    [[NSUserDefaults standardUserDefaults] setDouble:lineSpacing forKey:kQXLineSpacing];
    [self emit];
}

- (void)setBubbleCornerRadius:(CGFloat)bubbleCornerRadius {
    if (bubbleCornerRadius < 0)  bubbleCornerRadius = 0;
    if (bubbleCornerRadius > 30) bubbleCornerRadius = 30;
    if (fabs(bubbleCornerRadius - _bubbleCornerRadius) < 0.001) return;
    _bubbleCornerRadius = bubbleCornerRadius;
    [[NSUserDefaults standardUserDefaults] setDouble:bubbleCornerRadius forKey:kQXBubbleRadius];
    [self emit];
}

- (void)setDensity:(QXReadingDensity)density {
    if (_density == density) return;
    _density = density;
    [[NSUserDefaults standardUserDefaults] setInteger:density forKey:kQXDensity];
    [self emit];
}

- (void)setMonoTimestamps:(BOOL)monoTimestamps {
    if (_monoTimestamps == monoTimestamps) return;
    _monoTimestamps = monoTimestamps;
    [[NSUserDefaults standardUserDefaults] setBool:monoTimestamps forKey:kQXMonoTimestamps];
    [self emit];
}

- (void)setBoldNicknames:(BOOL)boldNicknames {
    if (_boldNicknames == boldNicknames) return;
    _boldNicknames = boldNicknames;
    [[NSUserDefaults standardUserDefaults] setBool:boldNicknames forKey:kQXBoldNicknames];
    [self emit];
}

#pragma mark - util

- (UIFont *)scaledFontFromBaseSize:(CGFloat)baseSize {
    return [UIFont systemFontOfSize:baseSize * self.fontScale];
}

- (UIFont *)scaledFontFromBaseSize:(CGFloat)baseSize weight:(UIFontWeight)weight {
    return [UIFont systemFontOfSize:baseSize * self.fontScale weight:weight];
}

- (void)resetToDefaults {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [d removeObjectForKey:kQXFontScale];
    [d removeObjectForKey:kQXLineSpacing];
    [d removeObjectForKey:kQXBubbleRadius];
    [d removeObjectForKey:kQXDensity];
    [d removeObjectForKey:kQXMonoTimestamps];
    [d removeObjectForKey:kQXBoldNicknames];
    [d synchronize];
    _fontScale = 1.0;
    _lineSpacing = 2.0;
    _bubbleCornerRadius = 12.0;
    _density = QXReadingDensityRegular;
    _monoTimestamps = YES;
    _boldNicknames = NO;
    [self emit];
}

- (NSDictionary<NSString *, id> *)snapshot {
    return @{
        @"fontScale":          @(self.fontScale),
        @"lineSpacing":        @(self.lineSpacing),
        @"bubbleCornerRadius": @(self.bubbleCornerRadius),
        @"density":            @(self.density),
        @"monoTimestamps":     @(self.monoTimestamps),
        @"boldNicknames":      @(self.boldNicknames),
    };
}

- (void)emit {
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:QXReadingPreferencesDidChangeNotification
                                                        object:self];
}

@end
