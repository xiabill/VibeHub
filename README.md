# VibeHub

> 一个 macOS 状态栏 app，把 **AirPods / 蓝牙耳机的媒体键手势** + **2.4G 遥控键盘的物理按键** 统一映射到任意 macOS 键盘 chord。
> 专为 **vibe coding** 工作流设计 —— 戴着 AirPods 单击 stem 触发 Typeless / WhisperKey 录音，左手抓着遥控器 一键截图 / 切窗 / 跳页。
> **代码 100% 由 [Claude Code](https://claude.com/claude-code) 写就。**

`VibeHub = AirPodsRemap + RemoteRemap` —— 合并两个独立项目的功能，共享同一套 chord 引擎，一个 binary、一份权限、一套 UI。

---

## 截图

（待补 —— 菜单栏图标 + 配置面板 TabView）

---

## 两个模块各自做什么

| 模块 | 输入设备 | 监听机制 | 触发点 |
|---|---|---|---|
| **AirPods** | AirPods 系列 / 任何走 AVRCP 协议的蓝牙耳机 | `CGEventTap` 监听 NSSystemDefined 媒体键事件 | 单击 / 双击 / 三击 stem + stem 上下滑（音量+/-） |
| **Remote** | 2.4G USB 遥控键盘（默认 XING WEI 0x1915:0x1025；任意 HID 键盘类设备可切换） | `IOHIDManager` 直接读 HID + `CGEventTap` 吞掉系统原行为 | 方向键×4 / OK / 菜单 / 主页 / 返回 / 语音 / 静音 / 音量+/- 共 12 颗 |

两个模块**独立启停**、独立配置、独立持久化，状态栏图标统一显示运行状态。可以只开 AirPods、只开 Remote、或两个都开。

---

## ⚠️ 兼容性（必看）

### AirPods 模块

| 设备 | 状态 | 说明 |
|---|---|---|
| AirPods 1 / 2 / 3 / 4（普通版） | ✅ 全部工作 | 单/双/三击 + 音量+/- 都能拦 |
| AirPods Max | ✅ 全部工作 | 同普通版 |
| AirPods Pro 1 | ⚠️ 待测试 | 理论上和普通版一样 |
| **AirPods Pro 2 / Pro 3** | ❌ **不支持**（实测） | Apple 把 Pro 2 的 stem 事件**全部**路由到 MediaRemote 私有 IPC，包括音量+/- 也拦不到。所有同类工具（Karabiner-Elements、SiriMote 等）一样失效 |
| 其他蓝牙耳机（非 Apple，各芯片厂商） | ✅ 部分手势可用 | Play/Pause 和音量+/- 全芯片通用；"下一曲""上一曲"多数可用（详见下） |

#### 非 Apple 耳机的逐手势支持

只要耳机走标准 AVRCP 协议接入 macOS，事件就会经过同一条 NSSystemDefined 公开通道，**和芯片厂商无关**（Qualcomm / Airoha / Realtek / 恒玄 BES / Jieli / 华为麒麟 A2 / 索尼 V1 等都一样）。

| 手势 | 非 Apple 耳机 | 原因 |
|---|---|---|
| 单击 = Play/Pause | ✅ 全芯片可用 | AVRCP `PLAY/PAUSE` → `NX_KEYTYPE_PLAY (16)` |
| 音量+ / 音量- | ✅ 全芯片可用 | AVRCP `VOL_UP/DOWN` → `NX_KEYTYPE_SOUND_UP/DOWN (0/1)` |
| 双击 = 下一曲 | ✅ 大部分可用 | AVRCP `TRACK_NEXT` → `NX_KEYTYPE_NEXT (17)` |
| 三击 = 上一曲 | ✅ 大部分可用 | AirPods 三击发 `NX_KEYTYPE_FAST (19)`；非 Apple 耳机的"上一曲"按钮通常发 `NX_KEYTYPE_PREVIOUS (18)`。两者都识别，统一映射到「三击」 |

### Remote 模块

| 硬件 | VID:PID | 状态 |
|---|---|---|
| **XING WEI 2.4G USB 遥控键盘**（默认） | `0x1915:0x1025` | ✅ 全键支持 |
| 其他 2.4G 遥控键盘（通过 USB 接收器，被识别为 HID 键盘） | 任意 | ⚠️ 大概率能用，配置面板「目标设备 → 切换…」选中即可；按某些键没反应说明 HID usage 不在 hardcoded 列表，可改源码或提 issue |
| 蓝牙连接的遥控器 | — | ❌ 不支持（要改代码切换到 IOBluetooth API） |

---

## 安装

### 方式 A：下载 DMG（推荐）

到 [Releases](https://github.com/xiabill/VibeHub/releases) 下载最新的 `VibeHub-x.y.z.dmg`：

1. 双击挂载 → 拖 `VibeHub.app` 到 **Applications** 文件夹
2. 首次启动会被 macOS 拦下（self-signed app）→ 系统设置 → 隐私与安全性 → 拉到最下 → **仍要打开**
3. **授权两个权限**（两个模块各需一个）：
   - **辅助功能** — AirPods 模块 + Remote 模块吞键都需要
   - **输入监听** — Remote 模块读 HID 设备需要
4. 杀掉重启一次：

   ```bash
   pkill -f VibeHub && open /Applications/VibeHub.app
   ```

5. 状态栏出现 `⌘` 图标 = 成功

### 方式 B：从源码构建

需要 Xcode Command Line Tools (`xcode-select --install`)。

```bash
git clone https://github.com/xiabill/VibeHub
cd VibeHub

# 一次性：创建本地 self-signed 证书，让重编后辅助功能权限不丢
./setup-codesign.sh

./build.sh             # 编译 + 签名 + 嵌图标 → VibeHub.app
open VibeHub.app
```

之后再 `./build.sh` 多少次权限都保留（前提是跑过 `setup-codesign.sh`）。

#### 为什么需要 setup-codesign.sh？

macOS 的 TCC（权限数据库）用 app 的 **designated requirement** 作为身份键：

- **ad-hoc 签名**（`codesign --sign -`）→ DR 包含 binary cdhash，重编后 hash 变 → DR 变 → TCC 视作新 app → 权限失效
- **self-signed 证书签名** → DR 包含证书指纹（不变）→ 重编后 hash 变但 DR 不变 → 权限保留

`setup-codesign.sh` 用 OpenSSL 生成一个 10 年有效期的本地证书，导入登录钥匙串并标记为 codeSign 信任。**只在一台电脑上跑一次**。

> 如果你之前装过 AirPodsRemap 或 RemoteRemap，它们的自签证书 build.sh 会自动复用（按优先级 VibeHub → RemoteRemap → AirPodsRemap）。

---

## 配置面板说明

左键状态栏图标 → 打开配置面板，里面有两个 Tab：

### AirPods Tab

- **启动 / 暂停 AirPods 模块** + 辅助功能权限快捷链接
- 5 行映射：单击 / 双击 / 三击 / 音量+ / 音量-
  - 每行：启用 toggle + 按键列表（任意 chord）+ 「点按 / 按住」模式选择
  - **「点按」** = 按一下立刻松开（适合 ⌘C / ⌘V / F13 等普通快捷键）
  - **「按住」** = 按一下进入按住状态，再按一下释放（**专为 Typeless / WhisperKey 这种长按 Opt 录音的应用设计**）
- 重置 AirPods 默认（单击=按住⌥，其他禁用）

### Remote Tab

- **启动 / 暂停 Remote 模块** + 输入监听权限快捷链接
- **目标设备**：默认 XING WEI 0x1915:0x1025；点「切换…」可下拉选择当前已插上的任意 HID 键盘类设备
- 12 行映射，分 3 组：方向 / 确认 / 系统功能 / 音量
- **长按自动重复**：开关 + 启动延迟（200–1500ms）+ 重复间隔（30–500ms）滑块
- 重置 Remote 默认（全部禁用）

### 全局

- 右键状态栏图标 → 快捷菜单：分别启停两个模块、查看当前映射快览、权限设置、开机自启、关于、退出
- 开机自启 toggle 在面板底部

---

## 快速上手

### 场景 A：AirPods + Typeless 语音输入

1. 装好 [Typeless](https://typeless.dev/)，快捷键设为 **按住 Left Option (⌥)**
2. VibeHub AirPods Tab → 单击行：启用、`Left Option ⌥`、模式「按住」（这是默认）
3. 戴上普通 AirPods → 任意输入框 → **单击 stem** → 状态栏图标变红 → 说话 → **再单击 stem** → 文字粘到光标

### 场景 B：2.4G 遥控键盘 + 截图 / 切窗

1. 插入 2.4G 接收器，等 macOS 弹「找到新键盘助手」就关掉（不需要校准）
2. VibeHub Remote Tab → 启动 Remote 模块 → 设备状态变绿
3. 配置：
   - 主页 🏠 → `⌘ + ⇧ + 4`（截图）
   - 菜单 ☰ → `⌘ + Tab`（切窗）
   - 返回 ↩ → `Escape`
4. 按一下试试，立即生效

### 场景 C：AirPods + 遥控器一起用

两个 Tab 各自配置，两个模块同时跑。状态栏图标透明度反映「至少一个在跑」；AirPods 在「按住」状态时图标变红；Remote 等待设备时图标变橙。

---

## 工作原理

`VibeHub.swift`（单文件，~1590 行 Swift / SwiftUI / Cocoa）

### 共享层

| 组件 | 用途 |
|---|---|
| `KeyChoice` + `keyChoices` | 65+ 个可选目标按键（修饰键、F13–F20、A–Z、0–9、方向键等） |
| `modifierKeyMask` | 修饰键 keyCode → CGEventFlags mask 的对应表 |
| `Mapping` struct | 通用映射：`enabled` + `keys: [String]` + `mode: tap/holdToggle` |
| `postChordDownSync/Up` | 同步 chord 输出（AirPods 用，hold 模式需要立即生效） |
| `postChordDownAsync/Up` | 异步 chord 输出（Remote 用，串行后台队列 + 12ms 间隔） |
| `VH_EVENT_MAGIC` | 自家 post 的 CGEvent 带这个 magic 戳，让两个 tap 一眼认出不吞自己 |
| `LaunchAtLogin` | macOS 13+ SMAppService 实现开机自启 |

### AirPods 模块

```
AirPods 媒体键事件（蓝牙 AVRCP → macOS）
   ↓
NSSystemDefined (type=14, subtype=8)
   ↓ AirPodsTap.handle()
解码 data1：高 16 位 = keyCode (16=PLAY, 17=NEXT, 19=PREVIOUS, 0=VOL_UP, 1=VOL_DOWN)
            低 16 位 0xFF00 = down(0x0A) / up(0x0B)
   ↓
AirPodsConfig.single/double/triple/volumeUp/volumeDown
   ↓
- tap 模式 → 模拟 chord down + up（瞬时）
- holdToggle 模式 → 维护 holdingChords 字典，按下时 toggle
   ↓
swallow 原始事件
```

### Remote 模块

```
遥控器按键
   ↓ IOHIDManager（按 VID/PID 匹配）
HID Input Value Callback
   ↓ handleInputValue → 查 remoteButton(usagePage, usage)
RemoteEngine.dispatch(button, isDown)
   ↓
- 若该按键有「passthrough 等价系统事件」（如 OK→Enter, Vol+→NX_KEYTYPE_SOUND_UP）
  → 注册到 swallowSet 让 CGEventTap 吞掉系统这边的事件（防双触发）
- 模拟 chord down + up
- 若 isDown 且 autoRepeat 启用 → 启动重复 Timer
   ↓
CGEvent.post 出去 + sourceUserData 写 VH_EVENT_MAGIC（让 tap 不吞自己）
```

为什么 Remote 不 seize 设备独占接管？因为 self-signed app 拿不到 `com.apple.developer.driverkit.transport.usb` entitlement，seize 会返回 `kIOReturnNotPrivileged`（`0xE00002C1`）。退而求其次用 IOHIDManager 普通 open + CGEventTap 吞掉系统原行为，效果等价 —— 除了系统内核私有路径（语音键→听写）拦不到。

---

## 已知限制

### AirPods 模块

- **AirPods Pro 2 / Pro 3 完全不支持**（stem 事件走 MediaRemote 私有 IPC，所有同类工具都失效）
- **长按 stem（Siri / 降噪切换）拦不到**（系统专用路由）

### Remote 模块

- **🎤 语音键无法完全拦截 macOS 听写** —— macOS 还有一条私有路径把 HID Consumer 0xCF 直接路由到听写守护进程，用户态 CGEventTap 看不到。绕过：系统设置 → 键盘 → 听写 → 把「快捷键」改成「关闭」
- **🎙️ 遥控器自带 USB mic 1–2 分钟自动断流** —— 遥控器固件的硬性 timeout（省电策略）。绕过：第三方听写工具（Typeless 等）改用 Mac 内置麦克风，遥控器只用来按键
- **100ms 吞咽窗口** —— Vol+/-/Mute/方向键 这类映射的「按起」后 100ms 内，主键盘同 keycode 也会被吞（实际极少冲突）

### 通用

- **每次 `./build.sh` 后辅助功能权限失效** —— ad-hoc 签名固有问题；跑一次 `./setup-codesign.sh` 切到 self-signed 证书后永久解决

---

## 项目结构

```
.
├── VibeHub.swift          # 单文件源码（~1590 行）
├── probe.swift            # HID 事件探测器（加新硬件时用）
├── make-icon.swift        # 程序图标生成器（青蓝渐变 ⌘）
├── setup-codesign.sh      # 一次性创建 self-signed 证书
├── build.sh               # 编译 + 签名 → VibeHub.app
├── make-dmg.sh            # 打包 DMG
├── package.sh             # 一键 zip + dmg
├── USAGE.txt              # 用户使用说明（DMG/zip 里的简版）
└── README.md
```

---

## 跟原项目的关系

| 项目 | 状态 | 关系 |
|---|---|---|
| [xiabill/airpods-remap](https://github.com/xiabill/airpods-remap) | 单独维护中 | 只想要 AirPods 映射的用户可以继续装这个 |
| [xiabill/remote-remap](https://github.com/xiabill/remote-remap) | 单独维护中 | 只想要遥控器映射的用户可以继续装这个 |
| **xiabill/VibeHub**（本项目） | **推荐：两边都想用的用户** | 单 binary、单权限、单菜单栏图标，UI 用 TabView |

VibeHub 不会自动迁移老 app 的 UserDefaults 配置，需要重新配一遍（5 个手势 + 12 颗按键，几分钟）。配好后建议把老 app 暂停或退出，避免两个 app 抢同一个 NSSystemDefined 事件源。

---

## 系统要求

- **macOS 13.0** (Ventura) 及以上
- Apple Silicon（arm64；build.sh 默认只编 arm64，需要 universal 加 `-target x86_64-apple-macos13.0` lipo）

---

## License

[MIT](LICENSE) — 自由 fork / 改 / 商用。代码全开放，**欢迎提 issue / PR**。

---

**项目主页：** <https://github.com/xiabill/VibeHub>
**问题反馈：** [Issues](https://github.com/xiabill/VibeHub/issues)
