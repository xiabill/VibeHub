import Cocoa
import SwiftUI
import IOKit
import IOKit.hid
import CoreGraphics
import Combine
import ServiceManagement
import Darwin
import CoreAudio
import AVFoundation

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

extension KeyChoice {
    /// chip 键帽用的短标签：修饰键只留符号，其余用 label 去掉 CJK 注音后缀。
    var shortLabel: String {
        switch id {
        case "lopt", "ropt":   return "⌥"
        case "lcmd", "rcmd":   return "⌘"
        case "lctrl", "rctrl": return "⌃"
        case "lshift", "rshift": return "⇧"
        case "fn":             return "fn"
        default:
            var out = ""
            for ch in label {
                if let s = ch.unicodeScalars.first, s.value >= 0x3000 { break }  // 遇到 CJK/日文即截断
                out.append(ch)
            }
            let trimmed = out.trimmingCharacters(in: CharacterSet(charactersIn: " (（"))
            return trimmed.isEmpty ? label : trimmed
        }
    }
}

// MARK: - 共享：按键录制（NSEvent 本地监听）

/// 修饰键 keyCode → chord id（可区分左右，用于纯修饰键录制）。
private let modifierKeyCodeToId: [UInt16: String] = [
    58: "lopt", 61: "ropt", 55: "lcmd", 54: "rcmd",
    59: "lctrl", 62: "rctrl", 56: "lshift", 60: "rshift", 63: "fn",
]
/// 修饰键 keyCode → NSEvent 设备无关 flag（判断该 flagsChanged 是按下还是抬起）。
private let modifierKeyCodeToNSFlag: [UInt16: NSEvent.ModifierFlags] = [
    58: .option, 61: .option, 55: .command, 54: .command,
    59: .control, 62: .control, 56: .shift, 60: .shift, 63: .function,
]
private let recordRelevantFlags: NSEvent.ModifierFlags = [.command, .option, .control, .shift, .function]

/// event.modifierFlags → chord id 列表（左右不分时默认 left），顺序 fn/ctrl/opt/shift/cmd。
private func modifierIdsFromFlags(_ flags: NSEvent.ModifierFlags) -> [String] {
    var ids: [String] = []
    if flags.contains(.function) { ids.append("fn") }
    if flags.contains(.control)  { ids.append("lctrl") }
    if flags.contains(.option)   { ids.append("lopt") }
    if flags.contains(.shift)    { ids.append("lshift") }
    if flags.contains(.command)  { ids.append("lcmd") }
    return ids
}
/// keyCode 反查主键（排除纯修饰键）。
private func mainKeyChoice(forKeyCode kc: UInt16) -> KeyChoice? {
    keyChoices.first { $0.keyCode == kc && modifierKeyCodeToId[kc] == nil }
}

/// 单行按键录制器。进入录制态时装 local monitor，离开时销毁；全局同一时刻只应有一个在跑。
final class KeyRecorder: ObservableObject {
    private var monitor: Any?
    private var seenModifiers: [String] = []   // 纯修饰键 chord：flagsChanged 累积出现过的修饰键
    private var onCommit: (([String]) -> Void)?
    private var onCancel: (() -> Void)?

    func start(commit: @escaping ([String]) -> Void, cancel: @escaping () -> Void) {
        stop()
        onCommit = commit
        onCancel = cancel
        seenModifiers = []
        monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { [weak self] e in
            self?.handle(e) ?? e
        }
    }

    func stop() {
        if let m = monitor { NSEvent.removeMonitor(m); monitor = nil }
        seenModifiers = []
        onCommit = nil
        onCancel = nil
    }

    private func handle(_ e: NSEvent) -> NSEvent? {
        switch e.type {
        case .keyDown:
            // 剔除 .function：方向键/F13-F20/Home 等的 modifierFlags 自带该位，
            // 不剔会把 chord 误录成 [fn, ↑]。物理 fn 仍可走纯修饰键路径或手动菜单。
            let mods = e.modifierFlags.intersection(recordRelevantFlags).subtracting(.function)
            if e.keyCode == 53, mods.isEmpty {          // Esc 且无修饰 → 取消
                onCancel?()
                return nil
            }
            if let main = mainKeyChoice(forKeyCode: e.keyCode) {
                let commit = onCommit
                // 先清状态再提交：防止 stop() 生效前迟到的 flagsChanged 用纯修饰键覆盖
                onCommit = nil
                seenModifiers = []
                commit?(modifierIdsFromFlags(mods) + [main.id])
            } else {
                NSSound.beep()                           // 查不到主键：beep 并保持录制态
            }
            return nil                                   // 吞掉 keyDown，避免触发系统快捷键
        case .flagsChanged:
            if let id = modifierKeyCodeToId[e.keyCode],
               let flag = modifierKeyCodeToNSFlag[e.keyCode],
               e.modifierFlags.contains(flag),           // 该修饰键此刻是按下（非抬起）
               !seenModifiers.contains(id) {
                seenModifiers.append(id)
            }
            if e.modifierFlags.intersection(recordRelevantFlags).isEmpty, !seenModifiers.isEmpty {
                let captured = seenModifiers
                let commit = onCommit
                onCommit = nil
                seenModifiers = []
                commit?(captured)                        // 全部松开 → 提交纯修饰键 chord
            }
            return e                                     // flagsChanged 原样返回
        default:
            return e
        }
    }
}

/// 重启 App（授权后生效 / 菜单「重新启动」共用）。
func restartApp() {
    let bundlePath = Bundle.main.bundlePath
    let task = Process()
    task.launchPath = "/bin/sh"
    task.arguments = ["-c", "sleep 0.5 && open \"\(bundlePath)\""]
    try? task.run()
    NSApp.terminate(nil)
}

/// 面板卡片外观（背景 primary 0.045 + 12pt 内边距）。
extension View {
    func vhCard() -> some View {
        self.padding(12)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.primary.opacity(0.045)))
    }
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

/// 旧 app 配置解码用：老 Mapping 可能缺 mode 字段（v1.x），用 decodeIfPresent 兜底。
private struct LegacyMapping: Decodable {
    let enabled: Bool
    let keys: [String]
    let mode: MappingMode
    private enum CodingKeys: String, CodingKey { case enabled, keys, mode }
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        enabled = (try? c.decode(Bool.self, forKey: .enabled)) ?? false
        keys = (try? c.decode([String].self, forKey: .keys)) ?? []
        mode = (try? c.decode(MappingMode.self, forKey: .mode)) ?? .tap
    }
    var asMapping: Mapping { Mapping(enabled: enabled, keys: keys, mode: mode) }
}

private func decodeLegacyMappings(suite: String, key: String) -> [String: Mapping]? {
    guard let d = UserDefaults(suiteName: suite),
          let data = d.data(forKey: key),
          let dict = try? JSONDecoder().decode([String: LegacyMapping].self, from: data)
    else { return nil }
    return dict.mapValues { $0.asMapping }
}

// MARK: - 共享：NX_KEYTYPE 常量

