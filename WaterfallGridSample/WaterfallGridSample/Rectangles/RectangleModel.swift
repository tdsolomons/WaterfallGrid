//
//  Copyright © 2019 Paolo Leonardi.
//
//  Licensed under the MIT license. See the LICENSE file for more info.
//

import Foundation
import SwiftUI

struct RectangleModel: Identifiable, Equatable {
    var id = UUID()
    var index: Int
    var size: CGFloat = Generator.Rectangles.randomSize()
    var color: Color = Generator.Rectangles.randomColor()

    // width ÷ height: use 100 pt as the reference column width so that
    // taller rectangles get a smaller ratio and shorter ones get larger.
    var aspectRatio: CGFloat { 100.0 / size }
}
