# WaterfallGrid

A waterfall grid layout view for SwiftUI.

> **Fork notes** — this is a fork of [paololeonardi/WaterfallGrid](https://github.com/paololeonardi/WaterfallGrid) v1.1.0 (MIT).
> The layout engine has been replaced entirely:
> items are visible at full opacity on the **first render pass**, column
> assignment is a **synchronous, pure function** of its inputs, and heights
> are derived from a **caller-supplied aspect-ratio closure** rather than
> async runtime measurement.

---

## What changed from upstream

| | Upstream | This fork |
|---|---|---|
| First render | Items hidden (`opacity 0`) until async measurement completes | Items fully visible immediately |
| Height source | `GeometryReader` + `DispatchQueue.global` measurement | Caller-supplied `aspectRatio` closure |
| Layout | `ZStack` + async alignment guides | `HStack` + `VStack`, sized by SwiftUI natively |
| Async work | `DispatchQueue.global` + `DispatchQueue.main` | None |
| Preference keys | `ElementPreferenceKey`, `PreferenceSetter` | Removed |
| Column switching | Screen-size heuristic | `@Environment(\.horizontalSizeClass)` |
| Default animation | `.default` | `nil` |
| Default landscape cols | `2` | `3` |

---

## Usage

### 1 — Supply an aspect ratio for each item

The only new call-site requirement is an `aspectRatio` closure that returns
**width ÷ height** for each item. With that information the grid computes
every item's height in a single synchronous pass — no layout round-trip needed.

```swift
// Identifiable collection
WaterfallGrid(photos, aspectRatio: { $0.width / $0.height }) { photo in
    PhotoCell(photo: photo)
}

// Non-Identifiable collection — supply an id key path as well
WaterfallGrid(items, id: \.uuid, aspectRatio: { $0.aspectRatio }) { item in
    ItemCell(item: item)
}
```

Return `1.0` from the closure as a square fallback when exact dimensions
are not available:

```swift
WaterfallGrid(items, aspectRatio: { _ in 1.0 }) { item in
    ItemCell(item: item)
}
```

### 2 — Wrap in a ScrollView

`WaterfallGrid` is a plain `View` with natural height — drop it inside a
`ScrollView` exactly as you would a `VStack`:

```swift
ScrollView {
    WaterfallGrid(photos, aspectRatio: { $0.width / $0.height }) { photo in
        PhotoCell(photo: photo)
    }
    .padding(8)
}
```

### 3 — Customise with `.gridStyle`

```swift
WaterfallGrid(photos, aspectRatio: { $0.aspectRatio }) { photo in
    PhotoCell(photo: photo)
}
.gridStyle(
    columnsInPortrait:  2,   // compact horizontal size class (iPhone)
    columnsInLandscape: 3,   // regular horizontal size class (iPad / Mac)
    spacing: 8,
    animation: .spring(response: 0.4, dampingFraction: 0.8)
)
```

All parameters are optional and have sensible defaults:

| Parameter | Default |
|---|---|
| `columnsInPortrait` | `2` |
| `columnsInLandscape` | `3` |
| `spacing` | `8` |
| `animation` | `nil` |

Use the single-column overload when you don't need orientation switching:

```swift
.gridStyle(columns: 3, spacing: 12)
```

---

## Complete example

```swift
import SwiftUI
import WaterfallGrid

struct Photo: Identifiable {
    let id: UUID
    let imageURL: URL
    let pixelWidth:  CGFloat
    let pixelHeight: CGFloat
}

struct PhotoWall: View {
    let photos: [Photo]

    var body: some View {
        ScrollView {
            WaterfallGrid(photos, aspectRatio: { $0.pixelWidth / $0.pixelHeight }) { photo in
                AsyncImage(url: photo.imageURL) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.secondary.opacity(0.2)
                }
                .clipped()
                .cornerRadius(8)
            }
            .gridStyle(
                columnsInPortrait:  2,
                columnsInLandscape: 3,
                spacing: 8,
                animation: .easeInOut(duration: 0.35)
            )
            .padding(8)
        }
    }
}
```

### With add / remove animation

The `animation` parameter is applied with `value: items.map(\.id)`, so any
change to the collection — insert, remove, or reorder — triggers the
transition automatically:

```swift
@State private var photos: [Photo] = initialPhotos

var body: some View {
    ScrollView {
        WaterfallGrid(photos, aspectRatio: { $0.pixelWidth / $0.pixelHeight }) { photo in
            PhotoCell(photo: photo)
        }
        .gridStyle(
            columnsInPortrait:  2,
            columnsInLandscape: 3,
            spacing: 8,
            animation: .spring(response: 0.4, dampingFraction: 0.75)
        )
        .padding(8)
    }
    .toolbar {
        Button("Add")    { photos.insert(newPhoto(), at: 0) }
        Button("Remove") { photos.removeFirst() }
    }
}
```

---

## Migration from upstream

Add `aspectRatio:` after your data argument (or after `id:` if you supply one),
and remove any manual `onAppear` / opacity workarounds you may have added.

```swift
// Before
WaterfallGrid(photos) { photo in PhotoCell(photo: photo) }

// After
WaterfallGrid(photos, aspectRatio: { $0.width / $0.height }) { photo in PhotoCell(photo: photo) }
```

The `.gridStyle(columnsInPortrait:columnsInLandscape:spacing:animation:)` overload
is now available on **all** platforms (previously iOS-only).

---

## Installation

### Swift Package Manager

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/paololeonardi/WaterfallGrid.git", from: "1.1.0")
]
```

Or via Xcode: **File › Add Package Dependencies** and enter the repository URL.

---

## License

WaterfallGrid is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
Original work © 2019 Paolo Leonardi.
