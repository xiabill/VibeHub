import Cocoa
import SwiftUI
import IOKit
import IOKit.hid
import CoreGraphics
import Combine
import ServiceManagement
import Darwin

// MARK: - 共享：按键目录（chord 目标按键可选项）

struct KeyChoice: Identifiable, Hashable {
    let id: String
    let label: String
    let keyCode: UInt16
    let flags: UInt64
}

let keyChoices: [KeyChoice] = [
    .init(id: "lopt",    label: "Left Option ⌥",   keyCode: 58, flags: 0),
    .init(id: "ropt",    label: "Right Option ⌥",  keyCode: 61, flags: 0),
    .init(id: "lcmd",    label: "Left Command ⌘",  keyCode: 55, flags: 0),
    .init(id: "rcmd",    label: "Right Command ⌘", keyCode: 54, flags: 0),
    .init(id: "lctrl",   label: "Left Control ⌃",  keyCode: 59, flags: 0),
    .init(id: "rctrl",   label: "Right Control ⌃", keyCode: 62, flags: 0),
    .init(id: "lshift",  label: "Left Shift ⇧",    keyCode: 56, flags: 0),
    .init(id: "rshift",  label: "Right Shift ⇧",   keyCode: 60, flags: 0),
    .init(id: "fn",      label: "Fn",              keyCode: 63, flags: 0),

    .init(id: "f13", label: "F13", keyCode: 105, flags: 0),
    .init(id: "f14", label: "F14", keyCode: 107, flags: 0),
    .init(id: "f15", label: "F15", keyCode: 113, flags: 0),
    .init(id: "f16", label: "F16", keyCode: 106, flags: 0),
    .init(id: "f17", label: "F17", keyCode:  64, flags: 0),
    .init(id: "f18", label: "F18", keyCode:  79, flags: 0),
    .init(id: "f19", label: "F19", keyCode:  80, flags: 0),
    .init(id: "f20", label: "F20", keyCode:  90, flags: 0),

    .init(id: "space",   label: "Space 空格",         keyCode: 49,  flags: 0),
    .init(id: "return",  label: "Return / Enter ↵",   keyCode: 36,  flags: 0),
    .init(id: "esc",     label: "Escape",             keyCode: 53,  flags: 0),
    .init(id: "tab",     label: "Tab",                keyCode: 48,  flags: 0),
    .init(id: "delete",  label: "Delete ⌫ (退格)",    keyCode: 51,  flags: 0),
    .init(id: "fwddel",  label: "Forward Delete ⌦",   keyCode: 117, flags: 0),

    .init(id: "up",      label: "↑ Up Arrow",         keyCode: 126, flags: 0),
    .init(id: "down",    label: "↓ Down Arrow",       keyCode: 125, flags: 0),
    .init(id: "left",    label: "← Left Arrow",       keyCode: 123, flags: 0),
    .init(id: "right",   label: "→ Right Arrow",      keyCode: 124, flags: 0),
    .init(id: "pgup",    label: "Page Up",            keyCode: 116, flags: 0),
    .init(id: "pgdn",    label: "Page Down",          keyCode: 121, flags: 0),
    .init(id: "home",    label: "Home",               keyCode: 115, flags: 0),
    .init(id: "end",     label: "End",                keyCode: 119, flags: 0),

    .init(id: "n1", label: "1", keyCode: 18, flags: 0),
    .init(id: "n2", label: "2", keyCode: 19, flags: 0),
    .init(id: "n3", label: "3", keyCode: 20, flags: 0),
    .init(id: "n4", label: "4", keyCode: 21, flags: 0),
    .init(id: "n5", label: "5", keyCode: 23, flags: 0),
    .init(id: "n6", label: "6", keyCode: 22, flags: 0),
    .init(id: "n7", label: "7", keyCode: 26, flags: 0),
    .init(id: "n8", label: "8", keyCode: 28, flags: 0),
    .init(id: "n9", label: "9", keyCode: 25, flags: 0),
    .init(id: "n0", label: "0", keyCode: 29, flags: 0),

    .init(id: "kA", label: "A", keyCode:  0, flags: 0),
    .init(id: "kB", label: "B", keyCode: 11, flags: 0),
    .init(id: "kC", label: "C", keyCode:  8, flags: 0),
    .init(id: "kD", label: "D", keyCode:  2, flags: 0),
    .init(id: "kE", label: "E", keyCode: 14, flags: 0),
    .init(id: "kF", label: "F", keyCode:  3, flags: 0),
    .init(id: "kG", label: "G", keyCode:  5, flags: 0),
    .init(id: "kH", label: "H", keyCode:  4, flags: 0),
    .init(id: "kI", label: "I", keyCode: 34, flags: 0),
    .init(id: "kJ", label: "J", keyCode: 38, flags: 0),
    .init(id: "kK", label: "K", keyCode: 40, flags: 0),
    .init(id: "kL", label: "L", keyCode: 37, flags: 0),
    .init(id: "kM", label: "M", keyCode: 46, flags: 0),
    .init(id: "kN", label: "N", keyCode: 45, flags: 0),
    .init(id: "kO", label: "O", keyCode: 31, flags: 0),
    .init(id: "kP", label: "P", keyCode: 35, flags: 0),
    .init(id: "kQ", label: "Q", keyCode: 12, flags: 0),
    .init(id: "kR", label: "R", keyCode: 15, flags: 0),
    .init(id: "kS", label: "S", keyCode:  1, flags: 0),
    .init(id: "kT", label: "T", keyCode: 17, flags: 0),
    .init(id: "kU", label: "U", keyCode: 32, flags: 0),
    .init(id: "kV", label: "V", keyCode:  9, flags: 0),
    .init(id: "kW", label: "W", keyCode: 13, flags: 0),
    .init(id: "kX", label: "X", keyCode:  7, flags: 0),
    .init(id: "kY", label: "Y", keyCode: 16, flags: 0),
    .init(id: "kZ", label: "Z", keyCode:  6, flags: 0),
]

func keyChoice(_ id: String) -> KeyChoice? {
    keyChoices.first { $0.id == id }
}

// 修饰键 keyCode → CGEventFlags。post 修饰键时必须把对应 mask 加到 flags 里，
// 系统才认为该修饰键真的"按下"。Typeless 之类监听 Opt 状态的应用就靠这个。
private let modifierKeyMask: [UInt16: CGEventFlags] = [
    58: .maskAlternate,    // Left Option ⌥
    61: .maskAlternate,    // Right Option ⌥
    55: .maskCommand,      // Left Command ⌘
    54: .maskCommand,      // Right Command ⌘
    59: .maskControl,      // Left Control ⌃
    62: .maskControl,      // Right Control ⌃
    56: .maskShift,        // Left Shift ⇧
    60: .maskShift,        // Right Shift ⇧
    63: .maskSecondaryFn,  // Fn
]

// MARK: - 共享：通用 Mapping 结构

enum MappingMode: String, Codable, CaseIterable {
    case tap          // 按一下：down + up（瞬时）
    case holdToggle   // 按一下按住，再按一下释放；仅 AirPods 模块使用
}

struct Mapping: Codable, Equatable {
    var enabled: Bool
    var keys: [String]
    var mode: MappingMode

    init(enabled: Bool = false, keys: [String] = [], mode: MappingMode = .tap) {
        self.enabled = enabled
        self.keys = keys
        self.mode = mode
    }
}

// MARK: - 共享：NX_KEYTYPE 常量

private let NX_KEYTYPE_SOUND_UP:   Int32 = 0
private let NX_KEYTYPE_SOUND_DOWN: Int32 = 1
private let NX_KEYTYPE_MUTE:       Int32 = 7
private let NX_KEYTYPE_PLAY:       Int32 = 16
private let NX_KEYTYPE_NEXT:       Int32 = 17
// AirPods 三击实测发的是 keyCode 19（IOKit 头里这个值其实是 NX_KEYTYPE_FAST，
// 而 NX_KEYTYPE_PREVIOUS=18）。非 Apple 耳机的"上一曲"按钮多数发 18，目前不处理。
private let NX_KEYTYPE_PREVIOUS:   Int32 = 19

