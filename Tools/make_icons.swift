// Renders the Space Explorer app icon layers and Top Shelf images.
// Usage: swift make_icons.swift <path to "App Icon & Top Shelf Image.brandassets">

import AppKit
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

let brand = CommandLine.arguments[1]
let sRGB = CGColorSpace(name: CGColorSpace.sRGB)!

func rgba(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> CGColor {
    CGColor(colorSpace: sRGB, components: [r, g, b, a])!
}

func gradient(_ colors: [CGColor], _ locations: [CGFloat]) -> CGGradient {
    CGGradient(colorsSpace: sRGB, colors: colors as CFArray, locations: locations)!
}

struct Rng {
    var state: UInt64
    mutating func next() -> Double {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return Double((z ^ (z >> 31)) >> 11) / Double(1 << 53)
    }
}

// MARK: - Background

func drawSpace(_ ctx: CGContext, w: CGFloat, h: CGFloat) {
    ctx.drawLinearGradient(
        gradient([rgba(0.07, 0.06, 0.24), rgba(0.03, 0.05, 0.16), rgba(0.01, 0.02, 0.07)], [0, 0.5, 1]),
        start: CGPoint(x: 0, y: h), end: CGPoint(x: w, y: 0), options: [])
    // Nebula glows
    ctx.drawRadialGradient(gradient([rgba(0.62, 0.45, 1, 0.45), rgba(0.62, 0.45, 1, 0)], [0, 1]),
                           startCenter: CGPoint(x: w * 0.82, y: h * 0.85), startRadius: 0,
                           endCenter: CGPoint(x: w * 0.82, y: h * 0.85), endRadius: h * 0.9, options: [])
    ctx.drawRadialGradient(gradient([rgba(0.36, 0.64, 1, 0.3), rgba(0.36, 0.64, 1, 0)], [0, 1]),
                           startCenter: CGPoint(x: w * 0.12, y: h * 0.1), startRadius: 0,
                           endCenter: CGPoint(x: w * 0.12, y: h * 0.1), endRadius: h * 0.8, options: [])
    // Stars, placed in unit coordinates so every scale looks the same
    var rng = Rng(state: 42)
    let count = Int(70 * (w / h))
    for _ in 0..<count {
        let x = rng.next() * w, y = rng.next() * h
        let depth = rng.next()
        let r = h * (0.002 + depth * 0.005)
        ctx.setFillColor(rgba(1, 1, 1, 0.3 + depth * 0.7))
        ctx.fillEllipse(in: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2))
    }
}

// MARK: - Logo (ringed planet)

enum Part { case back, front, all }

let ringTilt: CGFloat = 0.36  // radians, rising to the right

func ringPath(r: CGFloat) -> CGPath {
    let path = CGMutablePath()
    path.addEllipse(in: CGRect(x: -2.05 * r, y: -0.54 * r, width: 4.1 * r, height: 1.08 * r))
    path.addEllipse(in: CGRect(x: -1.36 * r, y: -0.33 * r, width: 2.72 * r, height: 0.66 * r))
    return path
}

/// Draws one half of the ring. In y-up coordinates the far half is the upper half.
func drawRing(_ ctx: CGContext, center: CGPoint, r: CGFloat, far: Bool) {
    ctx.saveGState()
    ctx.translateBy(x: center.x, y: center.y)
    ctx.rotate(by: ringTilt)
    ctx.clip(to: far ? CGRect(x: -3 * r, y: -0.03 * r, width: 6 * r, height: 3.03 * r)
                     : CGRect(x: -3 * r, y: -3 * r, width: 6 * r, height: 3 * r))
    ctx.addPath(ringPath(r: r))
    ctx.clip(using: .evenOdd)
    ctx.drawLinearGradient(
        gradient([rgba(0.5, 0.85, 1), rgba(0.95, 0.97, 1), rgba(0.8, 0.66, 1), rgba(0.55, 0.42, 0.98)], [0, 0.35, 0.7, 1]),
        start: CGPoint(x: -2.1 * r, y: 0), end: CGPoint(x: 2.1 * r, y: 0), options: [])
    // Gaps between ring bands
    ctx.setStrokeColor(rgba(0.08, 0.06, 0.25, 0.55))
    ctx.setLineWidth(0.05 * r)
    ctx.strokeEllipse(in: CGRect(x: -1.75 * r, y: -0.455 * r, width: 3.5 * r, height: 0.91 * r))
    ctx.setLineWidth(0.02 * r)
    ctx.strokeEllipse(in: CGRect(x: -1.55 * r, y: -0.4 * r, width: 3.1 * r, height: 0.8 * r))
    ctx.restoreGState()
}