private let NX_KEYTYPE_SOUND_UP:   Int32 = 0
private let NX_KEYTYPE_SOUND_DOWN: Int32 = 1
private let NX_KEYTYPE_MUTE:       Int32 = 7
private let NX_KEYTYPE_PLAY:       Int32 = 16
private let NX_KEYTYPE_NEXT:       Int32 = 17
// AirPods 三击实测发的是 keyCode 19（NX_KEYTYPE_FAST）；非 Apple 耳机的"上一曲"
// 按钮多数发 18（真正的 NX_KEYTYPE_PREVIOUS）。两者都映射到"三击"。
private let NX_KEYTYPE_FAST:       Int32 = 19
private let NX_KEYTYPE_PREVIOUS:   Int32 = 18

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
        // 用户关掉某行 / 切走 holdToggle 时，释放对应还按着的 hold（init 里直接赋值不触发 didSet，安全）。
        DispatchQueue.main.async {
            AirPodsTap.shared.releaseHoldsForDisabledMappings()
        }
    }

    func resetToDefaults() {
        single     = Mapping(enabled: true,  keys: ["lopt"], mode: .holdToggle)
        double     = Mapping(enabled: false, keys: ["f14"])
        triple     = Mapping(enabled: false, keys: ["f15"])
        volumeUp   = Mapping(enabled: false, keys: ["f16"])
        volumeDown = Mapping(enabled: false, keys: ["f17"])
    }

    /// 从旧版 AirPodsRemap（域 com.xiabill.airpods-remap，key config_v1）导入。
    /// 返回导入项数；读不到旧配置返回 nil。
    func importFromLegacy() -> Int? {
        guard let dict = decodeLegacyMappings(
            suite: "com.xiabill.airpods-remap", key: "config_v1") else { return nil }
        var n = 0
        if let v = dict["single"]     { single = v;     n += 1 }
        if let v = dict["double"]     { double = v;     n += 1 }
        if let v = dict["triple"]     { triple = v;     n += 1 }
        if let v = dict["volumeUp"]   { volumeUp = v;   n += 1 }
        if let v = dict["volumeDown"] { volumeDown = v; n += 1 }
        return n
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
        case NX_KEYTYPE_FAST, NX_KEYTYPE_PREVIOUS: mapping = cfg.triple
        case NX_KEYTYPE_SOUND_UP:   mapping = cfg.volumeUp
        case NX_KEYTYPE_SOUND_DOWN: mapping = cfg.volumeDown
        default: return Unmanaged.passUnretained(event)
        }
        // 已按住的 chord 无论映射当前是否 enabled，再按都能释放（否则 UI 关掉该行后 chord 永久卡住）。
        if isKeyDown, let chord = holdingChords[keyCode] {
            postChordUpSync(keyIds: chord)
            holdingChords.removeValue(forKey: keyCode)
            DispatchQueue.main.async { [weak self] in
                self?.holdingCount = self?.holdingChords.count ?? 0
            }
            return nil
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

    /// 释放那些对应映射已被 disable 或不再是 holdToggle 的 hold，防止 chord 永久卡住。
    /// 在 AirPodsConfig.save() 里调用（用户在 UI 关掉某行时）。只在主线程访问 holdingChords。
    func releaseHoldsForDisabledMappings() {
        let cfg = AirPodsConfig.shared
        for (keyCode, chord) in holdingChords {
            let mapping: Mapping
            switch keyCode {
            case NX_KEYTYPE_PLAY:       mapping = cfg.single
            case NX_KEYTYPE_NEXT:       mapping = cfg.double
            case NX_KEYTYPE_FAST, NX_KEYTYPE_PREVIOUS: mapping = cfg.triple
            case NX_KEYTYPE_SOUND_UP:   mapping = cfg.volumeUp
            case NX_KEYTYPE_SOUND_DOWN: mapping = cfg.volumeDown
            default: continue
            }
            if !mapping.enabled || mapping.mode != .holdToggle {
                postChordUpSync(keyIds: chord)
                holdingChords.removeValue(forKey: keyCode)
            }
        }
        DispatchQueue.main.async { [weak self] in
            self?.holdingCount = self?.holdingChords.count ?? 0
        }
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

/// 用户自学习捕获的按键。usagePage/usage 是 HID 原始值，label 用户命名。
struct CustomRemoteButton: Codable, Identifiable {
    let id: String        // "custom-<n>"
    var label: String
    let usagePage: UInt32
    let usage: UInt32
}

/// HID Keyboard usage page(0x07)→ macOS 虚拟键码。只覆盖常用项，用于给自学习按键
/// 推断 passthrough，以便吞掉系统原生事件。查不到返回 nil。
private let hidKeyboardUsageToVK: [UInt32: UInt16] = [
    // 字母 a-z (0x04-0x1D)
    0x04: 0,  0x05: 11, 0x06: 8,  0x07: 2,  0x08: 14, 0x09: 3,  0x0A: 5,  0x0B: 4,
    0x0C: 34, 0x0D: 38, 0x0E: 40, 0x0F: 37, 0x10: 46, 0x11: 45, 0x12: 31, 0x13: 35,
    0x14: 12, 0x15: 15, 0x16: 1,  0x17: 17, 0x18: 32, 0x19: 9,  0x1A: 13, 0x1B: 7,
    0x1C: 16, 0x1D: 6,
    // 数字 1-0 (0x1E-0x27)
    0x1E: 18, 0x1F: 19, 0x20: 20, 0x21: 21, 0x22: 23, 0x23: 22, 0x24: 26, 0x25: 28,
    0x26: 25, 0x27: 29,
    // Enter/Esc/Backspace/Tab/Space (0x28-0x2C)
    0x28: 36, 0x29: 53, 0x2A: 51, 0x2B: 48, 0x2C: 49,
    // F1-F12 (0x3A-0x45)
    0x3A: 122, 0x3B: 120, 0x3C: 99, 0x3D: 118, 0x3E: 96, 0x3F: 97,
    0x40: 98,  0x41: 100, 0x42: 101, 0x43: 109, 0x44: 103, 0x45: 111,
    // Home/PageUp/ForwardDelete/End/PageDown (0x4A-0x4E)
    0x4A: 115, 0x4B: 116, 0x4C: 117, 0x4D: 119, 0x4E: 121,
    // 方向键 Right/Left/Down/Up (0x4F-0x52)
    0x4F: 124, 0x50: 123, 0x51: 125, 0x52: 126,
]

private func inferPassthrough(usagePage: UInt32, usage: UInt32) -> PassthroughKind {
    if usagePage == 0x07, let vk = hidKeyboardUsageToVK[usage] { return .keyboard(vk) }
    return .none
}

func customToRemoteButton(_ c: CustomRemoteButton) -> RemoteButton {
    RemoteButton(id: c.id, label: c.label, usagePage: c.usagePage, usage: c.usage,
                 passthrough: inferPassthrough(usagePage: c.usagePage, usage: c.usage))
}

/// 先查硬编码 12 颗按键，未命中再查用户自定义按键。
func remoteButton(usagePage: UInt32, usage: UInt32) -> RemoteButton? {
    if let b = buttonByUsage[UInt64(usagePage) << 32 | UInt64(usage)] { return b }
    if let c = RemoteConfig.shared.customButtons.first(where: {
        $0.usagePage == usagePage && $0.usage == usage
    }) { return customToRemoteButton(c) }
    return nil
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
    private let captureAllKey    = "vibehub_remote_capture_all"
    private let vidKey           = "vibehub_remote_target_vid"
    private let pidKey           = "vibehub_remote_target_pid"
    private let customKey        = "vibehub_remote_custom_v1"

    @Published var mappings: [String: Mapping] { didSet { saveMappings() } }
    @Published var customButtons: [CustomRemoteButton] { didSet { saveCustom() } }
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
    /// 全吞模式：开启后遥控器任意键（含未映射 / 未识别）的系统原生行为都被吞掉。
    @Published var captureAllKeys: Bool {
        didSet { UserDefaults.standard.set(captureAllKeys, forKey: captureAllKey) }
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
        if let cdata = UserDefaults.standard.data(forKey: customKey),
           let loaded = try? JSONDecoder().decode([CustomRemoteButton].self, from: cdata) {
            self.customButtons = loaded
        } else {
            self.customButtons = []
        }
        let d = UserDefaults.standard
        self.moduleEnabled            = (d.object(forKey: enabledKey)     as? Bool) ?? true
        self.autoRepeatEnabled        = (d.object(forKey: arEnabledKey)   as? Bool) ?? true
        self.autoRepeatInitialDelayMs = (d.object(forKey: arInitialMsKey) as? Int)  ?? 500
        self.autoRepeatIntervalMs     = (d.object(forKey: arIntervalMsKey) as? Int) ?? 100
        self.captureAllKeys           = (d.object(forKey: captureAllKey) as? Bool) ?? true
        self.targetVID                = (d.object(forKey: vidKey) as? Int) ?? DEFAULT_TARGET_VID
        self.targetPID                = (d.object(forKey: pidKey) as? Int) ?? DEFAULT_TARGET_PID
    }

    private func saveMappings() {
        if let data = try? JSONEncoder().encode(mappings) {
            UserDefaults.standard.set(data, forKey: storeKey)
        }
    }

    private func saveCustom() {
        if let data = try? JSONEncoder().encode(customButtons) {
            UserDefaults.standard.set(data, forKey: customKey)
        }
    }

    /// 添加自学习按键：追加到 customButtons 并建一条默认映射。
    func addCustomButton(label: String, usagePage: UInt32, usage: UInt32) {
        let nums = customButtons.compactMap { Int($0.id.dropFirst("custom-".count)) }
        let n = (nums.max() ?? 0) + 1
        let id = "custom-\(n)"
        customButtons.append(CustomRemoteButton(id: id, label: label,
                                                usagePage: usagePage, usage: usage))
        mappings[id] = Mapping()
    }

    /// 删除自学习按键：清掉按键、映射，并停掉可能残留的 auto-repeat。
    func removeCustomButton(_ id: String) {
        customButtons.removeAll { $0.id == id }
        mappings.removeValue(forKey: id)
        RemoteEngine.shared.stopAutoRepeat(buttonId: id)
    }

    func resetToDefaults() {
        var fresh: [String: Mapping] = [:]
        for b in remoteButtons { fresh[b.id] = Mapping() }
        for c in customButtons { fresh[c.id] = Mapping() }
        mappings = fresh
        autoRepeatEnabled = true
        autoRepeatInitialDelayMs = 500
        autoRepeatIntervalMs = 100
        captureAllKeys = true
        targetVID = DEFAULT_TARGET_VID
        targetPID = DEFAULT_TARGET_PID
    }

    /// 从旧版 RemoteRemap（域 com.xiabill.remote-remap）导入映射与散键设置。
    /// 返回导入的映射条数；读不到旧配置返回 nil。
    func importFromLegacy() -> Int? {
        let suite = "com.xiabill.remote-remap"
        guard let d = UserDefaults(suiteName: suite) else { return nil }
        guard let dict = decodeLegacyMappings(suite: suite, key: "remote_remap_v1") else { return nil }
        var merged = mappings
        for (k, v) in dict { merged[k] = v }
        mappings = merged
        // 散键设置（存在才覆盖）
        if let v = d.object(forKey: "autoRepeatEnabled") as? Bool { autoRepeatEnabled = v }
        if let v = d.object(forKey: "autoRepeatInitialDelayMs") as? Int { autoRepeatInitialDelayMs = v }
        if let v = d.object(forKey: "autoRepeatIntervalMs") as? Int { autoRepeatIntervalMs = v }
        if let v = d.object(forKey: "targetVID") as? Int { targetVID = v }
        if let v = d.object(forKey: "targetPID") as? Int { targetPID = v }
        return dict.count
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

    // —— 自学习模式 ——
    struct LearnedUsage: Equatable { let page: UInt32; let usage: UInt32 }
    @Published var isLearning = false
    @Published var learnedUsage: LearnedUsage?
    @Published var learnDuplicate: String?   // 学习时命中已存在按键 → 该按键 label（提示重复）
    private var learnTimer: Timer?

    // —— 按下反馈 / 最近按键回显（HID 回调在主 runloop，@Published 更新安全）——
    struct LastHIDEvent { let usagePage: UInt32; let usage: UInt32; let buttonLabel: String? }
    @Published var pressedButtonIds: Set<String> = []   // 仅对已知按键维护，抬起移除
    @Published var lastHIDEvent: LastHIDEvent?

    /// 面板打开期间为 true：仍吞原生事件、仍更新回显，但不执行绑定 chord / auto-repeat。
    /// 非 @Published，只在主线程读写（AppDelegate 管理生命周期）。
    var panelVisible = false

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
    private func clearSwallows() {
        swallowLock.lock(); swallowSet.removeAll(); swallowLock.unlock()
        greedyLock.lock(); greedyUntil = 0; greedyLock.unlock()
    }

    // 全吞兜底：遥控器一有按键动作就开一个极短窗，窗口内吞掉一切非自家事件，
    // 覆盖认不出 keycode 的冷门键。窗口过期自动失效（无需清理线程）。
    private var greedyUntil: CFAbsoluteTime = 0
    private let greedyLock = NSLock()
    private func armGreedy(ms: Double) {
        greedyLock.lock(); greedyUntil = CFAbsoluteTimeGetCurrent() + ms / 1000.0; greedyLock.unlock()
    }
    private func inGreedyWindow() -> Bool {
        greedyLock.lock(); defer { greedyLock.unlock() }
        return CFAbsoluteTimeGetCurrent() < greedyUntil
    }

    private func swallowKey(for button: RemoteButton) -> SwallowKey? {
        return swallowKey(forPassthrough: button.passthrough)
    }

    private func swallowKey(forPassthrough pt: PassthroughKind) -> SwallowKey? {
        switch pt {
        case .keyboard(let kc): return .keyboard(Int64(kc))
        case .consumer(let kt): return .consumer(kt)
        case .none:             return nil
        }
    }

    /// keydown 时登记吞键，keyup 时 100ms 延迟摘除（吞掉系统"按起"与 auto-repeat 残留）。
    private func applySwallow(_ sk: SwallowKey, isDown: Bool) {
        if isDown {
            addSwallow(sk)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.removeSwallow(sk)
            }
        }
    }

    /// 登记吞键（与"执行 chord"解耦）。
    /// - 全吞开启：任意非噪声键都吞——能算出 keycode/consumer 的走精确 swallowSet（低误伤），
    ///   同时开短窗贪吞兜底认不出的键。
    /// - 全吞关闭：退回旧行为，仅对"已启用且已绑定"的已知键吞。
    private func captureSwallow(usagePage: UInt32, usage: UInt32, isDown: Bool, known: RemoteButton?) {
        let cfg = RemoteConfig.shared
        guard cfg.captureAllKeys else {
            if let b = known {
                let m = cfg.mappings[b.id] ?? Mapping()
                if m.enabled, !m.keys.isEmpty, let sk = swallowKey(for: b) {
                    applySwallow(sk, isDown: isDown)
                }
            }
            return
        }
        let pt = known?.passthrough ?? inferPassthrough(usagePage: usagePage, usage: usage)
        if let sk = swallowKey(forPassthrough: pt) {
            applySwallow(sk, isDown: isDown)
        }
        armGreedy(ms: 40)
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
        // 全吞兜底：遥控器刚有按键动作，短窗内吞掉一切非自家事件（覆盖认不出 keycode 的键）
        if inGreedyWindow(), type == .keyDown || type == .keyUp || type.rawValue == 14 {
            return nil
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
        stopLearning()
        pressedButtonIds.removeAll()
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
        // 接收器被拔掉时 key-up 永远不来，repeat Timer 会无限发 chord。HID 回调在主
        // runloop，repeatTimers 只在主线程访问，直接停掉所有 auto-repeat。
        stopAllAutoRepeats()
        // 同理：isDown 时加进 swallowSet 的条目等不到 key-up 的延迟摘除，
        // 不清掉会永久吞真实键盘的同键码事件（与 stop() 的配对做法一致）。
        clearSwallows()
        pressedButtonIds.removeAll()   // 拔出时清空按下高亮，防残留（HID 回调在主 runloop）
        DispatchQueue.main.async { [weak self] in
            self?.deviceConnected = !(self?.openedDevices.isEmpty ?? true)
        }
    }

    // HID 回调在主 runloop（IOHIDManagerScheduleWithRunLoop main），@Published 更新安全。
    func startLearning() {
        learnedUsage = nil
        learnDuplicate = nil
        isLearning = true
        armLearnTimeout()
    }

    /// 装/重置 10 秒学习超时（命中重复按键时也重置，给用户重新按的机会）。
    private func armLearnTimeout() {
        learnTimer?.invalidate()
        learnTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { [weak self] _ in
            self?.stopLearning()
        }
    }

    func stopLearning() {
        isLearning = false
        learnDuplicate = nil
        learnTimer?.invalidate()
        learnTimer = nil
    }

    private func handleInputValue(_ value: IOHIDValue) {
        let element = IOHIDValueGetElement(value)
        let usagePage = IOHIDElementGetUsagePage(element)
        let usage = IOHIDElementGetUsage(element)
        let intValue = IOHIDValueGetIntegerValue(value)
        let isDown = (intValue != 0)

        // 噪声：键盘页 reserved/rollover(<0x04) 与修饰键(0xE0-0xE7)、usage 0。这些不回显也不学习。
        let isNoise = usage == 0
            || (usagePage == 0x07 && (usage < 0x04 || (usage >= 0xE0 && usage <= 0xE7)))
        let known = remoteButton(usagePage: usagePage, usage: usage)

        // 回显与按下高亮：无论是否在列表 / 是否学习态都更新 lastHIDEvent（已知给 label，未知给 nil）；
        // pressedButtonIds 只对已知按键维护。
        if isDown && !isNoise {
            lastHIDEvent = LastHIDEvent(usagePage: usagePage, usage: usage, buttonLabel: known?.label)
        }
        if let button = known {
            if isDown { pressedButtonIds.insert(button.id) } else { pressedButtonIds.remove(button.id) }
        }

        // 学习态只拦截按下(value!=0)：key-up 必须放行到正常 dispatch，
        // 否则学习前按住的键抬起被吞，auto-repeat 停不下来、swallowSet 残留。
        if isLearning, isDown {
            if isNoise { return }
            if known != nil {                    // 命中已存在按键 → 提示重复，保持学习态并重置超时
                learnDuplicate = known?.label
                armLearnTimeout()
                return
            }
            learnDuplicate = nil
            learnedUsage = LearnedUsage(page: usagePage, usage: usage)
            stopLearning()
            return  // 学习态下不 dispatch
        }
        // 登记吞键（与"执行 chord"解耦）：全吞模式下含未映射 / 未识别的键
        if !isNoise {
            captureSwallow(usagePage: usagePage, usage: usage, isDown: isDown, known: known)
        }
        guard let button = known else { return }
        dispatch(button: button, isDown: isDown)
    }

    private func dispatch(button: RemoteButton, isDown: Bool) {
        let cfg = RemoteConfig.shared
        let mapping = cfg.mappings[button.id] ?? Mapping()
        guard mapping.enabled, !mapping.keys.isEmpty else { return }
        if isDown {
            // 面板打开时：swallow 已处理（吞掉 OK→Enter 等原生事件），但不执行绑定，
            // 否则切窗/Enter 会抢焦点、把 transient popover 自动关掉、打断输名字。
            if panelVisible { return }
            postChordDownAsync(keyIds: mapping.keys)
            postChordUpAsync(keyIds: mapping.keys)
            startAutoRepeat(buttonId: button.id, keys: mapping.keys)
        } else {
            stopAutoRepeat(buttonId: button.id)  // 抬起始终停 repeat（含面板打开前已启动的）
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

    func stopAutoRepeat(buttonId: String) {
        repeatTimers[buttonId]?.invalidate()
        repeatTimers[buttonId] = nil
    }

    private func stopAllAutoRepeats() {
        for (_, t) in repeatTimers { t.invalidate() }
        repeatTimers.removeAll()
    }
}

// MARK: - 共享：系统麦克风输入监测（当前输入设备 + 按需电平表）

/// 只读展示"系统默认输入设备"名称/UID（纯 CoreAudio 属性，不开麦、不需权限），
/// 并提供按需的麦克风电平测试（点一下才开麦，超时/停止自动关，把对遥控器自带 mic
/// 断流特性的影响降到最低）。
final class AudioInputMonitor: ObservableObject {
    static let shared = AudioInputMonitor()

    @Published private(set) var inputName: String = "—"
    @Published private(set) var inputUID: String = ""
    @Published private(set) var isTesting = false
    @Published private(set) var level: Float = 0      // 0...1 归一化电平
    @Published private(set) var testError: String?

    private var engine: AVAudioEngine?
    private var timeoutItem: DispatchWorkItem?
    private var defaultInputAddr = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDefaultInputDevice,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain)

    private init() {
        refresh()
        // 系统默认输入设备变化时实时刷新显示
        AudioObjectAddPropertyListenerBlock(
            AudioObjectID(kAudioObjectSystemObject), &defaultInputAddr, DispatchQueue.main
        ) { [weak self] _, _ in self?.refresh() }
    }

    /// 刷新"当前系统默认输入设备"名称 + UID。纯只读属性，不激活麦克风。
    func refresh() {
        var devID = AudioDeviceID(0)
        var size = UInt32(MemoryLayout<AudioDeviceID>.size)
        let st = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject),
                                            &defaultInputAddr, 0, nil, &size, &devID)
        guard st == noErr, devID != 0 else {
            inputName = "（无输入设备）"; inputUID = ""; return
        }
        inputName = deviceString(devID, kAudioObjectPropertyName) ?? "未知设备"
        inputUID  = deviceString(devID, kAudioDevicePropertyDeviceUID) ?? ""
    }

    private func deviceString(_ dev: AudioDeviceID, _ selector: AudioObjectPropertySelector) -> String? {
        var addr = AudioObjectPropertyAddress(
            mSelector: selector,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain)
        var value: CFString? = nil
        var size = UInt32(MemoryLayout<CFString?>.size)
        guard AudioObjectGetPropertyData(dev, &addr, 0, nil, &size, &value) == noErr else { return nil }
        return value as String?
    }

    /// 按需开麦测电平：先请求麦克风权限，授权后启动 AVAudioEngine 读 RMS。
    func startTest() {
        guard !isTesting else { return }
        testError = nil
        AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
            DispatchQueue.main.async {
                guard let self else { return }
                if granted { self.beginEngine() }
                else { self.testError = "麦克风权限被拒绝：系统设置 → 隐私与安全性 → 麦克风 开启 VibeHub" }
            }
        }
    }

    private func beginEngine() {
        refresh()
        let eng = AVAudioEngine()
        let input = eng.inputNode
        let fmt = input.inputFormat(forBus: 0)
        guard fmt.sampleRate > 0, fmt.channelCount > 0 else {
            testError = "无法读取输入设备格式（设备可能未就绪或被占用）"; return
        }
        input.installTap(onBus: 0, bufferSize: 1024, format: fmt) { [weak self] buffer, _ in
            guard let ch = buffer.floatChannelData?[0] else { return }
            let n = Int(buffer.frameLength)
            if n == 0 { return }
            var sum: Float = 0
            for i in 0..<n { let s = ch[i]; sum += s * s }
            let rms = sqrtf(sum / Float(n))
            let db = 20 * log10f(max(rms, 1e-7))
            let norm = max(0, min(1, (db + 60) / 60))   // -60dB..0dB → 0..1
            DispatchQueue.main.async { self?.level = norm }
        }
        do {
            try eng.start()
            engine = eng
            isTesting = true
            // 15 秒自动停（遥控器自带 mic 撑不了太久，测试用够了）
            let item = DispatchWorkItem { [weak self] in self?.stopTest() }
            timeoutItem = item
            DispatchQueue.main.asyncAfter(deadline: .now() + 15, execute: item)
        } catch {
            testError = "启动麦克风失败：\(error.localizedDescription)"
        }
    }

    func stopTest() {
        timeoutItem?.cancel(); timeoutItem = nil
        if let eng = engine {
            eng.inputNode.removeTap(onBus: 0)
            eng.stop()
        }
        engine = nil
        isTesting = false
        level = 0
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

/// chord 键帽 chip（等宽小圆角标签）。
struct KeyChip: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(.caption, design: .monospaced))
            .padding(.horizontal, 6).padding(.vertical, 3)
            .background(RoundedRectangle(cornerRadius: 5).fill(Color.secondary.opacity(0.15)))
    }
}