// MARK: - 共享：自家事件 magic（让 tap 识别自己 post 的事件，避免自吞）

private let VH_EVENT_MAGIC: Int64 = 0x56484D50  // "VHMP" ASCII

// MARK: - 共享：chord post（CGEvent）

/// 关键点 1：始终显式设置 flags，避免事件继承 hidSystemState 残留的修饰键状态。
/// 否则 Return 在某些 IM 应用（如微信）会被识别成 Shift/Cmd+Return（换行）。
/// 关键点 2：post 修饰键时 flags 必须包含对应 mask，系统才认为修饰键真的按下。
private func postKeyDown(keyCode: UInt16, flags: UInt64) {
    let src = CGEventSource(stateID: .hidSystemState)
    let down = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: true)
    var f = CGEventFlags(rawValue: flags)
    if let modMask = modifierKeyMask[keyCode] { f.insert(modMask) }
    down?.flags = f
    down?.setIntegerValueField(.eventSourceUserData, value: VH_EVENT_MAGIC)
    down?.post(tap: .cghidEventTap)
}

private func postKeyUp(keyCode: UInt16, flags: UInt64) {
    let src = CGEventSource(stateID: .hidSystemState)
    let up = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: false)
    up?.flags = CGEventFlags(rawValue: flags)
    up?.setIntegerValueField(.eventSourceUserData, value: VH_EVENT_MAGIC)
    up?.post(tap: .cghidEventTap)
}

/// 同步 chord 输出（AirPods 用，hold 模式需要立即生效）。
/// 按数组顺序逐键 down，修饰键 flag 累加；reverse 顺序 up。
private func postChordDownSync(keyIds: [String]) {
    var acc: CGEventFlags = []
    for id in keyIds {
        guard let c = keyChoice(id) else { continue }
        let base = CGEventFlags(rawValue: c.flags).union(acc).rawValue
        postKeyDown(keyCode: c.keyCode, flags: base)
        if let mod = modifierKeyMask[c.keyCode] { acc.insert(mod) }
    }
}

private func postChordUpSync(keyIds: [String]) {
    let choices = keyIds.compactMap { keyChoice($0) }
    var acc: CGEventFlags = []
    for c in choices { if let mod = modifierKeyMask[c.keyCode] { acc.insert(mod) } }
    for c in choices.reversed() {
        if let mod = modifierKeyMask[c.keyCode] { acc.remove(mod) }
        let base = CGEventFlags(rawValue: c.flags).union(acc).rawValue
        postKeyUp(keyCode: c.keyCode, flags: base)
    }
}

/// 异步 chord 输出（Remote 用，串行后台队列 + 12ms 间隔，保证修饰键 flags 累加被系统看到）。
private let chordQueue = DispatchQueue(label: "VibeHub.chord", qos: .userInteractive)
private let perKeyDelayUS: useconds_t = 12_000

private func postChordDownAsync(keyIds: [String]) {
    let choices = keyIds.compactMap { keyChoice($0) }
    let baseFlagsArr: [UInt64] = {
        var acc: CGEventFlags = []
        return choices.map { c in
            let f = CGEventFlags(rawValue: c.flags).union(acc).rawValue
            if let mod = modifierKeyMask[c.keyCode] { acc.insert(mod) }
            return f
        }
    }()
    chordQueue.async {
        for (i, c) in choices.enumerated() {
            postKeyDown(keyCode: c.keyCode, flags: baseFlagsArr[i])
            if i < choices.count - 1 { usleep(perKeyDelayUS) }
        }
    }
}

private func postChordUpAsync(keyIds: [String]) {
    let choices = keyIds.compactMap { keyChoice($0) }
    var acc: CGEventFlags = []
    for c in choices { if let mod = modifierKeyMask[c.keyCode] { acc.insert(mod) } }
    let reversed = Array(choices.reversed())
    let baseFlagsArr: [UInt64] = reversed.map { c in
        if let mod = modifierKeyMask[c.keyCode] { acc.remove(mod) }
        return CGEventFlags(rawValue: c.flags).union(acc).rawValue
    }
    chordQueue.async {
        for (i, c) in reversed.enumerated() {
            postKeyUp(keyCode: c.keyCode, flags: baseFlagsArr[i])
            if i < reversed.count - 1 { usleep(perKeyDelayUS) }
        }
    }
}

// MARK: - AirPods 模块：配置（5 个手势）

final class AirPodsConfig: ObservableObject {
    static let shared = AirPodsConfig()
    private let storeKey   = "vibehub_airpods_v1"
    private let enabledKey = "vibehub_airpods_enabled"

    @Published var single: Mapping     { didSet { save() } }
    @Published var double: Mapping     { didSet { save() } }
    @Published var triple: Mapping     { didSet { save() } }
    @Published var volumeUp: Mapping   { didSet { save() } }
    @Published var volumeDown: Mapping { didSet { save() } }

    /// 子模块是否启用（UI/菜单可切换；持久化）
    @Published var moduleEnabled: Bool {
        didSet { UserDefaults.standard.set(moduleEnabled, forKey: enabledKey) }
    }

    private init() {
        // 默认：单击 = 按住 Opt（Typeless 友好）
        var s  = Mapping(enabled: true,  keys: ["lopt"], mode: .holdToggle)
        var d  = Mapping(enabled: false, keys: ["f14"])
        var t  = Mapping(enabled: false, keys: ["f15"])
        var vu = Mapping(enabled: false, keys: ["f16"])
        var vd = Mapping(enabled: false, keys: ["f17"])
        if let data = UserDefaults.standard.data(forKey: storeKey),
           let dict = try? JSONDecoder().decode([String: Mapping].self, from: data) {
            if let v = dict["single"]     { s  = v }
            if let v = dict["double"]     { d  = v }
            if let v = dict["triple"]     { t  = v }
            if let v = dict["volumeUp"]   { vu = v }
            if let v = dict["volumeDown"] { vd = v }
        }
        self.single = s
        self.double = d
        self.triple = t
        self.volumeUp = vu
        self.volumeDown = vd
        self.moduleEnabled = (UserDefaults.standard.object(forKey: enabledKey) as? Bool) ?? true
    }

    private func save() {
        let dict: [String: Mapping] = [
            "single": single, "double": double, "triple": triple,
            "volumeUp": volumeUp, "volumeDown": volumeDown,
        ]
        if let data = try? JSONEncoder().encode(dict) {
            UserDefaults.standard.set(data, forKey: storeKey)
        }
    }

    func resetToDefaults() {
        single     = Mapping(enabled: true,  keys: ["lopt"], mode: .holdToggle)
        double     = Mapping(enabled: false, keys: ["f14"])
        triple     = Mapping(enabled: false, keys: ["f15"])
        volumeUp   = Mapping(enabled: false, keys: ["f16"])
        volumeDown = Mapping(enabled: false, keys: ["f17"])
    }
}

// MARK: - AirPods 模块：CGEventTap on NSSystemDefined

final class AirPodsTap: ObservableObject {
    static let shared = AirPodsTap()

    @Published private(set) var isRunning = false
    @Published private(set) var holdingCount = 0  // 处于 hold 状态的映射数（>0 时图标变红）
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var holdingChords: [Int32: [String]] = [:]

    func hasAccessibility(prompt: Bool = false) -> Bool {
        let opts = [
            kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: prompt
        ] as CFDictionary
        return AXIsProcessTrustedWithOptions(opts)
    }

