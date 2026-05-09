//
//  PhotoWallExample.swift
//
//  Self-contained usage example for the WaterfallGrid fork.
//  Demonstrates: caller-supplied aspect ratios, greedy packing,
//  portrait/landscape column switching, and insert/remove animation.
//

import SwiftUI
import WaterfallGrid

// MARK: - Model

/// A photo whose pixel dimensions are known at call time
/// (e.g. fetched from server metadata, Core Data, or PHAsset).
struct Photo: Identifiable {
    let id: UUID
    let color: Color          // stands in for a real image
    let pixelWidth: CGFloat
    let pixelHeight: CGFloat

    /// Width ÷ height — the value WaterfallGrid needs.
    var aspectRatio: CGFloat { pixelWidth / pixelHeight }
}

// MARK: - Sample data

extension Photo {
    /// A deterministic mix of portrait, square, and landscape shots.
    static let samples: [Photo] = [
        //           w     h      colour
        make(800,   600,  .red),          // landscape  1.33
        make(600,  1000,  .blue),         // portrait   0.60
        make(400,   400,  .green),        // square     1.00
        make(1200,  800,  .orange),       // landscape  1.50
        make(500,   900,  .purple),       // portrait   0.56
        make(700,   700,  .pink),         // square     1.00
        make(900,   500,  .yellow),       // landscape  1.80
        make(400,   800,  .teal),         // portrait   0.50
        make(600,   400,  .indigo),       // landscape  1.50
        make(500,   750,  .mint),         // portrait   0.67
        make(800,   800,  .cyan),         // square     1.00
        make(1000,  600,  .brown),        // landscape  1.67
    ]

    private static func make(_ w: CGFloat, _ h: CGFloat, _ c: Color) -> Photo {
        Photo(id: UUID(), color: c, pixelWidth: w, pixelHeight: h)
    }
}

// MARK: - Cell

private struct PhotoCell: View {
    let photo: Photo

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(photo.color.opacity(0.85))
            VStack(spacing: 4) {
                Text("\(Int(photo.pixelWidth))×\(Int(photo.pixelHeight))")
                    .font(.caption2.monospacedDigit())
                    .foregroundColor(.white)
                Text(String(format: "ar %.2f", photo.aspectRatio))
                    .font(.caption2.monospacedDigit())
                    .foregroundColor(.white.opacity(0.75))
            }
        }
    }
}

// MARK: - Example view

struct PhotoWallExample: View {
    @State private var photos = Photo.samples
    private var nextIndex = 0

    var body: some View {
        NavigationView {
            ScrollView {
                // ── The grid ────────────────────────────────────────────────
                WaterfallGrid(photos, aspectRatio: { $0.aspectRatio }) { photo in
                    PhotoCell(photo: photo)
                }
                .gridStyle(
                    columnsInPortrait:  2,
                    columnsInLandscape: 3,
                    spacing: 8,
                    animation: .spring(response: 0.4, dampingFraction: 0.75)
                )
                .padding(8)
                // ────────────────────────────────────────────────────────────
            }
            .navigationTitle("Photo Wall")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    // Prepend a random photo — existing items keep their column
                    Button {
                        let p = Photo.samples.randomElement()!
                        photos.insert(
                            Photo(id: UUID(),
                                  color: p.color,
                                  pixelWidth: p.pixelWidth,
                                  pixelHeight: p.pixelHeight),
                            at: 0
                        )
                    } label: {
                        Image(systemName: "plus.square.on.square")
                    }

                    // Remove the last photo
                    Button {
                        if !photos.isEmpty { photos.removeLast() }
                    } label: {
                        Image(systemName: "minus.square")
                    }
                    .disabled(photos.isEmpty)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    // Shuffle to show that column assignment is greedy,
                    // not random — same ratios always pack the same way.
                    Button {
                        photos.shuffle()
                    } label: {
                        Image(systemName: "shuffle")
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct PhotoWallExample_Previews: PreviewProvider {
    static var previews: some View {
        PhotoWallExample()
    }
}
