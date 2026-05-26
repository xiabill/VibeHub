import Cocoa

// 在 ctx 上画一个 command SF Symbol（白色），居中、占画布约 56%。
// command 是 VibeHub 的中性 hub 标志 —— AirPods/Remote 都不偏向。
func drawHubSymbol(size: CGFloat) {
    let config = NSImage.SymbolConfiguration(pointSize: size * 0.56, weight: .regular)
    guard let img = NSImage(systemSymbolName: "command", accessibilityDescription: nil)?
            .withSymbolConfiguration(config) else { return }

    let tinted = NSImage(size: img.size, flipped: false) { rect in
        img.draw(in: rect)
        NSColor.white.set()
        rect.fill(using: .sourceIn)
        return true
    }

    let drawSize = tinted.size
    let drawRect = NSRect(
        x: (size - drawSize.width) / 2,
        y: (size - drawSize.height) / 2,
        width: drawSize.width, height: drawSize.height)
    tinted.draw(in: drawRect)
}

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

    let radius = size * 0.2237
    let inset  = size * 0.04
    let bgRect = NSRect(x: inset, y: inset, width: size - inset * 2, height: size - inset * 2)
    let bgPath = NSBezierPath(roundedRect: bgRect, xRadius: radius, yRadius: radius)

    // VibeHub 用青蓝渐变 —— 跟 AirPodsRemap（蓝）/ RemoteRemap（紫红）区分
    let gradient = NSGradient(colors: [
        NSColor(red: 0.30, green: 0.78, blue: 0.95, alpha: 1.0),  // 顶部天青
        NSColor(red: 0.08, green: 0.30, blue: 0.70, alpha: 1.0),  // 底部深蓝
    ])!
    gradient.draw(in: bgPath, angle: -90)

    NSGraphicsContext.saveGraphicsState()
    bgPath.addClip()
    let hlRect = NSRect(x: inset, y: size * 0.58, width: size - inset * 2, height: size * 0.42)
    let hl = NSGradient(colors: [
        NSColor(white: 1.0, alpha: 0.20),
        NSColor(white: 1.0, alpha: 0.0)
    ])!
    hl.draw(in: hlRect, angle: -90)
    NSGraphicsContext.restoreGraphicsState()

    NSGraphicsContext.saveGraphicsState()
    bgPath.addClip()
    drawHubSymbol(size: size)
    NSGraphicsContext.restoreGraphicsState()

    let borderPath = NSBezierPath(
        roundedRect: bgRect.insetBy(dx: 0.5, dy: 0.5),
        xRadius: radius, yRadius: radius)
    NSColor(white: 0, alpha: 0.10).setStroke()
    borderPath.lineWidth = max(1, size / 1024)
    borderPath.stroke()

    guard let cgImage = ctx.makeImage() else { return nil }
    let rep = NSBitmapImageRep(cgImage: cgImage)
    return rep.representation(using: .png, properties: [:])
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
