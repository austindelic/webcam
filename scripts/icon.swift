// Draws the 1024px app icon: a screen with the camera light on at the top
// and a little video window in the bottom-right corner. Flat colours only.
// Usage: swift scripts/icon.swift <output.png>

import AppKit

let canvas: CGFloat = 1024
// Apple's macOS icon grid: an 824pt rounded square centred on a 1024pt canvas.
let tile = CGRect(x: 100, y: 100, width: 824, height: 824)

func color(_ hex: UInt32) -> CGColor {
    CGColor(
        srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
        green: CGFloat((hex >> 8) & 0xFF) / 255,
        blue: CGFloat(hex & 0xFF) / 255,
        alpha: 1
    )
}

func fillRoundedRect(_ ctx: CGContext, _ rect: CGRect, radius: CGFloat, _ fill: CGColor) {
    ctx.addPath(CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil))
    ctx.setFillColor(fill)
    ctx.fillPath()
}

let ctx = CGContext(
    data: nil, width: Int(canvas), height: Int(canvas), bitsPerComponent: 8, bytesPerRow: 0,
    space: CGColorSpace(name: CGColorSpace.sRGB)!,
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
)!

// Screen.
fillRoundedRect(ctx, tile, radius: 185, color(0xEDEAE4))

// Camera light.
let light: CGFloat = 26
ctx.setFillColor(color(0x30C552))
ctx.fillEllipse(in: CGRect(
    x: canvas / 2 - light,
    y: tile.maxY - 96 - light,
    width: light * 2,
    height: light * 2
))

// The webcam window, 16:9, tucked into the corner like the app.
let window = CGSize(width: 448, height: 252)
let inset: CGFloat = 112
fillRoundedRect(
    ctx,
    CGRect(
        x: tile.maxX - inset - window.width,
        y: tile.minY + inset,
        width: window.width,
        height: window.height
    ),
    radius: 44,
    color(0x161616)
)

let output = URL(fileURLWithPath: CommandLine.arguments[1])
let png = NSBitmapImageRep(cgImage: ctx.makeImage()!).representation(using: .png, properties: [:])!
try png.write(to: output)