    @discardableResult
    func start() -> Bool {
        if isRunning { return true }
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: true)
            isRunning = true
            return true
        }
        guard hasAccessibility(prompt: true) else { return false }

        let mask: CGEventMask = 1 << 14  // NSSystemDefined
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        guard let tap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: { _, type, event, userInfo in
                guard let userInfo = userInfo else { return Unmanaged.passUnretained(event) }
                let me = Unmanaged<AirPodsTap>.fromOpaque(userInfo).takeUnretainedValue()
                return me.handle(type: type, event: event)
            },
            userInfo: selfPtr
        ) else {
            return false
        }
        let src = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), src, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        eventTap = tap
        runLoopSource = src
        isRunning = true
        return true
    }

    func stop() {
        guard isRunning else { return }
        if let tap = eventTap { CGEvent.tapEnable(tap: tap, enable: false) }
        releaseAllHeld()
        isRunning = false
    }

    func toggle() { if isRunning { stop() } else { _ = start() } }

    private func handle(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if isRunning, let tap = eventTap { CGEvent.tapEnable(tap: tap, enable: true) }
            return Unmanaged.passUnretained(event)
        }
        // 自家事件直接放行（防御性 —— 当前不会有 NSSystemDefined magic 事件）
        if event.getIntegerValueField(.eventSourceUserData) == VH_EVENT_MAGIC {
            return Unmanaged.passUnretained(event)
        }
        guard type.rawValue == 14 else { return Unmanaged.passUnretained(event) }
        guard let nsEvent = NSEvent(cgEvent: event), nsEvent.subtype.rawValue == 8 else {
            return Unmanaged.passUnretained(event)
        }
        let keyCode  = Int32((nsEvent.data1 & 0xFFFF0000) >> 16)
        let keyFlags = nsEvent.data1 & 0x0000FFFF
        let isKeyDown = ((keyFlags & 0xFF00) >> 8) == 0x0A

        let cfg = AirPodsConfig.shared
        let mapping: Mapping
        switch keyCode {
        case NX_KEYTYPE_PLAY:       mapping = cfg.single
        case NX_KEYTYPE_NEXT:       mapping = cfg.double
        case NX_KEYTYPE_PREVIOUS:   mapping = cfg.triple
        case NX_KEYTYPE_SOUND_UP:   mapping = cfg.volumeUp
        case NX_KEYTYPE_SOUND_DOWN: mapping = cfg.volumeDown
        default: return Unmanaged.passUnretained(event)
        }
        guard mapping.enabled, !mapping.keys.isEmpty else {
            return Unmanaged.passUnretained(event)
        }
        if isKeyDown {
            switch mapping.mode {
            case .tap:
                postChordDownSync(keyIds: mapping.keys)
                postChordUpSync(keyIds: mapping.keys)
            case .holdToggle:
                if let chord = holdingChords[keyCode] {
                    postChordUpSync(keyIds: chord)
                    holdingChords.removeValue(forKey: keyCode)
                } else {
                    postChordDownSync(keyIds: mapping.keys)
                    holdingChords[keyCode] = mapping.keys
                }
                DispatchQueue.main.async { [weak self] in
                    self?.holdingCount = self?.holdingChords.count ?? 0
                }
            }
        }
        return nil
    }

    /// 释放所有 hold 中的 chord，防止 Opt 等修饰键卡住。stop()/quit 时调用。
    func releaseAllHeld() {
        for (_, chord) in holdingChords { postChordUpSync(keyIds: chord) }
        holdingChords.removeAll()
        DispatchQueue.main.async { [weak self] in self?.holdingCount = 0 }
    }
}

// MARK: - Remote 模块：物理按键 + 设备

struct RemoteButton: Identifiable, Hashable {
    let id: String
    let label: String
    let usagePage: UInt32
    let usage: UInt32
    let passthrough: PassthroughKind
}

enum PassthroughKind: Hashable {
    case none
    case keyboard(UInt16)
    case consumer(Int32)
}

let remoteButtons: [RemoteButton] = [
    // —— 方向键 + 确定 + 菜单（标准 HID Keyboard usage page）——
    .init(id: "up",    label: "↑ 上",      usagePage: 0x07, usage: 0x52,  passthrough: .keyboard(126)),
    .init(id: "down",  label: "↓ 下",      usagePage: 0x07, usage: 0x51,  passthrough: .keyboard(125)),
    .init(id: "left",  label: "← 左",      usagePage: 0x07, usage: 0x50,  passthrough: .keyboard(123)),
    .init(id: "right", label: "→ 右",      usagePage: 0x07, usage: 0x4F,  passthrough: .keyboard(124)),
    .init(id: "ok",    label: "⭕ OK 确认", usagePage: 0x07, usage: 0x28,  passthrough: .keyboard(36)),
    .init(id: "menu",  label: "☰ 菜单",    usagePage: 0x07, usage: 0x65,  passthrough: .keyboard(110)),
    // —— 功能键（Consumer page，TV 遥控器风格）——
    .init(id: "home",  label: "🏠 主页",    usagePage: 0x0C, usage: 0x223, passthrough: .none),
    .init(id: "back",  label: "↩ 返回",    usagePage: 0x0C, usage: 0x224, passthrough: .none),
    .init(id: "voice", label: "🎤 语音",    usagePage: 0x0C, usage: 0x0CF, passthrough: .keyboard(176)),
    .init(id: "mute",  label: "🔇 静音",    usagePage: 0x0C, usage: 0x0E2, passthrough: .consumer(NX_KEYTYPE_MUTE)),
    .init(id: "volup", label: "🔊 音量+",   usagePage: 0x0C, usage: 0x0E9, passthrough: .consumer(NX_KEYTYPE_SOUND_UP)),
    .init(id: "voldn", label: "🔉 音量-",   usagePage: 0x0C, usage: 0x0EA, passthrough: .consumer(NX_KEYTYPE_SOUND_DOWN)),
]

private let buttonByUsage: [UInt64: RemoteButton] = Dictionary(uniqueKeysWithValues:
    remoteButtons.map { (UInt64($0.usagePage) << 32 | UInt64($0.usage), $0) }
)

func remoteButton(usagePage: UInt32, usage: UInt32) -> RemoteButton? {
    buttonByUsage[UInt64(usagePage) << 32 | UInt64(usage)]
}

/// 默认目标设备：XING WEI 2.4G USB（常见国产 2.4G TV 遥控器接收器）
private let DEFAULT_TARGET_VID: Int = 0x1915
private let DEFAULT_TARGET_PID: Int = 0x1025

struct DetectedDevice: Hashable, Identifiable {
    let vendorId: Int
    let productId: Int
    let manufacturer: String
    let product: String
    var id: String { "\(vendorId):\(productId)" }
    var hexId: String { String(format: "0x%04X:0x%04X", vendorId, productId) }
    var displayName: String {
        let m = manufacturer.isEmpty ? "" : "\(manufacturer)  "
        let p = product.isEmpty ? "(未知设备)" : product
        return "\(m)\(p)  \(hexId)"
    }
}

