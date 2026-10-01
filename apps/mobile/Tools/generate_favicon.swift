#!/usr/bin/env swift
// Logo.png dosyasından çok boyutlu favicon.ico üretir (16/32/48).
// macOS CoreGraphics kullanır; ek paket gerekmez.
//
// Çıktı düzeni (ICO spec):
//   ICONDIR (6 bayt) + ICONDIRENTRY (16 bayt x adet) + tüm görsel verileri
//
// Kullanım: swift Tools/generate_favicon.swift <logo.png> <out.ico>

import AppKit
import Foundation

let arguments = CommandLine.arguments
guard arguments.count >= 3 else {
    FileHandle.standardError.write("kullanım: generate_favicon.swift <logo.png> <out.ico>\n".data(using: .utf8)!)
    exit(1)
}

let sourcePath = arguments[1]
let outputPath = arguments[2]
let sizes = [16, 32, 48]

guard let source = NSImage(contentsOfFile: sourcePath) else {
    FileHandle.standardError.write("Logo okunamadı: \(sourcePath)\n".data(using: .utf8)!)
    exit(1)
}

// Veri blokları önce üretilir, sonra ofsetler hesaplanır.
var pngEntries: [Data] = []
for size in sizes {
    let side = CGFloat(size)
    guard let context = CGContext(
        data: nil,
        width: size,
        height: size,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else { continue }

    context.interpolationQuality = .high
    let rect = CGRect(origin: .zero, size: CGSize(width: side, height: side))
    if let cgImage = source.cgImage(forProposedRect: nil, context: nil, hints: nil) {
        context.draw(cgImage, in: rect)
    }

    guard let image = context.makeImage() else { continue }
    let rep = NSBitmapImageRep(cgImage: image)
    guard let png = rep.representation(using: .png, properties: [:]) else { continue }
    pngEntries.append(png)
}

guard !pngEntries.isEmpty else {
    FileHandle.standardError.write("Hiç boyut üretilemedi\n".data(using: .utf8)!)
    exit(1)
}

let entryCount = pngEntries.count
let dataStart = 6 + entryCount * 16

var directory: [UInt8] = []
var cursor = dataStart

for (index, png) in pngEntries.enumerated() {
    let size = sizes[index]
    directory.append(UInt8(size & 0xFF))        // genişlik (0 = 256)
    directory.append(UInt8(size & 0xFF))        // yükseklik
    directory.append(0)                          // renk sayısı
    directory.append(0)                          // rezerv
    directory.append(1)                          // renk düzlemi
    directory.append(0)                          // piksel başına bit
    directory.append(contentsOf: [0, 0])         // rezerv
    directory.append(UInt8(png.count & 0xFF))
    directory.append(UInt8((png.count >> 8) & 0xFF))
    directory.append(UInt8((png.count >> 16) & 0xFF))
    directory.append(UInt8((png.count >> 24) & 0xFF))
    directory.append(UInt8(cursor & 0xFF))
    directory.append(UInt8((cursor >> 8) & 0xFF))
    directory.append(UInt8((cursor >> 16) & 0xFF))
    directory.append(UInt8((cursor >> 24) & 0xFF))
    cursor += png.count
}

var output = Data([0, 0, 1, 0, UInt8(entryCount & 0xFF), 0])
output.append(contentsOf: directory)
for png in pngEntries {
    output.append(png)
}

try output.write(to: URL(fileURLWithPath: outputPath))
print("yazıldı: \(outputPath) (\(entryCount) boyut)")