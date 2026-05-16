# QX iOS

QX 是一款基于自研 IM 协议的即时通讯客户端。

## 构建

```bash
pod install
open QXiOS.xcworkspace
```

要求：Xcode 15+、iOS 13.0+、CocoaPods 1.11+。

## 项目结构

- `QX/` — 主 App target
- `Modules/QCCore` — 通用 UI、工具与会话/联系人主流程
- `Modules/QCAuth` — 登录注册
- `Modules/QCContacts` — 通讯录与好友
- `Modules/QCData` — 数据接入层（HTTP/缓存）
- `Modules/QCFile` — 文件传输
- `Modules/QCGroup` — 群组管理
- `Modules/QCVideo` — 小视频/媒体
- `Modules/QCIM` — IM SDK
- `NotificationService` / `NotificationContent` — 推送扩展

## 主题

主色：`#1E90FF`（DodgerBlue），定义于 `QCCore/QCAppConfig.m`。

## 隐私

App 隐私清单位于 `privacy_manifests/PrivacyInfo.xcprivacy`，在 `pod install` 阶段会自动注入到每个 Pod target。提交 App Store 前请根据 App 实际数据收集行为校对清单。
