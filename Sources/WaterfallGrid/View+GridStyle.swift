//
//  Copyright © 2019 Paolo Leonardi.
//
//  Licensed under the MIT license. See the LICENSE file for more info.
//

import SwiftUI

// MARK: - GridStyle

extension View {

    /// Sets the style for `WaterfallGrid` within the environment of `self`.
    ///
    /// - Parameter columnsInPortrait: Columns when the horizontal size class is
    ///   compact (iPhone portrait). Ignored on macOS, tvOS, and watchOS.
    ///   The default is `2`.
    /// - Parameter columnsInLandscape: Columns when the horizontal size class is
    ///   regular (iPad or Mac). The default is `3`.
    /// - Parameter spacing: Distance between adjacent columns and rows. The
    ///   default is `8`.
    /// - Parameter animation: Applied when the item collection changes. Pass
    ///   `nil` (the default) for no animation.
    public func gridStyle(
        columnsInPortrait: Int = 2,
        columnsInLandscape: Int = 3,
        spacing: CGFloat = 8,
        animation: Animation? = nil
    ) -> some View {
        let style = GridSyle(
            columnsInPortrait: columnsInPortrait,
            columnsInLandscape: columnsInLandscape,
            spacing: spacing,
            animation: animation
        )
        return self.environment(\.gridStyle, style)
    }

    /// Sets the style for `WaterfallGrid` within the environment of `self`,
    /// using the same column count in every orientation.
    ///
    /// - Parameter columns: The number of columns. The default is `2`.
    /// - Parameter spacing: Distance between adjacent columns and rows. The
    ///   default is `8`.
    /// - Parameter animation: Applied when the item collection changes. Pass
    ///   `nil` (the default) for no animation.
    public func gridStyle(
        columns: Int = 2,
        spacing: CGFloat = 8,
        animation: Animation? = nil
    ) -> some View {
        gridStyle(
            columnsInPortrait: columns,
            columnsInLandscape: columns,
            spacing: spacing,
            animation: animation
        )
    }
}