/// 列出当前插着、且看起来像"遥控键盘 / 类键盘 HID"的 USB 设备。
/// 过滤掉 Apple 自家键盘（VID 0x05AC），避免选错把内置键盘接管。
func enumerateRemoteCandidates() -> [DetectedDevice] {
    let manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
    let matching: [String: Any] = [
        kIOHIDDeviceUsagePageKey as String: 0x01,  // Generic Desktop
        kIOHIDDeviceUsageKey as String:     0x06,  // Keyboard
    ]
    IOHIDManagerSetDeviceMatching(manager, matching as CFDictionary)
    guard let devices = IOHIDManagerCopyDevices(manager) as? Set<IOHIDDevice> else { return [] }
    var seen = Set<String>()
    var result: [DetectedDevice] = []
    for device in devices {
        let vid = (IOHIDDeviceGetProperty(device, kIOHIDVendorIDKey as CFString) as? Int) ?? 0
        let pid = (IOHIDDeviceGetProperty(device, kIOHIDProductIDKey as CFString) as? Int) ?? 0
        let manuf = (IOHIDDeviceGetProperty(device, kIOHIDManufacturerKey as CFString) as? String) ?? ""
        let prod = (IOHIDDeviceGetProperty(device, kIOHIDProductKey as CFString) as? String) ?? ""
        if vid == 0x05AC { continue }
        let key = "\(vid):\(pid)"
        if seen.contains(key) { continue }
        seen.insert(key)
        result.append(DetectedDevice(vendorId: vid, productId: pid, manufacturer: manuf, product: prod))
    }
    return result.sorted { $0.displayName < $1.displayName }
}

// MARK: - Remote 模块：配置

final class RemoteConfig: ObservableObject {
    static let shared = RemoteConfig()
    private let storeKey         = "vibehub_remote_v1"
    private let enabledKey       = "vibehub_remote_enabled"
    private let arEnabledKey     = "vibehub_remote_autorepeat_enabled"
    private let arInitialMsKey   = "vibehub_remote_autorepeat_initial_ms"
    private let arIntervalMsKey  = "vibehub_remote_autorepeat_interval_ms"
    private let vidKey           = "vibehub_remote_target_vid"
    private let pidKey           = "vibehub_remote_target_pid"

    @Published var mappings: [String: Mapping] { didSet { saveMappings() } }
    @Published var moduleEnabled: Bool {
        didSet { UserDefaults.standard.set(moduleEnabled, forKey: enabledKey) }
    }
    @Published var autoRepeatEnabled: Bool {
        didSet { UserDefaults.standard.set(autoRepeatEnabled, forKey: arEnabledKey) }
    }
    @Published var autoRepeatInitialDelayMs: Int {
        didSet { UserDefaults.standard.set(autoRepeatInitialDelayMs, forKey: arInitialMsKey) }
    }
    @Published var autoRepeatIntervalMs: Int {
        didSet { UserDefaults.standard.set(autoRepeatIntervalMs, forKey: arIntervalMsKey) }
    }
    @Published var targetVID: Int { didSet { UserDefaults.standard.set(targetVID, forKey: vidKey) } }
    @Published var targetPID: Int { didSet { UserDefaults.standard.set(targetPID, forKey: pidKey) } }

    private init() {
        var initial: [String: Mapping] = [:]
        for b in remoteButtons { initial[b.id] = Mapping() }
        if let data = UserDefaults.standard.data(forKey: storeKey),
           let loaded = try? JSONDecoder().decode([String: Mapping].self, from: data) {
            for (k, v) in loaded { initial[k] = v }
        }
        self.mappings = initial
        let d = UserDefaults.standard
        self.moduleEnabled            = (d.object(forKey: enabledKey)     as? Bool) ?? true
        self.autoRepeatEnabled        = (d.object(forKey: arEnabledKey)   as? Bool) ?? true
        self.autoRepeatInitialDelayMs = (d.object(forKey: arInitialMsKey) as? Int)  ?? 500
        self.autoRepeatIntervalMs     = (d.object(forKey: arIntervalMsKey) as? Int) ?? 100
        self.targetVID                = (d.object(forKey: vidKey) as? Int) ?? DEFAULT_TARGET_VID
        self.targetPID                = (d.object(forKey: pidKey) as? Int) ?? DEFAULT_TARGET_PID
    }

    private func saveMappings() {
        if let data = try? JSONEncoder().encode(mappings) {
            UserDefaults.standard.set(data, forKey: storeKey)
        }
    }

    func resetToDefaults() {
        var fresh: [String: Mapping] = [:]
        for b in remoteButtons { fresh[b.id] = Mapping() }
        mappings = fresh
        autoRepeatEnabled = true
        autoRepeatInitialDelayMs = 500
        autoRepeatIntervalMs = 100
        targetVID = DEFAULT_TARGET_VID
        targetPID = DEFAULT_TARGET_PID
    }

    func binding(for buttonId: String) -> Binding<Mapping> {
        Binding(
            get: { self.mappings[buttonId] ?? Mapping() },
            set: { self.mappings[buttonId] = $0 }
        )
    }
}

// MARK: - Remote 模块：HID 监听 + CGEventTap 吞键

final class RemoteEngine: ObservableObject {
    static let shared = RemoteEngine()

    @Published private(set) var isRunning = false
    @Published private(set) var deviceConnected = false
    @Published var lastError: String?

    private var manager: IOHIDManager?
    private var openedDevices: Set<IOHIDDevice> = []
    private var eventTap: CFMachPort?
    private var tapRunLoopSource: CFRunLoopSource?
    private var repeatTimers: [String: Timer] = [:]

    enum SwallowKey: Hashable {
        case keyboard(Int64)
        case consumer(Int32)
    }
    private var swallowSet: Set<SwallowKey> = []
    private let swallowLock = NSLock()

    private func addSwallow(_ k: SwallowKey)    { swallowLock.lock(); swallowSet.insert(k); swallowLock.unlock() }
    private func removeSwallow(_ k: SwallowKey) { swallowLock.lock(); swallowSet.remove(k); swallowLock.unlock() }
    private func shouldSwallow(_ k: SwallowKey) -> Bool {
        swallowLock.lock(); defer { swallowLock.unlock() }
        return swallowSet.contains(k)
    }
    private func clearSwallows() { swallowLock.lock(); swallowSet.removeAll(); swallowLock.unlock() }

    private func swallowKey(for button: RemoteButton) -> SwallowKey? {
        switch button.passthrough {
        case .keyboard(let kc): return .keyboard(Int64(kc))
        case .consumer(let kt): return .consumer(kt)
        case .none:             return nil
        }
    }

    @discardableResult
    func ensureHIDAccess() -> Bool {
        let access = IOHIDCheckAccess(kIOHIDRequestTypeListenEvent)
        if access == kIOHIDAccessTypeGranted { return true }
        return IOHIDRequestAccess(kIOHIDRequestTypeListenEvent)
    }

    @discardableResult
    func ensureAccessibility(prompt: Bool) -> Bool {
        let opts = [
            kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: prompt
        ] as CFDictionary
        return AXIsProcessTrustedWithOptions(opts)
    }