func drawSphere(_ ctx: CGContext, center: CGPoint, r: CGFloat) {
    let disc = CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)
    // Atmosphere glow
    ctx.drawRadialGradient(gradient([rgba(0.62, 0.45, 1, 0.55), rgba(0.36, 0.64, 1, 0)], [0, 1]),
                           startCenter: center, startRadius: r * 0.9, endCenter: center, endRadius: r * 1.7, options: [])
    ctx.saveGState()
    ctx.addEllipse(in: disc)
    ctx.clip()
    ctx.drawLinearGradient(
        gradient([rgba(0.5, 0.82, 1), rgba(0.45, 0.45, 0.98), rgba(0.3, 0.16, 0.6)], [0, 0.55, 1]),
        start: CGPoint(x: disc.minX, y: disc.maxY), end: CGPoint(x: disc.maxX, y: disc.minY), options: [])
    // Cloud bands, tilted with the ring
    ctx.saveGState()
    ctx.translateBy(x: center.x, y: center.y)
    ctx.rotate(by: ringTilt)
    for (offset, height, alpha) in [(0.5, 0.16, 0.16), (0.12, 0.22, 0.12), (-0.32, 0.14, 0.18), (-0.62, 0.1, 0.12)] as [(CGFloat, CGFloat, CGFloat)] {
        ctx.setFillColor(rgba(1, 1, 1, alpha))
        ctx.fillEllipse(in: CGRect(x: -1.3 * r, y: (offset - height / 2) * r, width: 2.6 * r, height: height * r))
    }
    ctx.restoreGState()
    // Lighting from the upper left
    let light = CGPoint(x: center.x - r * 0.42, y: center.y + r * 0.42)
    ctx.drawRadialGradient(
        gradient([rgba(1, 1, 1, 0.5), rgba(1, 1, 1, 0), rgba(0, 0, 0.1, 0.35), rgba(0, 0, 0.08, 0.75)], [0, 0.32, 0.72, 1]),
        startCenter: light, startRadius: 0, endCenter: light, endRadius: r * 1.95, options: [])
    ctx.restoreGState()
}

func drawSparkle(_ ctx: CGContext, at p: CGPoint, size s: CGFloat, alpha: CGFloat = 1) {
    ctx.drawRadialGradient(gradient([rgba(1, 1, 1, 0.5 * alpha), rgba(0.75, 0.7, 1, 0)], [0, 1]),
                           startCenter: p, startRadius: 0, endCenter: p, endRadius: s * 0.9, options: [])
    let path = CGMutablePath()
    let pinch = s * 0.12
    path.move(to: CGPoint(x: p.x, y: p.y + s))
    path.addQuadCurve(to: CGPoint(x: p.x + s, y: p.y), control: CGPoint(x: p.x + pinch, y: p.y + pinch))
    path.addQuadCurve(to: CGPoint(x: p.x, y: p.y - s), control: CGPoint(x: p.x + pinch, y: p.y - pinch))
    path.addQuadCurve(to: CGPoint(x: p.x - s, y: p.y), control: CGPoint(x: p.x - pinch, y: p.y - pinch))
    path.addQuadCurve(to: CGPoint(x: p.x, y: p.y + s), control: CGPoint(x: p.x - pinch, y: p.y + pinch))
    ctx.setFillColor(rgba(1, 1, 1, alpha))
    ctx.addPath(path)
    ctx.fillPath()
}

