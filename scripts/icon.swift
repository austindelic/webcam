// Draws the 1024px app icon: a dark rounded square with one camera lens
// and a green "camera on" light.
// Usage: swift scripts/icon.swift <output.png>

import AppKit

let canvas: CGFloat = 1024
// Apple's macOS icon grid: an 824pt rounded square centred on a 1024pt canvas.
let tile = CGRect(x: 100, y: 100, width: 824, height: 824)

func color(_ hex: UInt32, _ alpha: CGFloat = 1) -> CGColor {
    CGColor(
        srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
        green: CGFloat((hex >> 8) & 0xFF) / 255,
        blue: CGFloat(hex & 0xFF) / 255,
        alpha: alpha
    )
}

func circle(center: CGPoint, radius: CGFloat) -> CGRect {
    CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
}

func fillGradient(_ ctx: CGContext, _ colors: [CGColor], from start: CGPoint, to end: CGPoint) {
    let gradient = CGGradient(colorsSpace: nil, colors: colors as CFArray, locations: nil)!
    ctx.drawLinearGradient(gradient, start: start, end: end, options: [])
}

let ctx = CGContext(
    data: nil, width: Int(canvas), height: Int(canvas), bitsPerComponent: 8, bytesPerRow: 0,
    space: CGColorSpace(name: CGColorSpace.sRGB)!,
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
)!

// Tile with a soft drop shadow.
let tilePath = CGPath(roundedRect: tile, cornerWidth: 185, cornerHeight: 185, transform: nil)
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -12), blur: 28, color: color(0x000000, 0.35))
ctx.addPath(tilePath)
ctx.setFillColor(color(0x1C1C1E))
ctx.fillPath()
ctx.restoreGState()

ctx.saveGState()
ctx.addPath(tilePath)
ctx.clip()
fillGradient(
    ctx,
    [color(0x3A3A3C), color(0x111113)],
    from: CGPoint(x: 0, y: tile.maxY),
    to: CGPoint(x: 0, y: tile.minY)
)
ctx.restoreGState()

// Lens: a light ring around a deep glass centre.
let lensCenter = CGPoint(x: canvas / 2, y: canvas / 2 - 20)

ctx.setFillColor(color(0xF2F2F7))
ctx.fillEllipse(in: circle(center: lensCenter, radius: 250))

ctx.saveGState()
ctx.addEllipse(in: circle(center: lensCenter, radius: 196))
ctx.clip()
fillGradient(
    ctx, [color(0x2C3E66), color(0x05070D)],
    from: CGPoint(x: lensCenter.x - 140, y: lensCenter.y + 140),
    to: CGPoint(x: lensCenter.x + 140, y: lensCenter.y - 140)
)
ctx.restoreGState()

ctx.setFillColor(color(0x000000))
ctx.fillEllipse(in: circle(center: lensCenter, radius: 92))

// Glint.
ctx.setFillColor(color(0xFFFFFF, 0.85))
ctx.fillEllipse(in: circle(center: CGPoint(x: lensCenter.x - 74, y: lensCenter.y + 74), radius: 34))

// Camera-on light.
ctx.saveGState()
ctx.setShadow(offset: .zero, blur: 30, color: color(0x34C759, 0.9))
ctx.setFillColor(color(0x34C759))
ctx.fillEllipse(in: circle(center: CGPoint(x: canvas / 2, y: tile.maxY - 78), radius: 26))
ctx.restoreGState()

let output = URL(fileURLWithPath: CommandLine.arguments[1])
let png = NSBitmapImageRep(cgImage: ctx.makeImage()!).representation(using: .png, properties: [:])!
try png.write(to: output)
