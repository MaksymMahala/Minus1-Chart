//
//  CandleStickView.swift
//  Minus1Chart
//
//  Created by Max on 21.01.2025.
//

import SwiftUI

struct CandleStickView: View {
    let candle: Candle
    @ObservedObject var viewModel: CandleStickViewModel

    var body: some View {
        GeometryReader { geometry in
            let chartHeight = geometry.size.height
            let highY = viewModel.normalizePrice(candle.high, chartHeight: chartHeight)
            let lowY = viewModel.normalizePrice(candle.low, chartHeight: chartHeight)
            let openY = viewModel.normalizePrice(candle.open, chartHeight: chartHeight)
            let closeY = viewModel.normalizePrice(candle.close, chartHeight: chartHeight)
            let isBullish = candle.close > candle.open
            ZStack {
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width / 2, y: highY))
                    path.addLine(to: CGPoint(x: geometry.size.width / 2, y: lowY))
                }
                .stroke(isBullish ? Color.green : Color.red, lineWidth: 1)
                
                Path { path in
                    let bodyY = min(openY, closeY)
                    let bodyHeight = abs(openY - closeY)
                    path.addRect(CGRect(x: geometry.size.width / 4,
                                        y: bodyY,
                                        width: geometry.size.width / 2,
                                        height: bodyHeight))
                }
                .fill(isBullish ? Color.green : Color.red)
            }
        }
        .frame(width: 16) // Default candlestick width
    }
}
