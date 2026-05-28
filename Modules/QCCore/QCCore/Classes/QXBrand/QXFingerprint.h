//
//  QXFingerprint.h
//  QCCore
//
//  喜聊诊断标记。仅用于本地诊断报告（崩溃复现、卡顿统计）
//  在用户**主动**导出报告时附带，使开发者能在多份报告中识别
//  出"是否同一次复现"。该标记由随机 UUID 生成，不来源于
//  IDFA / IDFV / 设备硬件特征，不在网络请求中携带，不与
//  账号绑定。用户可在「设置 - 反馈与诊断」中重置或清除。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QXFingerprint : NSObject

+ (instancetype)sharedFingerprint;

/// 获取本地诊断标记。**仅当用户主动触发导出诊断时调用**；
/// 首次调用会生成并以 UUID 形式落地到 NSUserDefaults。
- (NSString *)diagnosticsTag;

/// 重置诊断标记（用户在反馈页主动点击）。
- (void)resetTag;

/// 当前会话标记，仅活在内存里，每次启动重新生成。
- (NSString *)sessionTag;

@end

NS_ASSUME_NONNULL_END
