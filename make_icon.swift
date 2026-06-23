import AppKit

let size: CGFloat = 1024

func tinted(_ img: NSImage, _ color: NSColor) -> NSImage {
    let out = NSImage(size: img.size)
    out.lockFocus()
    color.set()
    let r = NSRect(origin: .zero, size: img.size)
    img.draw(in: r)
    r.fill(using: .sourceAtop)
    out.unlockFocus()
    return out
}

let canvas = NSImage(size: NSSize(width: size, height: size))
canvas.lockFocus()

// Coffee-brown rounded-square background (macOS squircle corner ≈ 22.37%)
let bgRect = NSRect(x: 0, y: 0, width: size, height: size)
let corner = size * 0.2237
let bg = NSBezierPath(roundedRect: bgRect, xRadius: corner, yRadius: corner)
NSColor(calibratedRed: 0.435, green: 0.306, blue: 0.216, alpha: 1).setFill() // #6F4E37
bg.fill()

// Cup symbol, white, centered
let cfg = NSImage.SymbolConfiguration(pointSize: 540, weight: .regular)
if let base = NSImage(systemSymbolName: "cup.and.saucer.fill", accessibilityDescription: nil)?
    .withSymbolConfiguration(cfg) {
    let white = tinted(base, .white)
    let w = base.size.width, h = base.size.height
    white.draw(in: NSRect(x: (size - w) / 2, y: (size - h) / 2, width: w, height: h))
}

canvas.unlockFocus()

guard let tiff = canvas.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff),
      let png = rep.representation(using: .png, properties: [:]) else {
    FileHandle.standardError.write("failed to render\n".data(using: .utf8)!)
    exit(1)
}
try! png.write(to: URL(fileURLWithPath: "icon_1024.png"))
print("wrote icon_1024.png")