func drawMoon(_ ctx: CGContext, at p: CGPoint, r: CGFloat) {
    ctx.saveGState()
    ctx.addEllipse(in: CGRect(x: p.x - r, y: p.y - r, width: r * 2, height: r * 2))
    ctx.clip()
    let light = CGPoint(x: p.x - r * 0.4, y: p.y + r * 0.4)
    ctx.drawRadialGradient(gradient([rgba(1, 1, 1), rgba(0.7, 0.72, 0.82), rgba(0.25, 0.25, 0.38)], [0, 0.5, 1]),
                           startCenter: light, startRadius: 0, endCenter: light, endRadius: r * 1.8, options: [])
    ctx.restoreGState()
}

func drawLogo(_ ctx: CGContext, center c: CGPoint, r: CGFloat, part: Part) {
    if part != .front {
        drawRing(ctx, center: c, r: r, far: true)
        drawSphere(ctx, center: c, r: r)
    }
    if part != .back {
        drawRing(ctx, center: c, r: r, far: false)
        drawMoon(ctx, at: CGPoint(x: c.x + 1.85 * r, y: c.y + 1.05 * r), r: 0.17 * r)
        drawSparkle(ctx, at: CGPoint(x: c.x - 2.05 * r, y: c.y + 1.05 * r), size: 0.26 * r)
        drawSparkle(ctx, at: CGPoint(x: c.x + 2.3 * r, y: c.y - 0.95 * r), size: 0.15 * r, alpha: 0.85)
        drawSparkle(ctx, at: CGPoint(x: c.x - 1.6 * r, y: c.y - 1.1 * r), size: 0.1 * r, alpha: 0.7)
    }
}

// MARK: - Title text (Top Shelf)

func roundedFont(_ size: CGFloat, _ weight: NSFont.Weight) -> NSFont {
    let base = NSFont.systemFont(ofSize: size, weight: weight)
    return NSFont(descriptor: base.fontDescriptor.withDesign(.rounded) ?? base.fontDescriptor, size: size) ?? base
}

func drawText(_ ctx: CGContext, _ text: String, at p: CGPoint, font: NSFont, kern: CGFloat,
              fill: (CGContext, CGRect) -> Void, glow: CGColor? = nil) {
    let line = CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: [.font: font, .kern: kern]))
    ctx.textMatrix = .identity
    ctx.textPosition = .zero
    let bounds = CTLineGetImageBounds(line, ctx).offsetBy(dx: p.x, dy: p.y)
    if let glow {
        ctx.saveGState()
        ctx.setShadow(offset: .zero, blur: font.pointSize * 0.35, color: glow)
        ctx.setFillColor(rgba(1, 1, 1))
        ctx.textPosition = p
        CTLineDraw(line, ctx)
        ctx.restoreGState()
    }
    ctx.saveGState()
    ctx.setTextDrawingMode(.clip)
    ctx.textPosition = p
    CTLineDraw(line, ctx)
    fill(ctx, bounds)
    ctx.restoreGState()
}

// MARK: - Output

func render(width: Int, height: Int, opaque: Bool, draw: (CGContext, CGFloat, CGFloat) -> Void) -> CGImage {
    let ctx = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: sRGB,
                        bitmapInfo: opaque ? CGImageAlphaInfo.noneSkipLast.rawValue : CGImageAlphaInfo.premultipliedLast.rawValue)!
    ctx.setAllowsAntialiasing(true)
    ctx.interpolationQuality = .high
    draw(ctx, CGFloat(width), CGFloat(height))
    return ctx.makeImage()!
}

func save(_ image: CGImage, to path: String) {
    let url = URL(fileURLWithPath: path)
    let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(dest, image, nil)
    precondition(CGImageDestinationFinalize(dest), "Failed to write \(path)")
    print("wrote \(path) (\(image.width)x\(image.height))")
}

func writeContents(_ dir: String, images: [(file: String, scale: String?)]) {
    let entries = images.map { image -> String in
        let scale = image.scale.map { ",\n      \"scale\" : \"\($0)\"" } ?? ""
        return "    {\n      \"filename\" : \"\(image.file)\",\n      \"idiom\" : \"tv\"\(scale)\n    }"
    }
    let json = "{\n  \"images\" : [\n\(entries.joined(separator: ",\n"))\n  ],\n  \"info\" : {\n    \"author\" : \"xcode\",\n    \"version\" : 1\n  }\n}\n"
    try! json.write(toFile: dir + "/Contents.json", atomically: true, encoding: .utf8)
}

