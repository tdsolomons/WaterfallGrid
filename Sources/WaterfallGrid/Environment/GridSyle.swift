//
//  Copyright © 2019 Paolo Leonardi.
//
//  Licensed under the MIT license. See the LICENSE file for more info.
//

import SwiftUI

struct GridSyle {
    @PositiveNumber var columnsInPortrait: Int
    @PositiveNumber var columnsInLandscape: Int

    let spacing: CGFloat
    let animation: Animation?

    func columns(for sizeClass: UserInterfaceSizeClass?) -> Int {
        #if os(OSX) || os(tvOS) || targetEnvironment(macCatalyst) || os(visionOS)
        return columnsInLandscape
        #elseif os(watchOS)
        return columnsInPortrait
        #else
        return sizeClass == .regular ? columnsInLandscape : columnsInPortrait
        #endif
    }
}

struct GridStyleKey: EnvironmentKey {
    static let defaultValue = GridSyle(columnsInPortrait: 2, columnsInLandscape: 3,
                                       spacing: 8, animation: nil)
}

extension EnvironmentValues {
    var gridStyle: GridSyle {
        get { self[GridStyleKey.self] }
        set { self[GridStyleKey.self] = newValue }
    }
}