/// ⓘ 说明按钮：.help() tooltip + 点击 popover 双保险。
struct InfoPopoverButton<Content: View>: View {
    let help: String
    @ViewBuilder let content: () -> Content
    @State private var shown = false
    var body: some View {
        Button { shown.toggle() } label: {
            Image(systemName: "info.circle").font(.system(size: 11))
        }
        .buttonStyle(.borderless)
        .help(help)
        .popover(isPresented: $shown, arrowEdge: .bottom) {
            content()
                .font(.caption)
                .fixedSize(horizontal: false, vertical: true)
                .padding(10)
                .frame(width: 250)
        }
    }
}

/// 一行绑定：启用 Toggle + 手势名 + chord chips + 录制按钮 +（可选）模式菜单 + 手动编辑菜单。
struct KeyPickerRow: View {
    let label: String
    let labelWidth: CGFloat
    @Binding var mapping: Mapping
    let showModePicker: Bool  // AirPods=true（点按/按住），Remote=false
    let rowId: String
    @Binding var recordingRowId: String?
    var isPressed: Bool = false   // Remote：该按键此刻被按下 → 行背景闪 accent

    @StateObject private var recorder = KeyRecorder()

    private var isRecording: Bool { recordingRowId == rowId }

    var body: some View {
        HStack(spacing: 6) {
            Toggle("", isOn: $mapping.enabled).labelsHidden().controlSize(.small)
            Text(label).frame(width: labelWidth, alignment: .leading).font(.system(size: 12))
            Spacer(minLength: 4)
            if isRecording {
                Text("按下快捷键…")
                    .font(.caption).foregroundColor(.accentColor)
                    .padding(.horizontal, 6).padding(.vertical, 3)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.accentColor, lineWidth: 1))
            } else {
                chips
            }
            if showModePicker { modeMenu }
            recordButton
            manualMenu
        }
        .padding(.horizontal, 4).padding(.vertical, 1)
        .background(RoundedRectangle(cornerRadius: 5)
            .fill(Color.accentColor.opacity(isPressed ? 0.2 : 0)))
        .onChange(of: isRecording) { rec in
            if rec {
                recorder.start(
                    commit: { keys in
                        mapping.keys = keys
                        mapping.enabled = true       // 录完即启用，否则绑了不生效令人困惑
                        recordingRowId = nil
                    },
                    cancel: { recordingRowId = nil }
                )
            } else {
                recorder.stop()
            }
        }
        .onDisappear {
            if isRecording { recordingRowId = nil }  // popover 关闭强制取消
            recorder.stop()
        }
    }

    private var chips: some View {
        HStack(spacing: 3) {
            if mapping.keys.isEmpty {
                Text("未绑定").font(.caption).foregroundColor(.secondary)
            } else {
                ForEach(Array(mapping.keys.enumerated()), id: \.offset) { _, k in
                    KeyChip(text: keyChoice(k)?.shortLabel ?? "?")
                }
            }
        }
    }

    private var recordButton: some View {
        Button {
            recordingRowId = isRecording ? nil : rowId
        } label: {
            Image(systemName: isRecording ? "stop.circle.fill" : "record.circle")
                .foregroundColor(isRecording ? .accentColor : nil)
        }
        .buttonStyle(.borderless)
        .help(isRecording ? "停止录制" : "录制快捷键")
    }

    private var modeMenu: some View {
        Menu {
            Button("点按") { mapping.mode = .tap }
            Button("按住") { mapping.mode = .holdToggle }
        } label: {
            Text(mapping.mode == .tap ? "点按" : "按住").font(.caption)
        }
        .menuStyle(.borderlessButton).fixedSize()
        .disabled(!mapping.enabled)
    }

    private func setKey(_ idx: Int, _ id: String) {
        if idx < mapping.keys.count { mapping.keys[idx] = id }
    }
    private func removeKey(_ idx: Int) {
        if idx < mapping.keys.count { mapping.keys.remove(at: idx) }
    }

    /// 手动编辑：逐键改 / 删键 / 追加键（F13–F20 等按不出来的键靠它）。
    private var manualMenu: some View {
        Menu {
            ForEach(mapping.keys.indices, id: \.self) { idx in
                Menu {
                    ForEach(keyChoices) { c in
                        Button(c.label) { setKey(idx, c.id) }
                    }
                    if mapping.keys.count > 1 {
                        Divider()
                        Button("删除此键", role: .destructive) { removeKey(idx) }
                    }
                } label: {
                    Text("第 \(idx + 1) 键：\(keyChoice(mapping.keys[idx])?.shortLabel ?? "?")")
                }
            }
            Divider()
            Button("追加按键") { mapping.keys.append("lopt") }
        } label: {
            Image(systemName: "ellipsis")
        }
        .menuStyle(.borderlessButton).fixedSize()
        .help("手动编辑绑定")
    }
}

