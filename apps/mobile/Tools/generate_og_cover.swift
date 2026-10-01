#!/usr/bin/env swift
// Lineer Destek Open Graph kapak görselini üretir (1200x630).
// macOS CoreGraphics kullanır; ek paket gerekmez.
// Kullanım: swift Tools/generate_og_cover.swift <logo.png> <çıktı.png>

import AppKit
import Foundation

let arguments = CommandLine.arguments
guard arguments.count >= 3 else {
    FileHandle.standardError.write("kullanım: generate_og_cover.swift <logo.png> <out.png>\n".data(using: .utf8)!)
    exit(1)
}

let logoPath = arguments[1]
let outputPath = arguments[2]
let width = 1200.0
let height = 630.0

let colorSpace = CGColorSpaceCreateDeviceRGB()
guard let context = CGContext(
    data: nil,
    width: Int(width),
    height: Int(height),
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: colorSpace,
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
) else {
    FileHandle.standardError.write("CGContext oluşturulamadı\n".data(using: .utf8)!)
    exit(1)
}

// Arka plan degrade
let colors = [
    CGColor(red: 0.047, green: 0.118, blue: 0.200, alpha: 1.0),
    CGColor(red: 0.310, green: 0.275, blue: 0.898, alpha: 1.0)
] as CFArray
if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0, 1]) {
    context.drawLinearGradient(
        gradient,
        start: CGPoint(x: 0, y: height),
        end: CGPoint(x: width, y: 0),
        options: []
    )
}

// Logo (ortalanmış, 190pt)
let logo = NSImage(contentsOfFile: logoPath)
if let logo {
    let side: CGFloat = 190
    let rect = CGRect(x: (width - side) / 2, y: 400, width: side, height: side)
    if let cgImage = logo.cgImage(forProposedRect: nil, context: nil, hints: nil) {
        // Beyaz zemin üzerinde logo koyu zeminde okunur olsun diye
        // logo çevresine hafif yuvarlak beyaz kart basılır.
        let cardRect = CGRect(x: rect.minX - 28, y: rect.minY - 28, width: rect.width + 56, height: rect.height + 56)
        context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.96))
        context.addPath(CGPath(roundedRect: cardRect, cornerWidth: 44, cornerHeight: 44, transform: nil))
        context.fillPath()
        context.draw(cgImage, in: rect)
    }
}

// Metinler
func drawText(_ text: String, size: CGFloat, weight: NSFont.Weight, y: CGFloat, color: NSColor, spacing: CGFloat = 0) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    if spacing != 0 {
        paragraph.lineSpacing = spacing
    }
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: size, weight: weight),
        .foregroundColor: color,
        .paragraphStyle: paragraph
    ]
    let attributed = NSAttributedString(string: text, attributes: attributes)
    let bounds = attributed.size()
    attributed.draw(
        in: CGRect(
            x: (width - bounds.width) / 2,
            y: y,
            width: bounds.width,
            height: bounds.height
        )
    )
}

drawText("LINEER DESTEK", size: 22, weight: .bold, y: 330, color: NSColor(red: 0.85, green: 0.85, blue: 1.0, alpha: 1))
drawText("Teknik Servisinizi", size: 58, weight: .heavy, y: 240, color: .white)
drawText("Hızla Yönetin", size: 58, weight: .heavy, y: 170, color: .white)
drawText(
    "İş emri · Müşteri · Cihaz · Stok · Muhasebe · Yapay zeka destekli saha operasyonu",
    size: 22,
    weight: .medium,
    y: 108,
    color: NSColor(white: 1, alpha: 0.86)
)
drawText("www.lineerdestek.com", size: 20, weight: .semibold, y: 52, color: NSColor(red: 1, green: 1, blue: 1, alpha: 0.72))

guard let image = context.makeImage() else {
    FileHandle.standardError.write("Görsel oluşturulamadı\n".data(using: .utf8)!)
    exit(1)
}

let rep = NSBitmapImageRep(cgImage: image)
guard let data = rep.representation(using: .png, properties: [:]) else {
    FileHandle.standardError.write("PNG kodlanamadı\n".data(using: .utf8)!)
    exit(1)
}

try data.write(to: URL(fileURLWithPath: outputPath))
print("yazıldı: \(outputPath)")