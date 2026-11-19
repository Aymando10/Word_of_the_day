// Renders the Word of the Day app icon at 1024x1024.
// Usage: swift tool/render_icon.swift <output-dir>
// Then copy the PNGs into ios/Runner/Assets.xcassets/AppIcon.appiconset.
import AppKit
import CoreGraphics
import CoreText

let size: CGFloat = 1024
let outDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "."

func color(_ hex: UInt32, _ alpha: CGFloat = 1) -> CGColor {
    CGColor(
        srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
        green: CGFloat((hex >> 8) & 0xFF) / 255,
        blue: CGFloat(hex & 0xFF) / 255,
        alpha: alpha
    )
}

enum Variant { case standard, dark, tinted }

/// Four-point star centred at `c` with outer radius `r`.
func starPath(center c: CGPoint, radius r: CGFloat) -> CGPath {
    let path = CGMutablePath()
    let inner = r * 0.22
    for i in 0..<8 {
        let angle = CGFloat(i) * .pi / 4 + .pi / 2
        let radius = i.isMultiple(of: 2) ? r : inner
        let p = CGPoint(x: c.x + cos(angle) * radius, y: c.y + sin(angle) * radius)
        i == 0 ? path.move(to: p) : path.addLine(to: p)
    }
    path.closeSubpath()
    return path
}

func render(_ variant: Variant, to file: String) {
    let space = CGColorSpace(name: CGColorSpace.sRGB)!
    let ctx = CGContext(
        data: nil, width: Int(size), height: Int(size), bitsPerComponent: 8, bytesPerRow: 0,
        space: space, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
    )!
    let full = CGRect(x: 0, y: 0, width: size, height: size)

    // Palette per variant (tinted is grayscale; iOS applies the tint).
    let (glyph, accent): (CGColor, CGColor)
    switch variant {
    case .standard, .dark: (glyph, accent) = (color(0xF1EADB), color(0xD8BE85))
    case .tinted: (glyph, accent) = (color(0xFFFFFF), color(0xBDBDBD))
    }

    // Background.
    switch variant {
    case .standard:
        let g = CGGradient(colorsSpace: space, colors: [color(0x2A5443), color(0x12291F), color(0x07130E)] as CFArray, locations: [0, 0.55, 1])!
        ctx.setFillColor(color(0x07130E)); ctx.fill(full)
        ctx.drawRadialGradient(g, startCenter: CGPoint(x: size * 0.32, y: size * 0.80), startRadius: 0,
                               endCenter: CGPoint(x: size * 0.5, y: size * 0.5), endRadius: size * 0.85,
                               options: [.drawsAfterEndLocation])
    case .dark:
        let g = CGGradient(colorsSpace: space, colors: [color(0x1A3A2E), color(0x0A1913), color(0x030806)] as CFArray, locations: [0, 0.55, 1])!
        ctx.setFillColor(color(0x030806)); ctx.fill(full)
        ctx.drawRadialGradient(g, startCenter: CGPoint(x: size * 0.32, y: size * 0.80), startRadius: 0,
                               endCenter: CGPoint(x: size * 0.5, y: size * 0.5), endRadius: size * 0.85,
                               options: [.drawsAfterEndLocation])
    case .tinted:
        ctx.setFillColor(color(0x000000)); ctx.fill(full)
    }

    // Soft glow behind the glyph.
    if variant != .tinted {
        let glow = CGGradient(colorsSpace: space, colors: [color(0xD8BE85, 0.16), color(0xD8BE85, 0)] as CFArray, locations: [0, 1])!
        ctx.drawRadialGradient(glow, startCenter: CGPoint(x: size * 0.5, y: size * 0.56), startRadius: 0,
                               endCenter: CGPoint(x: size * 0.5, y: size * 0.56), endRadius: size * 0.42, options: [])
    }

    // Serif "W" (Georgia, matching the app's typography), optically centred.
    let font = CTFontCreateWithName("Georgia" as CFString, 600, nil)
    let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: glyph]
    let line = CTLineCreateWithAttributedString(NSAttributedString(string: "W", attributes: attrs))
    let bounds = CTLineGetBoundsWithOptions(line, .useGlyphPathBounds)
    let glyphCenterY = size * 0.555
    ctx.textPosition = CGPoint(x: (size - bounds.width) / 2 - bounds.minX,
                               y: glyphCenterY - bounds.height / 2 - bounds.minY)
    CTLineDraw(line, ctx)

    // Gold rule beneath the word, as on the app's word card.
    let ruleWidth: CGFloat = 168, ruleHeight: CGFloat = 16
    let ruleY = glyphCenterY - bounds.height / 2 - 92
    ctx.setFillColor(accent)
    ctx.addPath(CGPath(roundedRect: CGRect(x: (size - ruleWidth) / 2, y: ruleY, width: ruleWidth, height: ruleHeight),
                       cornerWidth: ruleHeight / 2, cornerHeight: ruleHeight / 2, transform: nil))
    ctx.fillPath()

    // Sparkle at the top right of the W: today's new word.
    let starCenter = CGPoint(x: size * 0.5 + bounds.width / 2 + 38, y: glyphCenterY + bounds.height / 2 + 66)
    if variant != .tinted {
        let sparkleGlow = CGGradient(colorsSpace: space, colors: [color(0xD8BE85, 0.45), color(0xD8BE85, 0)] as CFArray, locations: [0, 1])!
        ctx.drawRadialGradient(sparkleGlow, startCenter: starCenter, startRadius: 0, endCenter: starCenter, endRadius: 110, options: [])
    }
    ctx.setFillColor(accent)
    ctx.addPath(starPath(center: starCenter, radius: 62)); ctx.fillPath()
    ctx.addPath(starPath(center: CGPoint(x: starCenter.x + 58, y: starCenter.y - 74), radius: 24)); ctx.fillPath()

    let image = ctx.makeImage()!
    let rep = NSBitmapImageRep(cgImage: image)
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "\(outDir)/\(file)"))
}

render(.standard, to: "AppIcon.png")
render(.dark, to: "AppIcon-Dark.png")
render(.tinted, to: "AppIcon-Tinted.png")
print("Rendered icons to \(outDir)")