// MARK: - UI: 权限引导卡

enum PermissionKind {
    case accessibility, inputMonitoring

    var name: String {
        switch self {
        case .accessibility:  return "辅助功能"
        case .inputMonitoring: return "输入监听"
        }
    }
    var icon: String {
        switch self {
        case .accessibility:  return "hand.raised"
        case .inputMonitoring: return "keyboard"
        }
    }
    var url: String {
        switch self {
        case .accessibility:
            return "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
        case .inputMonitoring:
            return "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent"
        }
    }
    func granted() -> Bool {
        switch self {
        case .accessibility:
            return AXIsProcessTrusted()
        case .inputMonitoring:
            return IOHIDCheckAccess(kIOHIDRequestTypeListenEvent) == kIOHIDAccessTypeGranted
        }
    }
}

/// 缺权限时显示的橙色引导卡。面板可见期间每 1 秒轮询；授权后变 ✓ 并提示重启；全就绪且从未缺失则隐藏。
struct PermissionCard: View {
    let specs: [PermissionKind]
    @State private var granted: [Bool] = []
    @State private var everMissing = false
    @State private var timer: Timer?

    private func refresh() {
        let g = specs.map { $0.granted() }
        granted = g
        if g.contains(false) { everMissing = true }
    }
    private var allGranted: Bool { !granted.isEmpty && !granted.contains(false) }

