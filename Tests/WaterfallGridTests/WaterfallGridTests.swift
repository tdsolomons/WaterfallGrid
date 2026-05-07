//
//  Copyright © 2019 Paolo Leonardi.
//
//  Licensed under the MIT license. See the LICENSE file for more info.
//

import XCTest
import SwiftUI
@testable import WaterfallGrid

class WaterfallGridTests: XCTestCase {

    // MARK: - buildColumns: empty data

    func test_buildColumns_empty_returnsEmptyColumns() {
        let sut = makeGrid(items: [], aspectRatios: [:])
        for count in [1, 2, 3] {
            let cols = sut.buildColumns(count: count)
            XCTAssertEqual(cols.count, count, "count=\(count)")
            XCTAssertTrue(cols.allSatisfy(\.isEmpty), "count=\(count)")
        }
    }

    // MARK: - buildColumns: single column

    func test_buildColumns_singleColumn_allItemsInOne() {
        let items = [0, 1, 2, 3, 4]
        let sut = makeGrid(items: items, aspectRatios: [:])
        let cols = sut.buildColumns(count: 1)
        XCTAssertEqual(cols.count, 1)
        XCTAssertEqual(cols[0], items)
    }

    // MARK: - buildColumns: greedy packing, equal aspect ratios

    func test_buildColumns_twoColumns_equalRatios_alternating() {
        // All items are square (ar=1.0 → relative height 1.0).
        // Greedy picks shortest (ties → col 0 first):
        // item0 → col0 (h=[1,0])
        // item1 → col1 (h=[1,1])
        // item2 → col0 tie→col0 (h=[2,1])
        // item3 → col1 (h=[2,2])
        // item4 → col0 tie→col0 (h=[3,2])
        let items = [0, 1, 2, 3, 4]
        let sut = makeGrid(items: items, aspectRatios: [:])
        let cols = sut.buildColumns(count: 2)
        XCTAssertEqual(cols[0], [0, 2, 4])
        XCTAssertEqual(cols[1], [1, 3])
    }

    func test_buildColumns_threeColumns_equalRatios_roundRobin() {
        // 6 items, 3 cols, all ar=1.0 → round-robin distribution
        let items = [0, 1, 2, 3, 4, 5]
        let sut = makeGrid(items: items, aspectRatios: [:])
        let cols = sut.buildColumns(count: 3)
        XCTAssertEqual(cols[0], [0, 3])
        XCTAssertEqual(cols[1], [1, 4])
        XCTAssertEqual(cols[2], [2, 5])
    }

    // MARK: - buildColumns: greedy packing, variable aspect ratios

    func test_buildColumns_twoColumns_variableRatios_shortestColumn() {
        // ar for item0=0.5 → rel-height 2.0  (tall portrait)
        // ar for item1=2.0 → rel-height 0.5  (wide landscape)
        // ar for item2=1.0 → rel-height 1.0
        // item0 → col0 (h=[2.0, 0.0])
        // item1 → col1 (h=[2.0, 0.5])
        // item2 → col1 (h=[2.0, 1.5])  ← col1 still shorter
        let ratios: [Int: CGFloat] = [0: 0.5, 1: 2.0, 2: 1.0]
        let items = [0, 1, 2]
        let sut = makeGrid(items: items, aspectRatios: ratios)
        let cols = sut.buildColumns(count: 2)
        XCTAssertEqual(cols[0], [0])
        XCTAssertEqual(cols[1], [1, 2])
    }

    func test_buildColumns_twoColumns_tallItemsBalance() {
        // item0: ar=1.0 → h=1.0   item0→col0 (h=[1,0])
        // item1: ar=1.0 → h=1.0   item1→col1 (h=[1,1])
        // item2: ar=0.5 → h=2.0   tie→col0   (h=[3,1])
        // item3: ar=0.5 → h=2.0   item3→col1 (h=[3,3])
        let ratios: [Int: CGFloat] = [0: 1.0, 1: 1.0, 2: 0.5, 3: 0.5]
        let items = [0, 1, 2, 3]
        let sut = makeGrid(items: items, aspectRatios: ratios)
        let cols = sut.buildColumns(count: 2)
        XCTAssertEqual(cols[0], [0, 2])
        XCTAssertEqual(cols[1], [1, 3])
    }

    // MARK: - buildColumns: zero/negative count clamped to 1

    func test_buildColumns_zeroCount_clampedToOne() {
        let items = [0, 1, 2]
        let sut = makeGrid(items: items, aspectRatios: [:])
        let cols = sut.buildColumns(count: 0)
        XCTAssertEqual(cols.count, 1)
        XCTAssertEqual(cols[0], items)
    }

    // MARK: - GridStyle columns(for:)

    func test_gridStyle_columnsForCompact_returnsPortraitCount() {
        let style = GridSyle(columnsInPortrait: 2, columnsInLandscape: 4, spacing: 8, animation: nil)
        #if os(iOS)
        XCTAssertEqual(style.columns(for: .compact), 2)
        XCTAssertEqual(style.columns(for: .regular), 4)
        XCTAssertEqual(style.columns(for: nil), 2)
        #endif
    }

    // MARK: - Helpers

    private func makeGrid(
        items: [Int],
        aspectRatios: [Int: CGFloat]
    ) -> WaterfallGrid<[Int], Int, Text> {
        WaterfallGrid(items, id: \.self, aspectRatio: { aspectRatios[$0] ?? 1.0 }) {
            Text("\($0)")
        }
    }
}