    @discardableResult
    func start() -> Bool {
        if isRunning { return true }
        if !ensureHIDAccess() {
            DispatchQueue.main.async { [weak self] in
                self?.lastError = "缺少「输入监听」权限。系统已弹授权对话框，请到「系统设置 → 隐私与安全性 → 输入监听」打开 VibeHub，然后退出 App 重新启动。"
            }
            return false
        }
        _ = ensureAccessibility(prompt: true)

        let m = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        let cfg = RemoteConfig.shared
        let matching: [String: Any] = [
            kIOHIDVendorIDKey as String:  cfg.targetVID,
            kIOHIDProductIDKey as String: cfg.targetPID,
        ]
        IOHIDManagerSetDeviceMatching(m, matching as CFDictionary)
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        IOHIDManagerRegisterDeviceMatchingCallback(m, { ctx, _, _, device in
            guard let ctx else { return }
            let me = Unmanaged<RemoteEngine>.fromOpaque(ctx).takeUnretainedValue()
            me.onDeviceMatched(device)
        }, selfPtr)
        IOHIDManagerRegisterDeviceRemovalCallback(m, { ctx, _, _, device in
            guard let ctx else { return }
            let me = Unmanaged<RemoteEngine>.fromOpaque(ctx).takeUnretainedValue()
            me.onDeviceRemoved(device)
        }, selfPtr)
        IOHIDManagerScheduleWithRunLoop(m, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)

        // 不 seize（self-signed app 拿不到 driverkit entitlement）。普通 open + CGEventTap 吞咽。
        let r = IOHIDManagerOpen(m, IOOptionBits(kIOHIDOptionsTypeNone))
        if r != kIOReturnSuccess {
            let hex = String(format: "0x%X", UInt32(bitPattern: r))
            DispatchQueue.main.async { [weak self] in
                self?.lastError = "IOHIDManagerOpen 返回 \(hex)。请确认遥控器已插入、并且「输入监听」权限给到了 VibeHub。"
            }
            NSLog("RemoteEngine: IOHIDManagerOpen failed: \(hex)")
            IOHIDManagerUnscheduleFromRunLoop(m, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
            return false
        }
        if !installEventTap() {
            DispatchQueue.main.async { [weak self] in
                self?.lastError = "已启动 HID 监听，但 CGEventTap 安装失败 —— 多半「辅助功能」权限未授予。Home/Back/Voice/Menu 仍可工作；方向键/Vol/Mute 的映射会与系统行为叠加。请到「系统设置 → 隐私与安全性 → 辅助功能」打开 VibeHub，重启 App。"
            }
        } else {
            DispatchQueue.main.async { [weak self] in self?.lastError = nil }
        }
        manager = m
        isRunning = true
        return true
    }

    private func installEventTap() -> Bool {
        if eventTap != nil { return true }
        // keyDown / keyUp（10/11）+ NSSystemDefined（14）
        let mask: CGEventMask = (1 << 10) | (1 << 11) | (1 << 14)
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        guard let tap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: { _, type, event, userInfo in
                guard let userInfo = userInfo else { return Unmanaged.passUnretained(event) }
                let me = Unmanaged<RemoteEngine>.fromOpaque(userInfo).takeUnretainedValue()
                return me.handleTap(type: type, event: event)
            },
            userInfo: selfPtr
        ) else { return false }
        let src = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), src, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        eventTap = tap
        tapRunLoopSource = src
        return true
    }

    private func handleTap(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let tap = eventTap { CGEvent.tapEnable(tap: tap, enable: true) }
            return Unmanaged.passUnretained(event)
        }
        // 自家事件直接放行（防止"OK→Enter 把自己也吞了"那类自吞 bug）
        if event.getIntegerValueField(.eventSourceUserData) == VH_EVENT_MAGIC {
            return Unmanaged.passUnretained(event)
        }
        if type == .keyDown || type == .keyUp {
            let kc = event.getIntegerValueField(.keyboardEventKeycode)
            if shouldSwallow(.keyboard(kc)) { return nil }
        } else if type.rawValue == 14 {
            guard let nsEvent = NSEvent(cgEvent: event), nsEvent.subtype.rawValue == 8 else {
                return Unmanaged.passUnretained(event)
            }
            let keyType = Int32((nsEvent.data1 & 0xFFFF0000) >> 16)
            if shouldSwallow(.consumer(keyType)) { return nil }
        }
        return Unmanaged.passUnretained(event)
    }

    func stop() {
        guard isRunning else { return }
        stopAllAutoRepeats()
        clearSwallows()
        if let tap = eventTap { CGEvent.tapEnable(tap: tap, enable: false) }
        if let src = tapRunLoopSource { CFRunLoopRemoveSource(CFRunLoopGetMain(), src, .commonModes) }
        eventTap = nil
        tapRunLoopSource = nil
        if let m = manager {
            IOHIDManagerClose(m, IOOptionBits(kIOHIDOptionsTypeNone))
            IOHIDManagerUnscheduleFromRunLoop(m, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
        }
        manager = nil
        openedDevices.removeAll()
        DispatchQueue.main.async { [weak self] in self?.deviceConnected = false }
        isRunning = false
    }

    func toggle() { if isRunning { stop() } else { _ = start() } }

    /// 切换目标设备后调用：停掉旧设备，按新 VID/PID 重新建 manager
    func restart() {
        let wasRunning = isRunning
        if isRunning { stop() }
        if wasRunning { _ = start() }
    }

    private func onDeviceMatched(_ device: IOHIDDevice) {
        openedDevices.insert(device)
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        IOHIDDeviceRegisterInputValueCallback(device, { ctx, _, _, value in
            guard let ctx else { return }
            let me = Unmanaged<RemoteEngine>.fromOpaque(ctx).takeUnretainedValue()
            me.handleInputValue(value)
        }, selfPtr)
        DispatchQueue.main.async { [weak self] in self?.deviceConnected = true }
    }

    private func onDeviceRemoved(_ device: IOHIDDevice) {
        openedDevices.remove(device)
        DispatchQueue.main.async { [weak self] in
            self?.deviceConnected = !(self?.openedDevices.isEmpty ?? true)
        }
    }

    private func handleInputValue(_ value: IOHIDValue) {
        let element = IOHIDValueGetElement(value)
        let usagePage = IOHIDElementGetUsagePage(element)
        let usage = IOHIDElementGetUsage(element)
        let intValue = IOHIDValueGetIntegerValue(value)
        guard let button = remoteButton(usagePage: usagePage, usage: usage) else { return }
        let isDown = (intValue != 0)
        dispatch(button: button, isDown: isDown)
    }

    private func dispatch(button: RemoteButton, isDown: Bool) {
        let cfg = RemoteConfig.shared
        let mapping = cfg.mappings[button.id] ?? Mapping()
        guard mapping.enabled, !mapping.keys.isEmpty else { return }
        if let sk = swallowKey(for: button) {
            if isDown {
                addSwallow(sk)
            } else {
                let key = sk
                // 100ms 延迟摘除，确保系统的"按起"事件（以及 auto-repeat 残留）都被吞掉
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    self?.removeSwallow(key)
                }
            }
        }
        if isDown {
            postChordDownAsync(keyIds: mapping.keys)
            postChordUpAsync(keyIds: mapping.keys)
            startAutoRepeat(buttonId: button.id, keys: mapping.keys)
        } else {
            stopAutoRepeat(buttonId: button.id)
        }
    }

    private func startAutoRepeat(buttonId: String, keys: [String]) {
        let cfg = RemoteConfig.shared
        guard cfg.autoRepeatEnabled else { return }
        stopAutoRepeat(buttonId: buttonId)
        let initialSec  = TimeInterval(cfg.autoRepeatInitialDelayMs) / 1000.0
        let intervalSec = TimeInterval(cfg.autoRepeatIntervalMs) / 1000.0
        let initial = Timer.scheduledTimer(withTimeInterval: initialSec, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            let repeating = Timer.scheduledTimer(withTimeInterval: intervalSec, repeats: true) { _ in
                postChordDownAsync(keyIds: keys)
                postChordUpAsync(keyIds: keys)
            }
            self.repeatTimers[buttonId] = repeating
        }
        repeatTimers[buttonId] = initial
    }

    private func stopAutoRepeat(buttonId: String) {
        repeatTimers[buttonId]?.invalidate()
        repeatTimers[buttonId] = nil
    }

    private func stopAllAutoRepeats() {
        for (_, t) in repeatTimers { t.invalidate() }
        repeatTimers.removeAll()
    }
}

// MARK: - 开机自启动

final class LaunchAtLogin: ObservableObject {
    static let shared = LaunchAtLogin()
    @Published private(set) var isEnabled: Bool = false
    @Published var lastError: String?

    private init() { refresh() }

    func refresh() { isEnabled = SMAppService.mainApp.status == .enabled }

    func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                if SMAppService.mainApp.status != .enabled {
                    try SMAppService.mainApp.register()
                }
            } else {
                if SMAppService.mainApp.status == .enabled {
                    try SMAppService.mainApp.unregister()
                }
            }
            lastError = nil
        } catch {
            lastError = error.localizedDescription
            NSLog("LaunchAtLogin error: \(error)")
        }
        refresh()
    }
}