/// Icon logo geometry: centred, sized so the rings and sparkles stay inside the focus-crop safe area.
func iconLayer(_ name: String, _ ctx: CGContext, _ w: CGFloat, _ h: CGFloat) {
    let center = CGPoint(x: w / 2, y: h * 0.5)
    let r = h * 0.21
    switch name {
    case "Back": drawSpace(ctx, w: w, h: h)
    case "Middle": drawLogo(ctx, center: center, r: r, part: .back)
    default: drawLogo(ctx, center: center, r: r, part: .front)
    }
}

let layers = ["Back", "Middle", "Front"]

// App Icon (400x240 @1x and @2x)
for layer in layers {
    let dir = "\(brand)/App Icon.imagestack/\(layer).imagestacklayer/Content.imageset"
    let base = layer.lowercased()
    for (scale, suffix) in [(1, ""), (2, "@2x")] {
        save(render(width: 400 * scale, height: 240 * scale, opaque: layer == "Back") { iconLayer(layer, $0, $1, $2) },
             to: "\(dir)/\(base)\(suffix).png")
    }
    writeContents(dir, images: [("\(base).png", "1x"), ("\(base)@2x.png", "2x")])
}

// App Store icon (1280x768)
for layer in layers {
    let dir = "\(brand)/App Icon - App Store.imagestack/\(layer).imagestacklayer/Content.imageset"
    let base = layer.lowercased()
    save(render(width: 1280, height: 768, opaque: layer == "Back") { iconLayer(layer, $0, $1, $2) },
         to: "\(dir)/\(base).png")
    writeContents(dir, images: [("\(base).png", nil)])
}

// Top Shelf images: logo on the left, title on the right
func topShelf(_ ctx: CGContext, _ w: CGFloat, _ h: CGFloat) {
    drawSpace(ctx, w: w, h: h)
    let titleFont = roundedFont(h * 0.15, .heavy)
    let titleLine = CTLineCreateWithAttributedString(
        NSAttributedString(string: "SPACE EXPLORER", attributes: [.font: titleFont, .kern: h * 0.004]))
    let titleWidth = CGFloat(CTLineGetTypographicBounds(titleLine, nil, nil, nil))
    let logoWidth = h * 0.95, gap = h * 0.12
    let start = (w - (logoWidth + gap + titleWidth)) / 2
    drawLogo(ctx, center: CGPoint(x: start + logoWidth / 2, y: h * 0.5), r: h * 0.2, part: .all)
    let textX = start + logoWidth + gap
    drawText(ctx, "SPACE EXPLORER", at: CGPoint(x: textX, y: h * 0.47),
             font: titleFont, kern: h * 0.004,
             fill: { ctx, rect in
                 ctx.drawLinearGradient(
                     gradient([rgba(1, 1, 1), rgba(0.78, 0.84, 1), rgba(0.66, 0.5, 1)], [0, 0.5, 1]),
                     start: CGPoint(x: rect.minX, y: rect.maxY), end: CGPoint(x: rect.maxX, y: rect.minY), options: [])
             },
             glow: rgba(0.62, 0.45, 1, 0.7))
    drawText(ctx, "Explore the solar system on the big screen", at: CGPoint(x: textX + h * 0.005, y: h * 0.33),
             font: roundedFont(h * 0.055, .semibold), kern: h * 0.001,
             fill: { ctx, rect in
                 ctx.setFillColor(rgba(1, 1, 1, 0.75))
                 ctx.fill(rect.insetBy(dx: -rect.height, dy: -rect.height))
             })
}

for (name, width) in [("Top Shelf Image", 1920), ("Top Shelf Image Wide", 2320)] {
    let dir = "\(brand)/\(name).imageset"
    let base = name == "Top Shelf Image" ? "top-shelf" : "top-shelf-wide"
    for (scale, suffix) in [(1, ""), (2, "@2x")] {
        save(render(width: width * scale, height: 720 * scale, opaque: true) { topShelf($0, $1, $2) },
             to: "\(dir)/\(base)\(suffix).png")
    }
    writeContents(dir, images: [("\(base).png", "1x"), ("\(base)@2x.png", "2x")])
}
