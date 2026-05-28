//
//  QXPrivacyDashboard.h
//  QCCore
//
//  喜聊隐私面板。汇总 App 的数据收集行为说明、本地数据
//  的使用范围、第三方 SDK 列表，并以可视化条目暴露给用户。
//  这些信息纯本地静态构建，不发起任何网络请求。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, QXPrivacyDataCategory) {
    QXPrivacyDataCategoryAccount     = 0,
    QXPrivacyDataCategoryContact     = 1,
    QXPrivacyDataCategoryMessages    = 2,
    QXPrivacyDataCategoryMedia       = 3,
    QXPrivacyDataCategoryDevice      = 4,
    QXPrivacyDataCategoryDiagnostics = 5,
    QXPrivacyDataCategoryLocation    = 6,
};

typedef NS_ENUM(NSInteger, QXPrivacyDataPurpose) {
    QXPrivacyDataPurposeAppFunctionality = 0,
    QXPrivacyDataPurposeAnalytics        = 1,
    QXPrivacyDataPurposePersonalization  = 2,
    QXPrivacyDataPurposeAccountSecurity  = 3,
};

@interface QXPrivacyEntry : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, assign) QXPrivacyDataCategory category;
@property (nonatomic, copy) NSArray<NSNumber *> *purposes;        // QXPrivacyDataPurpose
@property (nonatomic, assign) BOOL leavesDevice;                  // 是否离开设备
@property (nonatomic, assign) BOOL linkedToUser;                  // 是否与用户身份绑定
@property (nonatomic, copy) NSString *retention;                  // 保留时长描述
@property (nonatomic, copy) NSString *userControl;                // 用户控制方式
@end

@interface QXPrivacyThirdParty : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *purpose;
@property (nonatomic, copy) NSString *privacyURL;
@property (nonatomic, copy) NSArray<NSString *> *dataItems;
@end

@interface QXPrivacyDashboard : NSObject

+ (instancetype)sharedDashboard;

- (NSArray<QXPrivacyEntry *> *)entries;
- (NSArray<QXPrivacyThirdParty *> *)thirdParties;

- (NSString *)userVisibleSummary;
- (NSData *)serializeJSON;

@end

NS_ASSUME_NONNULL_END