// MARK: - UI: 共享单行编辑器（AirPods + Remote 都用）

/// 懒加载的按键选择器：用 Menu 替代 Picker —— Menu 的 ForEach 子项只在用户点开下拉时才构建，
/// 折叠状态只有一个 label 在视图树里。把首次 popover 打开的 SwiftUI body 评估成本降一个量级。
struct LazyKeyMenu: View {
    @Binding var selection: String
    let enabled: Bool

    private var currentLabel: String { keyChoice(selection)?.label ?? "?" }

    var body: some View {
        Menu {
            ForEach(keyChoices) { c in
                Button(c.label) { selection = c.id }
            }
        } label: {
            Text(currentLabel)
                .font(.system(size: 12))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .controlSize(.small)
        .disabled(!enabled)
    }
}

struct KeyPickerRow: View {
    let label: String
    let labelWidth: CGFloat
    @Binding var mapping: Mapping
    let showModePicker: Bool  // AirPods=true（点按/按住），Remote=false

    private var firstKeyBinding: Binding<String> {
        Binding(
            get: { mapping.keys.first ?? "lopt" },
            set: { v in
                if mapping.keys.isEmpty { mapping.keys.append(v) }
                else { mapping.keys[0] = v }
            }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                Toggle("", isOn: $mapping.enabled).labelsHidden()
                Text(label).frame(width: labelWidth, alignment: .leading).font(.system(size: 12))

                LazyKeyMenu(selection: firstKeyBinding, enabled: mapping.enabled)
                    .frame(maxWidth: .infinity)

                if showModePicker {
                    Picker("", selection: $mapping.mode) {
                        Text("点按").tag(MappingMode.tap)
                        Text("按住").tag(MappingMode.holdToggle)
                    }
                    .pickerStyle(.segmented).labelsHidden().frame(width: 72)
                    .disabled(!mapping.enabled).controlSize(.small)
                }

                Button { mapping.keys.append("lopt") } label: {
                    Image(systemName: "plus.circle")
                }
                .buttonStyle(.borderless).help("追加 chord 按键").disabled(!mapping.enabled)
            }

            if mapping.keys.count > 1 {
                ForEach(1..<mapping.keys.count, id: \.self) { idx in
                    HStack(spacing: 6) {
                        Spacer().frame(width: labelWidth + 24)
                        Image(systemName: "plus").foregroundColor(.secondary).font(.system(size: 9))
                        LazyKeyMenu(selection: Binding(
                            get: { idx < mapping.keys.count ? mapping.keys[idx] : "lopt" },
                            set: { v in if idx < mapping.keys.count { mapping.keys[idx] = v } }
                        ), enabled: mapping.enabled).frame(maxWidth: .infinity)
                        Button {
                            if idx < mapping.keys.count { mapping.keys.remove(at: idx) }
                        } label: { Image(systemName: "minus.circle") }
                            .buttonStyle(.borderless)
                    }
                    .disabled(!mapping.enabled)
                }
            }
        }
    }
}

// MARK: - UI: AirPods Tab

struct AirPodsTabView: View {
    @ObservedObject var config = AirPodsConfig.shared
    @ObservedObject var tap = AirPodsTap.shared
    @State private var hasAccessibility = AirPodsTap.shared.hasAccessibility()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "earbuds")
                    Text("AirPods / 蓝牙耳机媒体键").font(.subheadline.weight(.semibold))
                    Spacer()
                    Circle()
                        .fill(tap.isRunning ? Color.green : Color.secondary)
                        .frame(width: 8, height: 8)
                    Text(tap.isRunning ? "运行中" : "已暂停")
                        .font(.caption).foregroundColor(.secondary)
                }

                HStack(spacing: 8) {
                    Button {
                        if tap.isRunning {
                            tap.stop()
                            config.moduleEnabled = false
                        } else {
                            hasAccessibility = tap.hasAccessibility(prompt: true)
                            if hasAccessibility, tap.start() {
                                config.moduleEnabled = true
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: tap.isRunning ? "pause.fill" : "play.fill")
                            Text(tap.isRunning ? "暂停 AirPods 模块" : "启动 AirPods 模块")
                        }.frame(maxWidth: .infinity)
                    }
                    Button("辅助功能…") {
                        NSWorkspace.shared.open(URL(string:
                            "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
                    }
                }

                if !hasAccessibility {
                    Text("⚠️ 需要「辅助功能」权限：系统设置 → 隐私与安全性 → 辅助功能 → 打开 VibeHub")
                        .font(.caption).foregroundColor(.orange)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Divider()

                KeyPickerRow(label: "单击",  labelWidth: 46, mapping: $config.single,     showModePicker: true)
                KeyPickerRow(label: "双击",  labelWidth: 46, mapping: $config.double,     showModePicker: true)
                KeyPickerRow(label: "三击",  labelWidth: 46, mapping: $config.triple,     showModePicker: true)
                KeyPickerRow(label: "音量+", labelWidth: 46, mapping: $config.volumeUp,   showModePicker: true)
                KeyPickerRow(label: "音量-", labelWidth: 46, mapping: $config.volumeDown, showModePicker: true)

                if config.volumeUp.enabled || config.volumeDown.enabled {
                    Text("⚠️ 启用音量键映射后，AirPods 将无法用来调系统音量")
                        .font(.caption2).foregroundColor(.orange)
                }

                HStack {
                    Spacer()
                    Button("重置 AirPods 默认") { config.resetToDefaults() }
                        .buttonStyle(.borderless).font(.caption)
                }

                Text("「点按」=按一下立刻松开；「按住」=按一下按住、再按一下释放（适合 Typeless / WhisperKey 长按 Opt 录音）。")
                    .font(.caption2).foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("注意：AirPods Pro 2 / Pro 3 的 stem 事件全部走 MediaRemote 私有 IPC，所有同类工具都拦不到。普通 AirPods / AirPods Max 工作正常。")
                    .font(.caption2).foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
        }
    }
}

// MARK: - UI: Remote Tab

struct RemoteTabView: View {
    @ObservedObject var config = RemoteConfig.shared
    @ObservedObject var engine = RemoteEngine.shared
    @State private var detectedDevices: [DetectedDevice] = []

    private let groupDpad   = ["up", "down", "left", "right", "ok", "menu"]
    private let groupSystem = ["home", "back", "voice"]
    private let groupVolume = ["mute", "volup", "voldn"]

