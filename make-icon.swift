import Cocoa

// 颜色助手
func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> NSColor {
    NSColor(red: r, green: g, blue: b, alpha: a)
}

// ---- 分层 / 深色模式支持（macOS 26 Icon Composer .icon 用）----
// 每层单独输出透明底 PNG，背景全出血（系统按 squircle 裁切）。
struct Palette {
    let bg: [NSColor]        // 底渐变 2 色
    let cap: [NSColor]       // 键帽渐变 2 色
    let capShadow: NSColor   // 键帽投影
    let wave: [NSColor]      // 波形渐变 2 色
}

// 浅色 = 现有设计
let lightPal = Palette(
    bg:  [rgb(0.310, 0.275, 0.898), rgb(0.486, 0.227, 0.929)],   // #4F46E5 → #7C3AED
    cap: [rgb(0.980, 0.980, 0.980), rgb(0.929, 0.929, 0.949)],   // #FAFAFA → #EDEDF2
    capShadow: rgb(0.231, 0.180, 0.549, 0.35),
    wave: [rgb(0.310, 0.275, 0.898), rgb(0.486, 0.227, 0.929)])

// 深色
let darkPal = Palette(
    bg:  [rgb(0.118, 0.106, 0.212), rgb(0.298, 0.114, 0.584)],   // #1E1B36 → #4C1D95
    cap: [rgb(0.165, 0.165, 0.200), rgb(0.129, 0.129, 0.157)],   // #2A2A33 → #212128 深石板灰
    capShadow: rgb(0, 0, 0, 0.50),
    wave: [rgb(0.655, 0.545, 0.980), rgb(0.545, 0.361, 0.965)])  // #A78BFA → #8B5CF6 亮紫

