//
//  QXBrandPalette.m
//  QCCore
//

#import "QXBrandPalette.h"

@interface QXBrandPalette ()
@property (nonatomic, strong) NSDictionary<NSNumber *, NSArray<UIColor *> *> *shadeMap;
@property (nonatomic, strong) NSDictionary<NSNumber *, UIColor *> *lightRoleMap;
@property (nonatomic, strong) NSDictionary<NSNumber *, UIColor *> *darkRoleMap;
@end

@implementation QXBrandPalette

+ (instancetype)sharedPalette {
    static QXBrandPalette *p = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        p = [[QXBrandPalette alloc] initPrivate];
    });
    return p;
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        [self buildShades];
        [self buildRoleMaps];
    }
    return self;
}

#pragma mark - Build

- (UIColor *)rgb:(NSInteger)hex {
    CGFloat r = ((hex >> 16) & 0xFF) / 255.0;
    CGFloat g = ((hex >>  8) & 0xFF) / 255.0;
    CGFloat b = ( hex        & 0xFF) / 255.0;
    return [UIColor colorWithRed:r green:g blue:b alpha:1.0];
}

- (void)buildShades {
    // 主色：青蓝 (Sky Blue) — 50…900
    NSArray<UIColor *> *primary = @[
        [self rgb:0xF0F9FF], [self rgb:0xE0F2FE], [self rgb:0xBAE6FD],
        [self rgb:0x7DD3FC], [self rgb:0x38BDF8], [self rgb:0x0EA5E9],
        [self rgb:0x0284C7], [self rgb:0x0369A1], [self rgb:0x075985], [self rgb:0x0C4A6E],
    ];
    // 次色：暖橙（保留橙系点缀色）
    NSArray<UIColor *> *secondary = @[
        [self rgb:0xFFF7ED], [self rgb:0xFFEDD5], [self rgb:0xFED7AA],
        [self rgb:0xFDBA74], [self rgb:0xFB923C], [self rgb:0xF97316],
        [self rgb:0xEA580C], [self rgb:0xC2410C], [self rgb:0x9A3412], [self rgb:0x7C2D12],
    ];
    // 中性灰
    NSArray<UIColor *> *neutral = @[
        [self rgb:0xF9FAFB], [self rgb:0xF3F4F6], [self rgb:0xE5E7EB],
        [self rgb:0xD1D5DB], [self rgb:0x9CA3AF], [self rgb:0x6B7280],
        [self rgb:0x4B5563], [self rgb:0x374151], [self rgb:0x1F2937], [self rgb:0x111827],
    ];
    self.shadeMap = @{ @(0): primary, @(1): secondary, @(2): neutral };
}

- (void)buildRoleMaps {
    self.lightRoleMap = @{
        @(QXBrandColorRolePrimary):       [self rgb:0x0EA5E9],   // Sky Blue
        @(QXBrandColorRoleOnPrimary):     [UIColor whiteColor],
        @(QXBrandColorRoleSecondary):     [self rgb:0xF97316],
        @(QXBrandColorRoleOnSecondary):   [UIColor whiteColor],
        @(QXBrandColorRoleSurface):       [UIColor whiteColor],
        @(QXBrandColorRoleOnSurface):     [self rgb:0x1F2937],
        @(QXBrandColorRoleBackground):    [self rgb:0xF6F8FB],
        @(QXBrandColorRoleOnBackground):  [self rgb:0x1F2937],
        @(QXBrandColorRoleError):         [self rgb:0xE11D48],   // Rose
        @(QXBrandColorRoleOnError):       [UIColor whiteColor],
        @(QXBrandColorRoleSuccess):       [self rgb:0x10B981],
        @(QXBrandColorRoleWarning):       [self rgb:0xF59E0B],
        @(QXBrandColorRoleInfo):          [self rgb:0x0EA5E9],
        @(QXBrandColorRoleOutline):       [self rgb:0xE5E7EB],
        @(QXBrandColorRoleScrim):         [UIColor colorWithWhite:0 alpha:0.32],
    };
    self.darkRoleMap = @{
        @(QXBrandColorRolePrimary):       [self rgb:0x38BDF8],
        @(QXBrandColorRoleOnPrimary):     [self rgb:0x0C4A6E],
        @(QXBrandColorRoleSecondary):     [self rgb:0xFB923C],
        @(QXBrandColorRoleOnSecondary):   [self rgb:0x7C2D12],
        @(QXBrandColorRoleSurface):       [self rgb:0x111827],
        @(QXBrandColorRoleOnSurface):     [self rgb:0xE5E7EB],
        @(QXBrandColorRoleBackground):    [self rgb:0x0B1220],
        @(QXBrandColorRoleOnBackground):  [self rgb:0xE5E7EB],
        @(QXBrandColorRoleError):         [self rgb:0xFB7185],
        @(QXBrandColorRoleOnError):       [self rgb:0x4C0519],
        @(QXBrandColorRoleSuccess):       [self rgb:0x34D399],
        @(QXBrandColorRoleWarning):       [self rgb:0xFBBF24],
        @(QXBrandColorRoleInfo):          [self rgb:0x7DD3FC],
        @(QXBrandColorRoleOutline):       [self rgb:0x374151],
        @(QXBrandColorRoleScrim):         [UIColor colorWithWhite:0 alpha:0.6],
    };
}

