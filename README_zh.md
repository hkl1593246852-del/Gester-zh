# Gester 简体中文本地化补丁

## 改了什么

| 文件 | 改动 |
|---|---|
| `src/zh-Hans.lproj/Localizable.strings` | **新增**，191 条完整中文翻译 |
| `src/Info.plist` | `CFBundleLocalizations` 加入 `zh-Hans` |
| `src/SettingsVC.m` | 语言选择器加入「简体中文」 |
| `Gester.xcodeproj/project.pbxproj` | `knownRegions` 加 `zh-Hans`，variant group 加子项 |
| `src/en.lproj/Localizable.strings` | 修复 3 条 mojibake（`â` 乱码还原成 `—` / `→`） |

## 为什么原来没有中文

两个原因叠加：

1. `src/` 下只有 `ar / en / ko / ru / tr / uk / vi` 七个 `.lproj`，没有 `zh-Hans.lproj`
2. `Info.plist` 的 `CFBundleLocalizations` 也只列了这七个，iOS 不会把「简体中文」放进系统语言列表
3. `SettingsVC.m` 的语言选择器是硬编码数组，同样只有七项

三处都补上，中文才完整。

## 编译

### 方式一：build.sh（推荐，Windows/Linux 上也能出包）

脚本里的这段会自动把 `src/*.lproj` 全部拷进 app 包：

```bash
for lproj in "$ROOT"/src/*.lproj; do
    [ -d "$lproj" ] && cp -R "$lproj" "$APP/"
done
```

所以新增的 `zh-Hans.lproj` 不用改脚本，直接：

```bash
cd Gester-main
./build.sh
```

需要 `clang` + iOS SDK，以及 `ldid`（TrollStore 签名用）。

### 方式二：Xcode

打开 `Gester.xcodeproj`，product.pbxproj 已经加好 `zh-Hans`，选中 target → Build 即可。

### 方式三：xcodegen 重新生成工程

`project.yml` 里 `sources: - path: src` 会自动扫描所有 `.lproj`，重新 `xcodegen generate` 也会带上中文，不会丢掉。

## 怎么切换语言

App 内：**设置 → 第 4 段第 3 行「语言」→ 简体中文 → 重启 Gester**。

原理：`SettingsVC.m` 往 `NSUserDefaults` 写入 `BQLanguageOverride` 和 `AppleLanguages`，`NSBundle` 下次启动时按这个顺序找本地化。

系统层面：iOS 设置 → 通用 → 语言与地区，简体中文已在支持列表里（`CFBundleLocalizations` 声明后才会出现）。

## 验证清单

编译完解包检查：

```bash
unzip -l Gester-2.4.1.ipa | grep lproj
```

应该看到九行，包含：

```
Payload/BQTool.app/zh-Hans.lproj/Localizable.strings
```

进去检查条目数：

```bash
cd Payload/BQTool.app
plutil -convert json -o - zh-Hans.lproj/Localizable.strings | jq 'length'
```

输出 `191` 就对了。

运行后如果界面还是英文，按顺序排查：

1. 系统设置里语言是不是中文
2. App 内「设置 → 语言」是否选了简体中文
3. 选完有没有**杀掉进程重开**（不是切后台，是划掉）
4. `Info.plist` 里 `CFBundleLocalizations` 是否真的包含 `zh-Hans`
5. app 包里 `zh-Hans.lproj` 是否被打进去

## 翻译约定

技术名词保留英文，方便对照日志和文档：

| 保留原文 | 说明 |
|---|---|
| Gestalt / MobileGestalt | 系统设备信息框架名 |
| PosterBoard | 壁纸服务进程名 |
| CacheExtra / CacheData | MG 缓存字段名 |
| Stage Manager / Medusa | 台前调度 |
| SpringBoard | 桌面进程 |
| MDM | 移动设备管理 |
| KAMUI | 原作者署名 |

`Respring` 统一译成「注销重启」，这是国内越狱圈的通行叫法。

## 目录结构

```
Gester-main/
├── src/
│   ├── en.lproj/Localizable.strings      191 条（已修 mojibake）
│   ├── zh-Hans.lproj/Localizable.strings 191 条（新增）
│   ├── ar.lproj / ko.lproj / ru.lproj /
│   │   tr.lproj / uk.lproj / vi.lproj
│   ├── Info.plist                        已加 zh-Hans
│   ├── SettingsVC.m                      已加简中选项
│   └── ...其余源码未动
├── Gester.xcodeproj/                     已加 zh-Hans
├── build.sh                              无需改动
└── project.yml                           无需改动
```