func withCanvas(_ pxSize: Int, _ draw: (CGFloat) -> Void) -> Data? {
    let cs = CGColorSpaceCreateDeviceRGB()
    guard let ctx = CGContext(data: nil, width: pxSize, height: pxSize,
                              bitsPerComponent: 8, bytesPerRow: 0, space: cs,
                              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
    let ns = NSGraphicsContext(cgContext: ctx, flipped: false)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = ns
    draw(CGFloat(pxSize))
    NSGraphicsContext.restoreGraphicsState()
    guard let img = ctx.makeImage() else { return nil }
    return NSBitmapImageRep(cgImage: img).representation(using: .png, properties: [:])
}

// 背景：全出血渐变 + 顶部高光 + 底部内阴影带
func drawBackground(_ size: CGFloat, _ pal: Palette) {
    let bodyRect = NSRect(x: 0, y: 0, width: size, height: size)
    let bgPath = NSBezierPath(rect: bodyRect)
    NSGradient(colors: pal.bg)!.draw(in: bgPath, angle: -45)

    NSGraphicsContext.saveGraphicsState()
    bgPath.addClip()
    let glow = NSGradient(colors: [rgb(1, 1, 1, 0.10), rgb(1, 1, 1, 0.0)])!
    let c = NSPoint(x: size * 0.5, y: size * 0.80)
    glow.draw(fromCenter: c, radius: 0, toCenter: c, radius: size * 0.60, options: [])
    let bandRect = NSRect(x: 0, y: 0, width: size, height: size * 0.07)
    NSGradient(colors: [rgb(0, 0, 0, 0.15), rgb(0, 0, 0, 0.0)])!.draw(in: bandRect, angle: 90)
    NSGraphicsContext.restoreGraphicsState()
}

// 键帽：投影层 + 键帽本体（与原 iconset 几何一致）
func drawKeycap(_ size: CGFloat, _ pal: Palette) {
    let capW = size * 0.56, capH = capW
    let capX = (size - capW) / 2, capY = (size - capH) / 2
    let capRadius = capW * 0.18
    let capRect = NSRect(x: capX, y: capY, width: capW, height: capH)

    let drop = size * 0.025, grow = size * 0.008
    let shadowRect = NSRect(x: capX - grow, y: capY - drop - grow,
                            width: capW + grow * 2, height: capH + grow * 2)
    pal.capShadow.setFill()
    NSBezierPath(roundedRect: shadowRect, xRadius: capRadius, yRadius: capRadius).fill()

    let capPath = NSBezierPath(roundedRect: capRect, xRadius: capRadius, yRadius: capRadius)
    NSGradient(colors: pal.cap)!.draw(in: capPath, angle: -90)
}

// 波形：键帽内 5 根圆头柱
func drawWave(_ size: CGFloat, _ pal: Palette) {
    let capW = size * 0.56, capH = capW
    let capX = (size - capW) / 2, capY = (size - capH) / 2
    let waveAreaW = capW * 0.60, waveAreaH = capH * 0.52
    let heights: [CGFloat] = [0.35, 0.65, 1.0, 0.55, 0.30]
    let n = heights.count
    var barW = waveAreaW * 0.09
    if size < 64 { barW *= 1.3 }
    let startX = capX + capW / 2 - waveAreaW / 2
    let gap = (waveAreaW - barW * CGFloat(n)) / CGFloat(n - 1)
    let waveCY = capY + capH / 2

    let wavePath = NSBezierPath()
    for i in 0..<n {
        let bx = startX + CGFloat(i) * (barW + gap)
        let bh = waveAreaH * heights[i]
        let rect = NSRect(x: bx, y: waveCY - bh / 2, width: barW, height: bh)
        wavePath.append(NSBezierPath(roundedRect: rect, xRadius: barW / 2, yRadius: barW / 2))
    }
    NSGraphicsContext.saveGraphicsState()
    wavePath.addClip()
    NSGradient(colors: pal.wave)!.draw(in: wavePath.bounds, angle: -45)
    NSGraphicsContext.restoreGraphicsState()
}

// VibeHub 图标：靛蓝→电光紫的圆角方底 + 白色键帽 + 靛紫音频波形。
// 键帽 = 按键映射，波形 = 语音 / vibe coding。
func renderIconPNG(pxSize: Int) -> Data? {
    let cs = CGColorSpaceCreateDeviceRGB()
    guard let ctx = CGContext(
        data: nil,
        width: pxSize, height: pxSize,
        bitsPerComponent: 8, bytesPerRow: 0,
        space: cs,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else { return nil }

    let ns = NSGraphicsContext(cgContext: ctx, flipped: false)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = ns
    defer { NSGraphicsContext.restoreGraphicsState() }

    let size = CGFloat(pxSize)

    // ---- 1. 圆角方底（squircle 近似）----
    let margin = size * 0.10
    let bodyRect = NSRect(x: margin, y: margin, width: size - margin * 2, height: size - margin * 2)
    let radius = bodyRect.width * 0.2237
    let bgPath = NSBezierPath(roundedRect: bodyRect, xRadius: radius, yRadius: radius)

    // 对角线渐变：左上 #4F46E5 靛蓝 → 右下 #7C3AED 电光紫（angle -45 指向右下）
    let bgGrad = NSGradient(colors: [rgb(0.310, 0.275, 0.898),
                                     rgb(0.486, 0.227, 0.929)])!
    bgGrad.draw(in: bgPath, angle: -45)

    NSGraphicsContext.saveGraphicsState()
    bgPath.addClip()

    // 顶部中央微弱径向高光（光泽）
    let glow = NSGradient(colors: [rgb(1, 1, 1, 0.10), rgb(1, 1, 1, 0.0)])!
    let glowCenter = NSPoint(x: size * 0.5, y: size * 0.80)
    glow.draw(fromCenter: glowCenter, radius: 0,
              toCenter: glowCenter, radius: size * 0.60, options: [])

    // 底部内侧深色内阴影带（体积感）
    let bandRect = NSRect(x: bodyRect.minX, y: bodyRect.minY,
                          width: bodyRect.width, height: size * 0.07)
    let band = NSGradient(colors: [rgb(0, 0, 0, 0.15), rgb(0, 0, 0, 0.0)])!
    band.draw(in: bandRect, angle: 90)  // 底部暗，向上淡出

    NSGraphicsContext.restoreGraphicsState()

    // ---- 2. 白色键帽（先画投影层，再画键帽）----
    let capW = size * 0.56
    let capH = capW
    let capX = (size - capW) / 2
    let capY = (size - capH) / 2
    let capRadius = capW * 0.18
    let capRect = NSRect(x: capX, y: capY, width: capW, height: capH)

    // 投影 / 厚度层：稍大、下移 ~2.5%，深紫 35% alpha
    let drop = size * 0.025
    let grow = size * 0.008
    let shadowRect = NSRect(x: capX - grow, y: capY - drop - grow,
                            width: capW + grow * 2, height: capH + grow * 2)
    let shadowPath = NSBezierPath(roundedRect: shadowRect, xRadius: capRadius, yRadius: capRadius)
    rgb(0.231, 0.180, 0.549, 0.35).setFill()
    shadowPath.fill()

    // 键帽本体：#FAFAFA → #EDEDF2 轻微垂直渐变（上亮下暗）
    let capPath = NSBezierPath(roundedRect: capRect, xRadius: capRadius, yRadius: capRadius)
    let capGrad = NSGradient(colors: [rgb(0.980, 0.980, 0.980),
                                      rgb(0.929, 0.929, 0.949)])!
    capGrad.draw(in: capPath, angle: -90)  // 顶部 #FAFAFA → 底部 #EDEDF2

    // ---- 3. 键帽内音频波形：5 根圆头柱 ----
    let waveAreaW = capW * 0.60
    let waveAreaH = capH * 0.52
    let heights: [CGFloat] = [0.35, 0.65, 1.0, 0.55, 0.30]
    let n = heights.count
    var barW = waveAreaW * 0.09
    if size < 64 { barW *= 1.3 }  // 小尺寸加粗以保可读

    let startX = capX + capW / 2 - waveAreaW / 2
    let gap = (waveAreaW - barW * CGFloat(n)) / CGFloat(n - 1)
    let waveCY = capY + capH / 2

    let wavePath = NSBezierPath()
    for i in 0..<n {
        let bx = startX + CGFloat(i) * (barW + gap)
        let bh = waveAreaH * heights[i]
        let rect = NSRect(x: bx, y: waveCY - bh / 2, width: barW, height: bh)
        wavePath.append(NSBezierPath(roundedRect: rect, xRadius: barW / 2, yRadius: barW / 2))
    }

    NSGraphicsContext.saveGraphicsState()
    wavePath.addClip()
    let waveGrad = NSGradient(colors: [rgb(0.310, 0.275, 0.898),
                                       rgb(0.486, 0.227, 0.929)])!
    waveGrad.draw(in: wavePath.bounds, angle: -45)
    NSGraphicsContext.restoreGraphicsState()

    guard let cgImage = ctx.makeImage() else { return nil }
    let rep = NSBitmapImageRep(cgImage: cgImage)
    return rep.representation(using: .png, properties: [:])
}

// ---- --layers <outdir>：导出分层 PNG（含浅/深变体 + 合成预览），供 AppIcon.icon 用 ----
let cliArgs = CommandLine.arguments
if let li = cliArgs.firstIndex(of: "--layers") {
    let dir = li + 1 < cliArgs.count ? cliArgs[li + 1] : "AppIcon.icon/Assets"
    try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
    func write(_ data: Data?, _ name: String) {
        guard let data = data else { print("✗ \(name)"); return }
        try? data.write(to: URL(fileURLWithPath: dir).appendingPathComponent(name))
        print("✓ \(name)")
    }
    let px = 1024
    for (suffix, pal) in [("light", lightPal), ("dark", darkPal)] {
        write(withCanvas(px) { drawBackground($0, pal) }, "bg-\(suffix).png")
        write(withCanvas(px) { drawKeycap($0, pal) },     "cap-\(suffix).png")
        write(withCanvas(px) { drawWave($0, pal) },       "wave-\(suffix).png")
        // 合成预览仅供自查，不进 icon.json
        write(withCanvas(px) { s in drawBackground(s, pal); drawKeycap(s, pal); drawWave(s, pal) },
              "preview-\(suffix).png")
    }
    print("✅ layers → \(dir)")
    exit(0)
}

let outDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "AppIcon.iconset"
try? FileManager.default.createDirectory(atPath: outDir, withIntermediateDirectories: true)

let sizes: [(String, Int)] = [
    ("icon_16x16",       16),
    ("icon_16x16@2x",    32),
    ("icon_32x32",       32),
    ("icon_32x32@2x",    64),
    ("icon_128x128",    128),
    ("icon_128x128@2x", 256),
    ("icon_256x256",    256),
    ("icon_256x256@2x", 512),
    ("icon_512x512",    512),
    ("icon_512x512@2x",1024),
]

for (name, px) in sizes {
    if let data = renderIconPNG(pxSize: px) {
        let url = URL(fileURLWithPath: outDir).appendingPathComponent("\(name).png")
        try? data.write(to: url)
        print("✓ \(name).png  \(px)×\(px)")
    } else {
        print("✗ failed \(name) \(px)")
    }
}