#pragma mark - 语义色（类方法）

+ (UIColor *)primaryColor       { return [[QXBrandPalette sharedPalette] colorForRole:QXBrandColorRolePrimary]; }
+ (UIColor *)navigationColor    { return [[QXBrandPalette sharedPalette] primaryShade:600]; }   // #0284C7
+ (UIColor *)warningColor       { return [[QXBrandPalette sharedPalette] colorForRole:QXBrandColorRoleError]; }
+ (UIColor *)defaultTextColor   { return [[QXBrandPalette sharedPalette] neutralShade:800]; }   // #1F2937
+ (UIColor *)secondaryTextColor { return [[QXBrandPalette sharedPalette] neutralShade:500]; }   // #6B7280
+ (UIColor *)separatorColor     { return [[QXBrandPalette sharedPalette] neutralShade:200]; }   // #E5E7EB

#pragma mark - Public

- (UIColor *)colorForRole:(QXBrandColorRole)role {
    BOOL isDark = NO;
    if (@available(iOS 13.0, *)) {
        UIWindow *window = [[UIApplication sharedApplication].windows firstObject];
        isDark = window.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark;
    }
    return [self colorForRole:role darkMode:isDark];
}

- (UIColor *)colorForRole:(QXBrandColorRole)role darkMode:(BOOL)darkMode {
    NSDictionary *map = darkMode ? self.darkRoleMap : self.lightRoleMap;
    return map[@(role)] ?: [UIColor blackColor];
}

- (UIColor *)primaryShade:(NSInteger)shade   { return [self shadeFromGroup:0 shade:shade]; }
- (UIColor *)secondaryShade:(NSInteger)shade { return [self shadeFromGroup:1 shade:shade]; }
- (UIColor *)neutralShade:(NSInteger)shade   { return [self shadeFromGroup:2 shade:shade]; }

- (UIColor *)shadeFromGroup:(NSInteger)group shade:(NSInteger)shade {
    NSArray<UIColor *> *list = self.shadeMap[@(group)];
    NSInteger index = 5;
    if      (shade <= 50)  index = 0;
    else if (shade <= 100) index = 1;
    else if (shade <= 200) index = 2;
    else if (shade <= 300) index = 3;
    else if (shade <= 400) index = 4;
    else if (shade <= 500) index = 5;
    else if (shade <= 600) index = 6;
    else if (shade <= 700) index = 7;
    else if (shade <= 800) index = 8;
    else                   index = 9;
    if (index >= (NSInteger)list.count) {
        index = list.count - 1;
    }
    return list[index];
}

- (UIColor *)blendColor:(UIColor *)a withColor:(UIColor *)b ratio:(CGFloat)ratio {
    if (ratio < 0) ratio = 0;
    if (ratio > 1) ratio = 1;
    CGFloat ar = 0, ag = 0, ab = 0, aa = 1;
    CGFloat br = 0, bg = 0, bb = 0, ba = 1;
    [a getRed:&ar green:&ag blue:&ab alpha:&aa];
    [b getRed:&br green:&bg blue:&bb alpha:&ba];
    CGFloat r = ar * (1 - ratio) + br * ratio;
    CGFloat g = ag * (1 - ratio) + bg * ratio;
    CGFloat bl = ab * (1 - ratio) + bb * ratio;
    CGFloat al = aa * (1 - ratio) + ba * ratio;
    return [UIColor colorWithRed:r green:g blue:bl alpha:al];
}

- (CGFloat)relativeLuminance:(UIColor *)color {
    CGFloat r = 0, g = 0, b = 0, a = 1;
    [color getRed:&r green:&g blue:&b alpha:&a];
    CGFloat (^chan)(CGFloat) = ^CGFloat(CGFloat c) {
        return c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4);
    };
    return 0.2126 * chan(r) + 0.7152 * chan(g) + 0.0722 * chan(b);
}

- (CGFloat)contrastRatioBetween:(UIColor *)foreground and:(UIColor *)background {
    CGFloat l1 = [self relativeLuminance:foreground];
    CGFloat l2 = [self relativeLuminance:background];
    CGFloat lighter = MAX(l1, l2);
    CGFloat darker  = MIN(l1, l2);
    return (lighter + 0.05) / (darker + 0.05);
}

- (BOOL)isContrastReadable:(UIColor *)foreground on:(UIColor *)background {
    return [self contrastRatioBetween:foreground and:background] >= 4.5;
}

@end