    private func scanDevicesAsync() {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = enumerateRemoteCandidates()
            DispatchQueue.main.async { self.detectedDevices = result }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                header
                runStatus
                if let err = engine.lastError {
                    Text("⚠️ \(err)")
                        .font(.caption).foregroundColor(.orange)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(6).background(Color.orange.opacity(0.1)).cornerRadius(6)
                }
                deviceSection
                sectionGroup("方向 / 确认", ids: groupDpad)
                sectionGroup("系统功能",    ids: groupSystem)
                sectionGroup("音量",        ids: groupVolume)
                autoRepeatSection

                HStack {
                    Spacer()
                    Button("重置 Remote 默认") { config.resetToDefaults() }
                        .buttonStyle(.borderless).font(.caption)
                }
            }
            .padding(12)
        }
    }

    private var header: some View {
        HStack(spacing: 6) {
            Image(systemName: "av.remote")
            Text("2.4G 遥控键盘").font(.subheadline.weight(.semibold))
            Spacer()
            Circle()
                .fill(engine.isRunning && engine.deviceConnected ? Color.green
                      : engine.isRunning ? Color.orange : Color.secondary)
                .frame(width: 8, height: 8)
            Text(engine.isRunning
                 ? (engine.deviceConnected ? "运行中" : "等待设备")
                 : "已暂停")
                .font(.caption).foregroundColor(.secondary)
        }
    }

    private var runStatus: some View {
        HStack(spacing: 8) {
            Button {
                if engine.isRunning {
                    engine.stop()
                    config.moduleEnabled = false
                } else {
                    if engine.start() { config.moduleEnabled = true }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: engine.isRunning ? "pause.fill" : "play.fill")
                    Text(engine.isRunning ? "暂停 Remote 模块" : "启动 Remote 模块")
                }.frame(maxWidth: .infinity)
            }
            Button("输入监听权限…") {
                NSWorkspace.shared.open(URL(string:
                    "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")!)
            }
        }
    }

    private func sectionGroup(_ title: String, ids: [String]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption2).foregroundColor(.secondary).padding(.top, 2)
            ForEach(ids, id: \.self) { id in mappingRow(for: id) }
        }
    }

    private func mappingRow(for id: String) -> some View {
        Group {
            if let b = remoteButtons.first(where: { $0.id == id }) {
                KeyPickerRow(label: b.label, labelWidth: 68,
                    mapping: config.binding(for: id), showModePicker: false)
            }
        }
    }

    private var currentDeviceLabel: String {
        String(format: "0x%04X : 0x%04X", config.targetVID, config.targetPID)
    }

    private var deviceSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("目标设备").font(.caption2).foregroundColor(.secondary)
                Spacer()
                Menu {
                    if detectedDevices.isEmpty {
                        Text("（没扫到 HID 键盘类设备）").font(.caption)
                    } else {
                        ForEach(detectedDevices) { dev in
                            Button(dev.displayName) {
                                config.targetVID = dev.vendorId
                                config.targetPID = dev.productId
                                engine.restart()
                            }
                        }
                    }
                    Divider()
                    Button("重新扫描") { scanDevicesAsync() }
                    Button("恢复默认 (XING WEI 0x1915:0x1025)") {
                        config.targetVID = DEFAULT_TARGET_VID
                        config.targetPID = DEFAULT_TARGET_PID
                        engine.restart()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text("切换…").font(.caption)
                        Image(systemName: "chevron.up.chevron.down").font(.system(size: 9))
                    }
                }
                .menuStyle(.borderlessButton).fixedSize()
                .onAppear { if detectedDevices.isEmpty { scanDevicesAsync() } }
            }
            Text(currentDeviceLabel)
                .font(.system(size: 11, design: .monospaced))
                .padding(.horizontal, 6).padding(.vertical, 3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.secondary.opacity(0.1)).cornerRadius(4)
            if !engine.deviceConnected && engine.isRunning {
                Text("⚠️ 当前 VID/PID 没找到匹配设备。点「切换…」选择已插着的硬件。")
                    .font(.caption2).foregroundColor(.orange)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var autoRepeatSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("长按自动重复").font(.caption2).foregroundColor(.secondary)
                Spacer()
                Toggle("", isOn: $config.autoRepeatEnabled)
                    .toggleStyle(.switch).labelsHidden().controlSize(.mini)
            }
            .padding(.top, 2)
            if config.autoRepeatEnabled {
                HStack(spacing: 6) {
                    Text("启动延迟").font(.caption).frame(width: 56, alignment: .leading)
                    Slider(value: Binding(
                        get: { Double(config.autoRepeatInitialDelayMs) },
                        set: { config.autoRepeatInitialDelayMs = Int($0) }
                    ), in: 200...1500, step: 50)
                    Text("\(config.autoRepeatInitialDelayMs) ms")
                        .font(.caption).monospacedDigit().frame(width: 56, alignment: .trailing)
                }
                HStack(spacing: 6) {
                    Text("重复间隔").font(.caption).frame(width: 56, alignment: .leading)
                    Slider(value: Binding(
                        get: { Double(config.autoRepeatIntervalMs) },
                        set: { config.autoRepeatIntervalMs = Int($0) }
                    ), in: 30...500, step: 10)
                    Text("\(config.autoRepeatIntervalMs) ms")
                        .font(.caption).monospacedDigit().frame(width: 56, alignment: .trailing)
                }
            } else {
                Text("已关闭：按一次只触发一次 chord").font(.caption2).foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - UI: 主面板（segmented picker + ZStack，Tab 切换不重建视图树）

struct ContentView: View {
    @ObservedObject var loginItem = LaunchAtLogin.shared
    @State private var selectedTab: String = "airpods"

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                Text("AirPods").tag("airpods")
                Text("Remote").tag("remote")
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding(.horizontal, 10)
            .padding(.top, 8)
            .padding(.bottom, 6)

            Divider()

            ZStack(alignment: .top) {
                AirPodsTabView()
                    .opacity(selectedTab == "airpods" ? 1 : 0)
                    .allowsHitTesting(selectedTab == "airpods")
                RemoteTabView()
                    .opacity(selectedTab == "remote" ? 1 : 0)
                    .allowsHitTesting(selectedTab == "remote")
            }
            .frame(width: 340, height: 620)

            Divider()

            HStack(spacing: 8) {
                Toggle(isOn: Binding(
                    get: { loginItem.isEnabled },
                    set: { loginItem.setEnabled($0) }
                )) { Text("开机自启").font(.caption) }
                .toggleStyle(.checkbox)
                Spacer()
                Button {
                    NSApp.terminate(nil)
                } label: {
                    Text("退出 VibeHub").font(.caption)
                }
                .buttonStyle(.borderless)
                .keyboardShortcut("q")
            }
            .padding(.horizontal, 10).padding(.vertical, 6)

            if let err = loginItem.lastError {
                Text("自启动设置失败：\(err)")
                    .font(.caption2).foregroundColor(.orange)
                    .padding(.horizontal, 10).padding(.bottom, 6)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(width: 340)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

// MARK: - AppDelegate（状态栏 + 弹层 + 右键菜单）

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        setvbuf(stdout, nil, _IOLBF, 0)
        _ = AirPodsConfig.shared
        _ = RemoteConfig.shared

        // 各模块按之前的 moduleEnabled 状态启动
        if AirPodsConfig.shared.moduleEnabled { _ = AirPodsTap.shared.start() }
        if RemoteConfig.shared.moduleEnabled  { _ = RemoteEngine.shared.start() }

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            applyStatusIcon(to: button)
            button.target = self
            button.action = #selector(handleStatusClick(_:))
            // 左键改成 mouseDown 触发：默认 mouseUp 要等用户松开手才响应，
            // 即便后续都是 0ms，用户也会觉得"按下后停顿了一下"。
            button.sendAction(on: [.leftMouseDown, .rightMouseUp])
        }
        updateIconAppearance()

        AirPodsTap.shared.$isRunning.receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateIconAppearance() }.store(in: &cancellables)
        AirPodsTap.shared.$holdingCount.receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateIconAppearance() }.store(in: &cancellables)
        RemoteEngine.shared.$isRunning.receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateIconAppearance() }.store(in: &cancellables)
        RemoteEngine.shared.$deviceConnected.receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateIconAppearance() }.store(in: &cancellables)

        DistributedNotificationCenter.default.addObserver(
            forName: Notification.Name("AppleInterfaceThemeChangedNotification"),
            object: nil, queue: .main
        ) { [weak self] _ in self?.updateIconAppearance() }

        popover = NSPopover()
        popover.behavior = .transient
        popover.animates = false  // 关掉默认 ~200ms 弹出动画，状态栏点击立即响应

        // 预热：先把 host 挂到一个屏外隐藏 window 里强制 SwiftUI 渲染整棵树，
        // 然后再交给 popover。否则 SwiftUI 只在视图真正进入 window 时才 build body，
        // 首次点击图标时要现场建整棵树。
        let host = NSHostingController(rootView: ContentView())
        let warmup = NSWindow(
            contentRect: NSRect(x: -50000, y: -50000, width: 340, height: 720),
            styleMask: [.borderless], backing: .buffered, defer: false)
        warmup.alphaValue = 0
        warmup.contentViewController = host
        warmup.orderFront(nil)
        host.view.layoutSubtreeIfNeeded()
        DispatchQueue.main.async {
            warmup.contentViewController = nil
            warmup.orderOut(nil)
            self.popover.contentViewController = host
        }
    }

    private func applyStatusIcon(to button: NSStatusBarButton) {
        // 用 command 作为中性 hub 图标，AirPods/Remote 都不偏
        let img = NSImage(systemSymbolName: "command", accessibilityDescription: "VibeHub")
        img?.isTemplate = true
        button.image = img
    }

    private func updateIconAppearance() {
        guard let button = statusItem?.button else { return }
        let ap = AirPodsTap.shared
        let rem = RemoteEngine.shared
        let anyRunning = ap.isRunning || rem.isRunning
        button.alphaValue = anyRunning ? 1.0 : 0.4
        applyStatusIcon(to: button)
        // 优先级：AirPods 处于 hold = 红；Remote 等待设备 = 橙；都正常 = 默认色
        if ap.holdingCount > 0 {
            button.contentTintColor = .systemRed
        } else if rem.isRunning && !rem.deviceConnected {
            button.contentTintColor = .systemOrange
        } else {
            button.contentTintColor = nil
        }
    }

    @objc private func handleStatusClick(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }
        if event.type == .rightMouseUp || event.modifierFlags.contains(.control) {
            showContextMenu(from: sender, event: event)
        } else {
            togglePopover(sender)
        }
    }

    private func togglePopover(_ sender: Any?) {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    private func showContextMenu(from button: NSStatusBarButton, event: NSEvent) {
        let menu = NSMenu()
        let ap = AirPodsTap.shared
        let rem = RemoteEngine.shared

        // —— AirPods 状态 + 切换 ——
        let apHeader = NSMenuItem(
            title: ap.isRunning ? "AirPods 模块：运行中" : "AirPods 模块：已暂停",
            action: nil, keyEquivalent: "")
        apHeader.isEnabled = false
        menu.addItem(apHeader)
        let apToggle = NSMenuItem(
            title: ap.isRunning ? "  ⏸  暂停 AirPods" : "  ▶  启动 AirPods",
            action: #selector(menuToggleAirPods), keyEquivalent: "")
        apToggle.target = self
        menu.addItem(apToggle)

        // —— Remote 状态 + 切换 ——
        let remHeader = NSMenuItem(
            title: rem.isRunning
                ? (rem.deviceConnected ? "Remote 模块：运行中" : "Remote 模块：运行中（未检测到遥控器）")
                : "Remote 模块：已暂停",
            action: nil, keyEquivalent: "")
        remHeader.isEnabled = false
        menu.addItem(remHeader)
        let remToggle = NSMenuItem(
            title: rem.isRunning ? "  ⏸  暂停 Remote" : "  ▶  启动 Remote",
            action: #selector(menuToggleRemote), keyEquivalent: "")
        remToggle.target = self
        menu.addItem(remToggle)

        menu.addItem(.separator())

        // —— 当前映射快览 ——
        let apCfg = AirPodsConfig.shared
        let summaryItem = NSMenuItem(title: "当前映射：", action: nil, keyEquivalent: "")
        summaryItem.isEnabled = false
        menu.addItem(summaryItem)
        let apRows: [(String, Mapping)] = [
            ("AirPods 单击", apCfg.single), ("AirPods 双击", apCfg.double),
            ("AirPods 三击", apCfg.triple),
            ("AirPods 音量+", apCfg.volumeUp), ("AirPods 音量-", apCfg.volumeDown),
        ]
        for (label, m) in apRows where m.enabled && !m.keys.isEmpty {
            let names = m.keys.compactMap { keyChoice($0)?.label }.joined(separator: " + ")
            let item = NSMenuItem(title: "  \(label) → \(names)", action: nil, keyEquivalent: "")
            item.isEnabled = false
            menu.addItem(item)
        }
        let remCfg = RemoteConfig.shared
        for b in remoteButtons {
            guard let m = remCfg.mappings[b.id], m.enabled, !m.keys.isEmpty else { continue }
            let names = m.keys.compactMap { keyChoice($0)?.label }.joined(separator: " + ")
            let item = NSMenuItem(title: "  Remote \(b.label) → \(names)",
                action: nil, keyEquivalent: "")
            item.isEnabled = false
            menu.addItem(item)
        }

        menu.addItem(.separator())

        let openConfig = NSMenuItem(title: "打开配置面板",
            action: #selector(menuOpenConfig), keyEquivalent: ",")
        openConfig.target = self
        menu.addItem(openConfig)

        let openAcc = NSMenuItem(title: "辅助功能权限…",
            action: #selector(menuOpenAccessibility), keyEquivalent: "")
        openAcc.target = self
        menu.addItem(openAcc)

        let openListen = NSMenuItem(title: "输入监听权限…",
            action: #selector(menuOpenListenEvent), keyEquivalent: "")
        openListen.target = self
        menu.addItem(openListen)

        menu.addItem(.separator())

        let loginItem = NSMenuItem(title: "开机时自动启动",
            action: #selector(menuToggleLoginItem), keyEquivalent: "")
        loginItem.target = self
        loginItem.state = LaunchAtLogin.shared.isEnabled ? .on : .off
        menu.addItem(loginItem)

        menu.addItem(.separator())

        let about = NSMenuItem(title: "关于 VibeHub",
            action: #selector(menuAbout), keyEquivalent: "")
        about.target = self
        menu.addItem(about)

        let restart = NSMenuItem(title: "重新启动",
            action: #selector(menuRestart), keyEquivalent: "r")
        restart.target = self
        menu.addItem(restart)

        let quit = NSMenuItem(title: "退出",
            action: #selector(menuQuit), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)

        NSMenu.popUpContextMenu(menu, with: event, for: button)
    }

    @objc private func menuToggleAirPods() {
        AirPodsTap.shared.toggle()
        AirPodsConfig.shared.moduleEnabled = AirPodsTap.shared.isRunning
    }
    @objc private func menuToggleRemote() {
        RemoteEngine.shared.toggle()
        RemoteConfig.shared.moduleEnabled = RemoteEngine.shared.isRunning
    }
    @objc private func menuOpenConfig() { togglePopover(nil) }
    @objc private func menuOpenAccessibility() {
        NSWorkspace.shared.open(URL(string:
            "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
    }
    @objc private func menuOpenListenEvent() {
        NSWorkspace.shared.open(URL(string:
            "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")!)
    }
    @objc private func menuToggleLoginItem() {
        LaunchAtLogin.shared.setEnabled(!LaunchAtLogin.shared.isEnabled)
    }
    @objc private func menuAbout() {
        let alert = NSAlert()
        alert.messageText = "VibeHub"
        alert.informativeText = """
            把 AirPods / 蓝牙耳机 + 2.4G 遥控键盘的按键统一映射到任意 macOS 键盘 chord。

            • 左键状态栏图标 → 配置面板（AirPods / Remote 两个 Tab）
            • 右键状态栏图标 → 快捷菜单

            版本 1.0.0
            """
        alert.runModal()
    }
    @objc private func menuRestart() {
        let bundlePath = Bundle.main.bundlePath
        let task = Process()
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", "sleep 0.5 && open \"\(bundlePath)\""]
        try? task.run()
        NSApp.terminate(nil)
    }
    @objc private func menuQuit() { NSApp.terminate(nil) }

    func applicationWillTerminate(_ notification: Notification) {
        AirPodsTap.shared.releaseAllHeld()
        RemoteEngine.shared.stop()
    }
}

// MARK: - App 入口

@main
struct VibeHubApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        Settings { EmptyView() }
    }
}
