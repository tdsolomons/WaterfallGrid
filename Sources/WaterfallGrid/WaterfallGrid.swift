//
//  Copyright © 2019 Paolo Leonardi.
//
//  Licensed under the MIT license. See the LICENSE file for more info.
//

import SwiftUI

/// A container that presents items of variable heights arranged in a grid.
///
/// Layout is computed synchronously from caller-supplied aspect ratios using a
/// greedy shortest-column algorithm. No async measurement, no opacity gating.
@available(iOS 13, OSX 10.15, tvOS 13, visionOS 1, watchOS 6, *)
public struct WaterfallGrid<Data, ID, Content>: View
    where Data: RandomAccessCollection, Content: View, ID: Hashable {

    @Environment(\.gridStyle) private var style
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private let data: Data
    private let dataId: KeyPath<Data.Element, ID>
    private let content: (Data.Element) -> Content
    private let aspectRatio: (Data.Element) -> CGFloat

    public var body: some View {
        let cols = style.columns(for: horizontalSizeClass)
        let columnData = buildColumns(count: cols)

        HStack(alignment: .top, spacing: style.spacing) {
            ForEach(0..<cols, id: \.self) { col in
                VStack(spacing: style.spacing) {
                    ForEach(columnData[col], id: dataId) { element in
                        content(element)
                            .aspectRatio(max(0.01, aspectRatio(element)), contentMode: .fit)
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .top)
            }
        }
        .animation(style.animation, value: data.map { AnyHashable($0[keyPath: dataId]) })
    }

    // MARK: - Layout

    /// Distributes items across `count` columns using a greedy shortest-column
    /// algorithm. Heights are approximated by 1/aspectRatio so the result is
    /// identical to computing real pixel heights — only the scale differs.
    func buildColumns(count: Int) -> [[Data.Element]] {
        let n = max(1, count)
        var columns = Array(repeating: [Data.Element](), count: n)
        var heights = Array(repeating: 0.0, count: n)

        for element in data {
            let ar = Double(max(0.01, aspectRatio(element)))
            // ties resolve to the left-most column (stable, no hashValue)
            let col = heights.indices.min(by: { heights[$0] < heights[$1] }) ?? 0
            columns[col].append(element)
            heights[col] += 1.0 / ar
        }

        return columns
    }
}

// MARK: - Initializers

extension WaterfallGrid {

    /// Creates an instance that uniquely identifies views based on the `id`
    /// key path and sizes them using a caller-supplied aspect-ratio closure.
    ///
    /// - Parameters:
    ///   - data: A collection of data.
    ///   - id: Key path to a property on an underlying data element.
    ///   - aspectRatio: Width ÷ height for each item. Return `1.0` for a square
    ///     fallback when precise packing is not required.
    ///   - content: A view builder for each data element.
    public init(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        aspectRatio: @escaping (Data.Element) -> CGFloat,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.dataId = id
        self.aspectRatio = aspectRatio
        self.content = content
    }
}

extension WaterfallGrid where ID == Data.Element.ID, Data.Element: Identifiable {

    /// Creates an instance that uniquely identifies views based on the
    /// identity of the underlying data element.
    ///
    /// - Parameters:
    ///   - data: A collection of identified data.
    ///   - aspectRatio: Width ÷ height for each item. Return `1.0` for a square
    ///     fallback when precise packing is not required.
    ///   - content: A view builder for each data element.
    public init(
        _ data: Data,
        aspectRatio: @escaping (Data.Element) -> CGFloat,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.dataId = \Data.Element.id
        self.aspectRatio = aspectRatio
        self.content = content
    }
}
