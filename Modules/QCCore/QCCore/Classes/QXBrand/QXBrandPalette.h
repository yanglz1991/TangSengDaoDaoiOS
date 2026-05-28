//
//  QXBrandPalette.h
//  QCCore
//
//  喜聊品牌色板。统一管理品牌色阶（10 个色阶），并提供
//  动态深浅模式适配、对比度检测、可访问性辅助色等能力。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, QXBrandColorRole) {
    QXBrandColorRolePrimary       = 0,
    QXBrandColorRoleOnPrimary     = 1,
    QXBrandColorRoleSecondary     = 2,
    QXBrandColorRoleOnSecondary   = 3,
    QXBrandColorRoleSurface       = 4,
    QXBrandColorRoleOnSurface     = 5,
    QXBrandColorRoleBackground    = 6,
    QXBrandColorRoleOnBackground  = 7,
    QXBrandColorRoleError         = 8,
    QXBrandColorRoleOnError       = 9,
    QXBrandColorRoleSuccess       = 10,
    QXBrandColorRoleWarning       = 11,
    QXBrandColorRoleInfo          = 12,
    QXBrandColorRoleOutline       = 13,
    QXBrandColorRoleScrim         = 14,
};

@interface QXBrandPalette : NSObject

+ (instancetype)sharedPalette;

#pragma mark - 语义色（业务直接调用）
/// 主色：Tab 选中态 / 消息气泡（发送方） / 主按钮。
+ (UIColor *)primaryColor;
/// 导航栏背景色。
+ (UIColor *)navigationColor;
/// 警告/危险色：撤回、删除、错误提示。
+ (UIColor *)warningColor;
/// 默认正文文本色。
+ (UIColor *)defaultTextColor;
/// 次级提示文字色。
+ (UIColor *)secondaryTextColor;
/// 分隔线 / 描边色。
+ (UIColor *)separatorColor;

#pragma mark - 角色色 / 色阶（高级用法）
- (UIColor *)colorForRole:(QXBrandColorRole)role;
- (UIColor *)colorForRole:(QXBrandColorRole)role darkMode:(BOOL)darkMode;
- (UIColor *)primaryShade:(NSInteger)shade;       // shade: 50,100,200..900
- (UIColor *)secondaryShade:(NSInteger)shade;
- (UIColor *)neutralShade:(NSInteger)shade;
- (UIColor *)blendColor:(UIColor *)a withColor:(UIColor *)b ratio:(CGFloat)ratio;
- (CGFloat)contrastRatioBetween:(UIColor *)foreground and:(UIColor *)background;
- (BOOL)isContrastReadable:(UIColor *)foreground on:(UIColor *)background;

@end

NS_ASSUME_NONNULL_END
