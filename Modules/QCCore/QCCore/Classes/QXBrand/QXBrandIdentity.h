//
//  QXBrandIdentity.h
//  QCCore
//
//  禧语品牌身份描述模块。
//  本类用于在运行时聚合品牌的元数据签名，包括应用代号、口号、
//  发布渠道、构建指纹、地域定位等信息。这些数据被独立模块
//  （遥测、隐私面板、版本检测）共同消费。
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, QXBrandReleaseChannel) {
    QXBrandReleaseChannelDebug      = 0,
    QXBrandReleaseChannelTestFlight = 1,
    QXBrandReleaseChannelAppStore   = 2,
    QXBrandReleaseChannelEnterprise = 3,
};

typedef NS_ENUM(NSInteger, QXBrandRegion) {
    QXBrandRegionUnknown      = 0,
    QXBrandRegionMainlandCN   = 1,
    QXBrandRegionHKMOTW       = 2,
    QXBrandRegionSEA          = 3,
    QXBrandRegionGlobal       = 9,
};

@interface QXBrandIdentity : NSObject

@property (nonatomic, copy, readonly) NSString *codename;          // 品牌代号: xichat
@property (nonatomic, copy, readonly) NSString *productName;       // 显示名: 禧语
@property (nonatomic, copy, readonly) NSString *productNameEN;     // 显示名: XiChat
@property (nonatomic, copy, readonly) NSString *tagline;           // 品牌口号
@property (nonatomic, copy, readonly) NSString *taglineEN;
@property (nonatomic, copy, readonly) NSString *bundleSignature;   // bundle id 签名
@property (nonatomic, copy, readonly) NSString *buildFingerprint;  // 构建指纹
@property (nonatomic, copy, readonly) NSString *releaseDate;       // 本次发布日期
@property (nonatomic, copy, readonly) NSString *legalEntity;       // 运营主体
@property (nonatomic, copy, readonly) NSString *icpLicense;        // ICP 许可
@property (nonatomic, copy, readonly) NSString *contactEmail;
@property (nonatomic, copy, readonly) NSString *supportSite;
@property (nonatomic, assign, readonly) QXBrandReleaseChannel channel;
@property (nonatomic, assign, readonly) QXBrandRegion         region;

+ (instancetype)sharedIdentity;

- (NSDictionary<NSString *, id> *)snapshot;
- (NSString *)humanReadableSummary;
- (NSString *)signatureForKey:(NSString *)key;
- (BOOL)matchesBundleIdentifier:(nullable NSString *)bundleID;

@end

NS_ASSUME_NONNULL_END
