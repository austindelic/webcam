// Draws the DMG window background at 1x and 2x.
// Icon positions here must match icon_locations in scripts/dmg.py.
// Usage: swift scripts/dmg-background.swift <output-dir>

import AppKit

/// The window as it opens. Everything is laid out in this box.
let size = CGSize(width: 640, height: 400)
/// Finder pins the background to the top-left and shows white past its edges, so the
/// image is big enough to fill the window at any size. Plain paper compresses to nearly nothing.
let canvas = CGSize(width: 3200, height: 2000)
let appIcon = CGPoint(x: 170, y: 210)
let applicationsIcon = CGPoint(x: 470, y: 210)

let ink = NSColor(srgbRed: 0x1E / 255, green: 0x1E / 255, blue: 0x1E / 255, alpha: 1)
let paper = NSColor(srgbRed: 0xED / 255, green: 0xEA / 255, blue: 0xE4 / 255, alpha: 1)
let muted = NSColor(srgbRed: 0x86 / 255, green: 0x82 / 255, blue: 0x7B / 255, alpha: 1)
let rule = NSColor(srgbRed: 0xC9 / 255, green: 0xC5 / 255, blue: 0xBE / 255, alpha: 1)
let light = NSColor(srgbRed: 0x30 / 255, green: 0xC5 / 255, blue: 0x52 / 255, alpha: 1)

func rounded(_ size: CGFloat, _ weight: NSFont.Weight) -> NSFont {
    let base = NSFont.systemFont(ofSize: size, weight: weight)
    guard let descriptor = base.fontDescriptor.withDesign(.rounded) else { return base }
    return NSFont(descriptor: descriptor, size: size) ?? base
}

/// Draws `text` centred on `centerX`, with its top edge `top` points from the top of the window.
func draw(_ text: String, font: NSFont, color: NSColor, centerX: CGFloat, top: CGFloat) {
    let string = NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: color])
    let bounds = string.size()
    string.draw(at: CGPoint(x: centerX - bounds.width / 2, y: size.height - top - bounds.height))
}

func render(scale: CGFloat) -> Data {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(canvas.width * scale),
        pixelsHigh: Int(canvas.height * scale),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
    rep.size = canvas

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

    paper.setFill()
    CGRect(origin: .zero, size: canvas).fill()

    // Lay out in the window-sized box at the top-left of the canvas.
    let toTopLeft = NSAffineTransform()
    toTopLeft.translateX(by: 0, yBy: canvas.height - size.height)
    toTopLeft.concat()

    // Wordmark, led by the camera light.
    let title = NSAttributedString(
        string: "Webcam",
        attributes: [.font: rounded(30, .bold), .foregroundColor: ink]
    )
    let titleSize = title.size()
    let dot: CGFloat = 12
    let gap: CGFloat = 10
    let titleX = (size.width - titleSize.width - dot - gap) / 2
    let titleY = size.height - 44 - titleSize.height
    light.setFill()
    NSBezierPath(ovalIn: CGRect(
        x: titleX,
        y: titleY + (titleSize.height - dot) / 2,
        width: dot,
        height: dot
    )).fill()
    title.draw(at: CGPoint(x: titleX + dot + gap, y: titleY))

    draw(
        "Your webcam in a little floating window.",
        font: rounded(14, .medium),
        color: muted,
        centerX: size.width / 2,
        top: 88
    )

    // Arrow from the app to Applications.
    let y = size.height - appIcon.y
    let start = appIcon.x + 84
    let end = applicationsIcon.x - 84
    let arrow = NSBezierPath()
    arrow.move(to: CGPoint(x: start, y: y))
    arrow.line(to: CGPoint(x: end, y: y))
    arrow.move(to: CGPoint(x: end - 12, y: y + 12))
    arrow.line(to: CGPoint(x: end, y: y))
    arrow.line(to: CGPoint(x: end - 12, y: y - 12))
    arrow.lineWidth = 3
    arrow.lineCapStyle = .round
    arrow.lineJoinStyle = .round
    ink.setStroke()
    arrow.stroke()

    // Footer. The bottom 40pt stay empty: Finder may draw its path bar over them.
    let ruleY = size.height - 304
    let footer = NSBezierPath()
    footer.move(to: CGPoint(x: 40, y: ruleY))
    footer.line(to: CGPoint(x: size.width - 40, y: ruleY))
    footer.lineWidth = 1
    rule.setStroke()
    footer.stroke()

    draw(
        "Drag Webcam into Applications.",
        font: rounded(13, .semibold),
        color: ink,
        centerX: size.width / 2,
        top: 318
    )
    draw(
        "Nothing is recorded. Nothing is saved.",
        font: rounded(12, .medium),
        color: muted,
        centerX: size.width / 2,
        top: 340
    )

    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}

let dir = URL(fileURLWithPath: CommandLine.arguments[1])
try render(scale: 1).write(to: dir.appendingPathComponent("background.png"))
try render(scale: 2).write(to: dir.appendingPathComponent("background@2x.png"))