    var body: some View {
        Group {
            if granted.isEmpty || (allGranted && !everMissing) {
                Color.clear.frame(height: 0)
            } else {
                content
            }
        }
        .onAppear {
            refresh()
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in refresh() }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.shield")
                Text("需要权限").font(.subheadline.weight(.semibold))
            }
            ForEach(Array(specs.enumerated()), id: \.offset) { i, spec in
                HStack(spacing: 6) {
                    Image(systemName: spec.icon).frame(width: 16)
                    Text(spec.name).font(.caption)
                    Spacer()
                    if i < granted.count, granted[i] {
                        Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                    } else {
                        Image(systemName: "xmark.circle.fill").foregroundColor(.orange)
                        Button("去开启") { NSWorkspace.shared.open(URL(string: spec.url)!) }
                            .buttonStyle(.borderless).font(.caption)
                    }
                }
            }
            if allGranted && everMissing {
                Divider()
                HStack(spacing: 6) {
                    Text("已授权，重启 App 生效").font(.caption).foregroundColor(.secondary)
                    Spacer()
                    Button("重启") { restartApp() }.font(.caption)
                }
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.orange.opacity(0.09)))
    }
}

// MARK: - UI: AirPods Tab

struct AirPodsTabView: View {
    @ObservedObject var config = AirPodsConfig.shared
    @ObservedObject var tap = AirPodsTap.shared
    @Binding var recordingRowId: String?
    @State private var actionMsg: String?

