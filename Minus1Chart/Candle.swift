//
//  Candle.swift
//  Minus1Chart
//
//  Created by Max on 21.01.2025.
//

import Foundation

struct Candle: Identifiable {
    var id = UUID()
    var open: Double
    var high: Double
    var low: Double
    var close: Double
}
