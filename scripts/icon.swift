// Draws the 1024px app icon: you, on camera, with the camera light on.
// Flat colours only.
// Usage: swift scripts/icon.swift <output.png>

import AppKit

let canvas: CGFloat = 1024
// Apple's macOS icon grid: an 824pt rounded square centred on a 1024pt canvas.
let tile = CGRect(x: 100, y: 100, width: 824, height: 824)
let tileRadius: CGFloat = 185

let ink = color(0x1E1E1E)
let paper = color(0xEDEAE4)
let light = color(0x30C552)

func color(_ hex: UInt32) -> CGColor {
    CGColor(
        srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
        green: CGFloat((hex >> 8) & 0xFF) / 255,
        blue: CGFloat(hex & 0xFF) / 255,
        alpha: 1
    )
}

func circle(_ center: CGPoint, _ radius: CGFloat) -> CGRect {
    CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
}

let ctx = CGContext(
    data: nil, width: Int(canvas), height: Int(canvas), bitsPerComponent: 8, bytesPerRow: 0,
    space: CGColorSpace(name: CGColorSpace.sRGB)!,
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
)!

let tilePath = CGPath(roundedRect: tile, cornerWidth: tileRadius, cornerHeight: tileRadius, transform: nil)

// The video.
ctx.addPath(tilePath)
ctx.setFillColor(ink)
ctx.fillPath()

// You: head and shoulders, cut off by the bottom of the frame.
ctx.saveGState()
ctx.addPath(tilePath)
ctx.clip()
ctx.setFillColor(paper)
ctx.fillEllipse(in: CGRect(x: 512 - 260, y: tile.minY - 200, width: 520, height: 420))
ctx.fillEllipse(in: circle(CGPoint(x: 512, y: tile.minY + 340), 120))
ctx.restoreGState()

// Camera light.
ctx.setFillColor(light)
ctx.fillEllipse(in: circle(CGPoint(x: 512, y: tile.maxY - 84), 24))

let output = URL(fileURLWithPath: CommandLine.arguments[1])
let png = NSBitmapImageRep(cgImage: ctx.makeImage()!).representation(using: .png, properties: [:])!
try png.write(to: output)