    /// 开关绑定：读 tap.isRunning，start() 失败时 isRunning 仍为 false → 开关自动弹回。
    private var moduleToggle: Binding<Bool> {
        Binding(
            get: { tap.isRunning },
            set: { want in
                if want {
                    if tap.start() {
                        config.moduleEnabled = true
                    } else {
                        // start() 失败不触碰任何 @Published，SwiftUI 不会重读 get，
                        // 开关会视觉停在 ON。手动发一次变更让它弹回。
                        DispatchQueue.main.async { tap.objectWillChange.send() }
                    }
                } else {
                    tap.stop()
                    config.moduleEnabled = false
                }
            }
        )
    }

    var body: some View {
        VStack(spacing: 10) {
            moduleCard
            PermissionCard(specs: [.accessibility])
            bindingsCard
        }
        .padding(12)
        .frame(width: 360, alignment: .top)
    }

    private var moduleCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "earbuds")
                Text("AirPods / 蓝牙耳机").font(.subheadline.weight(.semibold))
                InfoPopoverButton(help: "机型支持说明") {
                    Text("AirPods Pro 2 / Pro 3 的 stem 事件走 MediaRemote 私有 IPC，所有同类工具都拦不到。普通 AirPods / AirPods Max 正常工作。")
                }
                Spacer()
                moduleMenu
                Toggle("", isOn: moduleToggle)
                    .labelsHidden().toggleStyle(.switch).controlSize(.small)
            }
            HStack(spacing: 6) {
                Circle().fill(tap.isRunning ? Color.green : Color.secondary).frame(width: 8, height: 8)
                Text(tap.isRunning ? "运行中" : "已暂停").font(.caption).foregroundColor(.secondary)
                if let msg = actionMsg {
                    Text("· \(msg)").font(.caption).foregroundColor(.secondary)
                }
            }
        }
        .vhCard()
    }

    private var moduleMenu: some View {
        Menu {
            Button("重置默认") {
                config.resetToDefaults()
                actionMsg = "已重置"
            }
            Button("从旧版导入") {
                if let n = config.importFromLegacy() {
                    actionMsg = "已导入 \(n) 项"
                } else {
                    actionMsg = "无旧版配置"
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
        .menuStyle(.borderlessButton).fixedSize()
    }

    private var bindingsCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Text("手势绑定").font(.subheadline.weight(.semibold))
                InfoPopoverButton(help: "点按 / 按住 说明") {
                    Text("「点按」= 按一下立刻松开（适合 ⌘C / F13 等）；「按住」= 按一下按住、再按一下释放（适合 Typeless / WhisperKey 长按 ⌥ 录音）。")
                }
                Spacer()
            }
            row("单击",  $config.single,     "ap-single")
            row("双击",  $config.double,     "ap-double")
            row("三击",  $config.triple,     "ap-triple")
            row("音量+", $config.volumeUp,   "ap-volup")
            row("音量-", $config.volumeDown, "ap-voldn")
            if config.volumeUp.enabled || config.volumeDown.enabled {
                Text("绑定音量键后耳机将无法调节系统音量")
                    .font(.caption2).foregroundColor(.orange)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .vhCard()
    }

    private func row(_ label: String, _ m: Binding<Mapping>, _ id: String) -> some View {
        KeyPickerRow(label: label, labelWidth: 46, mapping: m, showModePicker: true,
                     rowId: id, recordingRowId: $recordingRowId)
    }
}

// MARK: - UI: Remote Tab

struct RemoteTabView: View {
    @ObservedObject var config = RemoteConfig.shared
    @ObservedObject var engine = RemoteEngine.shared
    @ObservedObject var audio = AudioInputMonitor.shared
    @Binding var recordingRowId: String?
    @State private var detectedDevices: [DetectedDevice] = []
    @State private var learnName: String = ""
    @State private var actionMsg: String?

    private let groupDpad   = ["up", "down", "left", "right", "ok", "menu"]
    private let groupSystem = ["home", "back", "voice"]
    private let groupVolume = ["mute", "volup", "voldn"]

    private func scanDevicesAsync() {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = enumerateRemoteCandidates()
            DispatchQueue.main.async { self.detectedDevices = result }
        }
    }

    /// 开关绑定：start() 可能返回 true 但 tap 装不上（会写 lastError），isRunning 反映真实态。
    private var moduleToggle: Binding<Bool> {
        Binding(
            get: { engine.isRunning },
            set: { want in
                if want {
                    if engine.start() { config.moduleEnabled = true }
                } else {
                    engine.stop()
                    config.moduleEnabled = false
                }
            }
        )
    }

    var body: some View {
        VStack(spacing: 10) {
            moduleCard
            PermissionCard(specs: [.accessibility, .inputMonitoring])
            bindingsCard
            deviceCard
            micCard
            advancedCard
        }
        .padding(12)
        .frame(width: 360, alignment: .top)
    }

    // —— 模块卡 ——

    private var moduleCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "av.remote")
                Text("2.4G 遥控键盘").font(.subheadline.weight(.semibold))
                Spacer()
                moduleMenu
                Toggle("", isOn: moduleToggle)
                    .labelsHidden().toggleStyle(.switch).controlSize(.small)
            }
            HStack(spacing: 6) {
                Circle()
                    .fill(engine.isRunning && engine.deviceConnected ? Color.green
                          : engine.isRunning ? Color.orange : Color.secondary)
                    .frame(width: 8, height: 8)
                Text(engine.isRunning
                     ? (engine.deviceConnected ? "运行中" : "等待设备")
                     : "已暂停")
                    .font(.caption).foregroundColor(.secondary)
                Text(currentDeviceLabel)
                    .font(.system(size: 10, design: .monospaced)).foregroundColor(.secondary)
                if let msg = actionMsg {
                    Text("· \(msg)").font(.caption).foregroundColor(.secondary)
                }
            }
            if let err = engine.lastError {
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "exclamationmark.triangle").foregroundColor(.orange).font(.caption)
                    Text(err).font(.caption2).foregroundColor(.orange)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    Button("重启") { restartApp() }.font(.caption)
                }
            }
        }
        .vhCard()
    }

    private var moduleMenu: some View {
        Menu {
            Button("重置默认") {
                config.resetToDefaults()
                engine.restart()
                actionMsg = "已重置"
            }
            Button("从旧版导入") {
                if let n = config.importFromLegacy() {
                    engine.restart()
                    actionMsg = "已导入 \(n) 项"
                } else {
                    actionMsg = "无旧版配置"
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
        .menuStyle(.borderlessButton).fixedSize()
    }

    private var currentDeviceLabel: String {
        String(format: "0x%04X:0x%04X", config.targetVID, config.targetPID)
    }

    // —— 绑定卡 ——

    private var bindingsCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("按键绑定").font(.subheadline.weight(.semibold))
            sectionGroup("方向 / 确认", ids: groupDpad)
            sectionGroup("系统功能",    ids: groupSystem)
            sectionGroup("音量",        ids: groupVolume)
        }
        .vhCard()
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
                    mapping: config.binding(for: id), showModePicker: false,
                    rowId: "rm-\(id)", recordingRowId: $recordingRowId,
                    isPressed: engine.pressedButtonIds.contains(id))
            }
        }
    }

    // —— 设备卡 ——

    private var deviceCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("目标设备").font(.subheadline.weight(.semibold))
                Spacer()
                deviceMenu
            }
            Text(currentDeviceLabel)
                .font(.system(size: 11, design: .monospaced))
                .padding(.horizontal, 6).padding(.vertical, 3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.secondary.opacity(0.1)).cornerRadius(4)
            if !engine.deviceConnected && engine.isRunning {
                Text("当前 VID/PID 没找到匹配设备，点「切换…」选择已插着的硬件。")
                    .font(.caption2).foregroundColor(.orange)
                    .fixedSize(horizontal: false, vertical: true)
            }
            lastKeyRow
            Divider()
            Text("自定义按键").font(.caption2).foregroundColor(.secondary)
            ForEach(config.customButtons) { c in
                HStack(spacing: 4) {
                    KeyPickerRow(label: c.label, labelWidth: 68,
                        mapping: config.binding(for: c.id), showModePicker: false,
                        rowId: "rm-\(c.id)", recordingRowId: $recordingRowId,
                        isPressed: engine.pressedButtonIds.contains(c.id))
                    Button { config.removeCustomButton(c.id) } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.borderless).help("删除此自定义按键")
                }
            }
            learnControls
        }
        .vhCard()
    }

    /// 最近按键回显 + 常驻提示：已知给 label+usage，未知给橙色发现提示，无事件给灰字。
    @ViewBuilder private var lastKeyRow: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .top, spacing: 4) {
                Text("最近按键").font(.caption2).foregroundColor(.secondary)
                if let e = engine.lastHIDEvent {
                    if let lbl = e.buttonLabel {
                        Text(String(format: "%@ (0x%02X:0x%02X)", lbl, e.usagePage, e.usage))
                            .font(.system(size: 11, design: .monospaced)).foregroundColor(.secondary)
                    } else {
                        Text(String(format: "未知按键 0x%02X:0x%02X — 可通过下方「学习新按键」添加",
                                    e.usagePage, e.usage))
                            .font(.caption2).foregroundColor(.orange)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                } else {
                    Text("按一下遥控器试试").font(.caption2).foregroundColor(.secondary)
                }
                Spacer(minLength: 0)
            }
            Text("面板打开时按键不执行绑定（配置模式）")
                .font(.caption2).foregroundColor(.secondary)
        }
    }

    private var deviceMenu: some View {
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

    @ViewBuilder private var learnControls: some View {
        if engine.isLearning {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    ProgressView().controlSize(.small)
                    Text("请按下遥控器上要添加的按键…（10 秒）")
                        .font(.caption).foregroundColor(.secondary)
                    Spacer()
                    Button("取消") { engine.stopLearning() }
                        .buttonStyle(.borderless).font(.caption)
                }
                if let dup = engine.learnDuplicate {
                    Text("该按键已存在：\(dup)，请按其他键")
                        .font(.caption2).foregroundColor(.orange)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        } else if let lu = engine.learnedUsage {
            VStack(alignment: .leading, spacing: 4) {
                Text(String(format: "已捕获 0x%02X:0x%02X，命名后保存", lu.page, lu.usage))
                    .font(.system(size: 11, design: .monospaced)).foregroundColor(.secondary)
                HStack(spacing: 6) {
                    TextField("按键名称", text: $learnName)
                        .textFieldStyle(.roundedBorder).controlSize(.small)
                    Button("确认") {
                        let name = learnName.trimmingCharacters(in: .whitespaces)
                        let fallback = String(format: "0x%02X:0x%02X", lu.page, lu.usage)
                        config.addCustomButton(label: name.isEmpty ? fallback : name,
                                               usagePage: lu.page, usage: lu.usage)
                        learnName = ""
                        engine.learnedUsage = nil
                    }.font(.caption)
                    Button("取消") {
                        learnName = ""
                        engine.learnedUsage = nil
                    }.buttonStyle(.borderless).font(.caption)
                }
            }
        } else {
            HStack {
                Button {
                    learnName = ""
                    engine.startLearning()
                } label: {
                    Label("学习新按键", systemImage: "plus")
                }.buttonStyle(.borderless).font(.caption)
                if !engine.isRunning {
                    Text("需先启动 Remote 模块").font(.caption2).foregroundColor(.secondary)
                }
            }
        }
    }

    // —— 高级卡 ——

    private var advancedCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("完全接管遥控器").font(.subheadline.weight(.semibold))
                    Spacer()
                    Toggle("", isOn: $config.captureAllKeys)
                        .toggleStyle(.switch).labelsHidden().controlSize(.mini)
                }
                Text(config.captureAllKeys
                     ? "遥控器所有按键（含未映射 / 未识别）的系统原生行为都被吞掉，只走你的映射。"
                     : "仅吞掉已绑定按键的系统行为；未映射的键仍会触发系统。")
                    .font(.caption2).foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                if config.captureAllKeys {
                    Text("注意：按遥控器后约 40ms 内主键盘按下的键可能被一并吞掉（极少同时发生）；语音键触发的系统听写走私有路径无法拦截。")
                        .font(.caption2).foregroundColor(.orange)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Divider()
            HStack {
                Text("长按自动重复").font(.subheadline.weight(.semibold))
                Spacer()
                Toggle("", isOn: $config.autoRepeatEnabled)
                    .toggleStyle(.switch).labelsHidden().controlSize(.mini)
            }
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
        .vhCard()
    }

    // —— 麦克风输入卡 ——

    private var micCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("麦克风输入").font(.subheadline.weight(.semibold))
                Spacer()
                if audio.isTesting {
                    Button("停止") { audio.stopTest() }
                        .buttonStyle(.borderless).font(.caption)
                } else {
                    Button {
                        scanDevicesAsync()   // 刷新 HID 名，供是否遥控器匹配
                        audio.startTest()
                    } label: {
                        Label("测试麦克风", systemImage: "mic")
                    }.buttonStyle(.borderless).font(.caption)
                }
            }
            // 当前系统默认输入设备 + 是否遥控器徽标
            HStack(spacing: 6) {
                Image(systemName: "waveform").font(.caption).foregroundColor(.secondary)
                Text(audio.inputName)
                    .font(.system(size: 11, design: .monospaced))
                    .lineLimit(1).truncationMode(.middle)
                if inputLooksLikeRemote {
                    Text("遥控器").font(.caption2)
                        .padding(.horizontal, 5).padding(.vertical, 1)
                        .background(Color.green.opacity(0.18))
                        .foregroundColor(.green).cornerRadius(3)
                }
                Spacer(minLength: 0)
            }
            Text(inputLooksLikeRemote
                 ? "当前系统输入正是这个遥控器的麦克风"
                 : "当前系统输入不是遥控器（或设备名未能匹配）")
                .font(.caption2).foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            // 电平表（仅测试期间）
            if audio.isTesting {
                VStack(alignment: .leading, spacing: 3) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3).fill(Color.secondary.opacity(0.15))
                            RoundedRectangle(cornerRadius: 3)
                                .fill(audio.level > 0.02 ? Color.green : Color.secondary.opacity(0.4))
                                .frame(width: max(2, geo.size.width * CGFloat(audio.level)))
                        }
                    }
                    .frame(height: 8)
                    Text("对着遥控器说话，绿条应随声音跳动（15 秒后自动停）")
                        .font(.caption2).foregroundColor(.secondary)
                }
            }
            if let err = audio.testError {
                Text(err).font(.caption2).foregroundColor(.orange)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .vhCard()
        .onAppear { audio.refresh() }
        .onDisappear { audio.stopTest() }
    }

    /// best-effort 判断"系统默认输入设备是不是当前目标遥控器"。
    /// 先看设备 UID 里是否同时含目标 VID+PID 的 hex（强信号），再退到设备名/厂商名模糊匹配。
    // ponytail: 名称启发式，跨设备命名不一致可能漏判；漏判时只是不显示徽标，不会误接管。
    private var inputLooksLikeRemote: Bool {
        let uid = audio.inputUID.lowercased()
        if !uid.isEmpty {
            let vidHex = String(format: "%04x", config.targetVID)
            let pidHex = String(format: "%04x", config.targetPID)
            if uid.contains(vidHex) && uid.contains(pidHex) { return true }
        }
        let inNorm = normalizeName(audio.inputName)
        guard !inNorm.isEmpty else { return false }
        let target = detectedDevices.first {
            $0.vendorId == config.targetVID && $0.productId == config.targetPID
        }
        for cand in [target?.product, target?.manufacturer].compactMap({ $0 }) {
            let c = normalizeName(cand)
            if c.count >= 3 && (inNorm.contains(c) || c.contains(inNorm)) { return true }
        }
        return false
    }

    private func normalizeName(_ s: String) -> String {
        s.lowercased().filter { $0.isLetter || $0.isNumber }
    }
}

// MARK: - UI: 主面板（segmented picker + ZStack，Tab 切换不重建视图树）

struct ContentView: View {
    @ObservedObject var loginItem = LaunchAtLogin.shared
    @State private var selectedTab: String = "airpods"
    @State private var recordingRowId: String? = nil   // 全局唯一录制行；切 Tab 时清空

    private var appVersion: String {
        (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? "dev"
    }

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
            .onChange(of: selectedTab) { _ in recordingRowId = nil }

            Divider()

            ZStack(alignment: .top) {
                AirPodsTabView(recordingRowId: $recordingRowId)
                    .opacity(selectedTab == "airpods" ? 1 : 0)
                    .allowsHitTesting(selectedTab == "airpods")
                RemoteTabView(recordingRowId: $recordingRowId)
                    .opacity(selectedTab == "remote" ? 1 : 0)
                    .allowsHitTesting(selectedTab == "remote")
            }
            .frame(width: 360)

            Divider()

            HStack(spacing: 8) {
                Toggle(isOn: Binding(
                    get: { loginItem.isEnabled },
                    set: { loginItem.setEnabled($0) }
                )) { Text("开机自启").font(.caption) }
                .toggleStyle(.checkbox)
                Text("v\(appVersion)").font(.caption2).foregroundColor(.secondary)
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
        .frame(width: 360)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

// MARK: - AppDelegate（状态栏 + 弹层 + 右键菜单）

final class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
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

        // 锁屏/睡眠时释放所有 hold，否则 Opt 等修饰键会卡在按下状态，解锁输密码全错。
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.willSleepNotification, object: nil, queue: .main
        ) { _ in AirPodsTap.shared.releaseAllHeld() }
        DistributedNotificationCenter.default().addObserver(
            forName: Notification.Name("com.apple.screenIsLocked"), object: nil, queue: .main
        ) { _ in AirPodsTap.shared.releaseAllHeld() }

        popover = NSPopover()
        popover.behavior = .transient
        popover.animates = false  // 关掉默认 ~200ms 弹出动画，状态栏点击立即响应
        popover.delegate = self   // popoverDidClose → panelVisible = false

        // 预热：先把 host 挂到一个屏外隐藏 window 里强制 SwiftUI 渲染整棵树，
        // 然后再交给 popover。否则 SwiftUI 只在视图真正进入 window 时才 build body，
        // 首次点击图标时要现场建整棵树。
        // sizingOptions=.preferredContentSize 让 host 把 SwiftUI 理想高度同步给 popover（面板自适应高度）。
        let host = NSHostingController(rootView: ContentView())
        host.sizingOptions = [.preferredContentSize]
        let warmup = NSWindow(
            contentRect: NSRect(x: -50000, y: -50000, width: 360, height: 900),
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
        button.image = Self.statusIcon
    }

    /// 程序内绘制的 18×18 template 图标：圆角方框线框内三根垂直圆头波形短柱（中高两侧低）。
    private static let statusIcon: NSImage = {
        let img = NSImage(size: NSSize(width: 18, height: 18), flipped: false) { rect in
            NSColor.black.setStroke()
            NSColor.black.setFill()
            let frame = rect.insetBy(dx: 1.5, dy: 1.5)
            let box = NSBezierPath(roundedRect: frame, xRadius: 4, yRadius: 4)
            box.lineWidth = 1.5
            box.stroke()
            let barW: CGFloat = 1.8
            let spacing: CGFloat = 3.2
            let heights: [CGFloat] = [4.5, 7.0, 4.5]
            let xs: [CGFloat] = [rect.midX - spacing, rect.midX, rect.midX + spacing]
            for (i, x) in xs.enumerated() {
                let h = heights[i]
                let bar = NSRect(x: x - barW / 2, y: rect.midY - h / 2, width: barW, height: h)
                NSBezierPath(roundedRect: bar, xRadius: barW / 2, yRadius: barW / 2).fill()
            }
            return true
        }
        img.isTemplate = true
        return img
    }()

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
            popover.performClose(sender)   // → popoverDidClose 置 panelVisible = false
        } else {
            RemoteEngine.shared.panelVisible = true
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    // transient 自动关 / performClose 都会回调这里：面板不可见后恢复按键执行绑定。
    func popoverDidClose(_ notification: Notification) {
        RemoteEngine.shared.panelVisible = false
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
            let names = m.keys.compactMap { keyChoice($0)?.shortLabel }.joined(separator: " ")
            let item = NSMenuItem(title: "  \(label) → \(names)", action: nil, keyEquivalent: "")
            item.isEnabled = false
            menu.addItem(item)
        }
        let remCfg = RemoteConfig.shared
        for b in remoteButtons {
            guard let m = remCfg.mappings[b.id], m.enabled, !m.keys.isEmpty else { continue }
            let names = m.keys.compactMap { keyChoice($0)?.shortLabel }.joined(separator: " ")
            let item = NSMenuItem(title: "  Remote \(b.label) → \(names)",
                action: nil, keyEquivalent: "")
            item.isEnabled = false
            menu.addItem(item)
        }
        for c in remCfg.customButtons {
            guard let m = remCfg.mappings[c.id], m.enabled, !m.keys.isEmpty else { continue }
            let names = m.keys.compactMap { keyChoice($0)?.shortLabel }.joined(separator: " ")
            let item = NSMenuItem(title: "  Remote \(c.label) → \(names)",
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
        let version = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? "dev"
        let alert = NSAlert()
        alert.icon = NSApp.applicationIconImage
        alert.messageText = "VibeHub \(version)"
        alert.informativeText = """
            把 AirPods / 蓝牙耳机与 2.4G 遥控键盘的按键统一录制并映射到任意 macOS 键盘 chord。

            左键状态栏图标打开配置，右键打开快捷菜单。
            https://github.com/xiabill/VibeHub
            """
        alert.runModal()
    }
    @objc private func menuRestart() { restartApp() }
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
