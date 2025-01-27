//
//  ChartView.swift
//  Minus1Chart
//
//  Created by Max on 16.01.2025.
//

import SwiftUI

public struct Minus1CandleStickChart: View {
    @ObservedObject var viewModel = CandleStickViewModel()
    @Binding public var zoomLevel: CGFloat
    public var chartHeight: CGFloat
    @Binding public var selectedTimeFrame: String
    public var greenColor: Color
    public var symbol: String
    
    let timeFrames = ["1s", "1m", "5m", "15m", "1h", "4h", "1d"]
    
    public init(
        zoomLevel: Binding<CGFloat>,
        chartHeight: CGFloat,
        selectedTimeFrame: Binding<String>,
        greenColor: Color,
        symbol: String
    ) {
        self._zoomLevel = zoomLevel
        self.chartHeight = chartHeight
        self._selectedTimeFrame = selectedTimeFrame
        self.greenColor = greenColor
        self.symbol = symbol
    }
    
    public var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack {
                if viewModel.candles.isEmpty {
                    ProgressView("Loading data...")
                        .foregroundColor(.gray)
                } else {
                    GeometryReader { geometry in
                        let chartWidth = geometry.size.width
                        let chartHeight = geometry.size.height
                        let priceLevels = viewModel.calculatePriceLevels(chartHeight: chartHeight, levels: 5)
                        
                        HStack {
                            ZStack {
                                // Основний графік (свічки)
                                ScrollView(.horizontal) {
                                    LazyHStack(alignment: .bottom, spacing: 8 * zoomLevel) {
                                        ForEach(viewModel.candles) { candle in
                                            CandleStickView(candle: candle, viewModel: viewModel)
                                                .frame(width: 16 * zoomLevel)
                                        }
                                    }
                                    .padding(.trailing, 28)
                                    .padding()
                                }
                                .frame(height: chartHeight)
                                .background(ChartBackground(price: viewModel.currentPrice))
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            let dragAmount = value.translation.width
                                            let zoomChange = dragAmount / 1000
                                            zoomLevel = max(0.5, min(zoomLevel + zoomChange, 5.0))
                                            
                                            let limit = viewModel.calculateCandleLimit(zoomLevel: zoomLevel)
                                            viewModel.fetchCandles(symbol: symbol, timeFrame: selectedTimeFrame, limit: limit)
                                        }
                                )
                                
                                // Поточна ціна
                                Path { path in
                                    let currentPriceY = viewModel.normalizePrice(viewModel.currentPrice, chartHeight: chartHeight)
                                    path.move(to: CGPoint(x: 0, y: currentPriceY))
                                    path.addLine(to: CGPoint(x: chartWidth, y: currentPriceY))
                                }
                                .stroke(Color.red, lineWidth: 1)
                            }
                            
                            VStack(alignment: .trailing) {
                                ForEach(priceLevels, id: \.self) { level in
                                    GeometryReader { geometry in
                                        Text(String(format: "%.2f", level))
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                            .frame(width: 50, alignment: .trailing)
                                            .padding(.leading, 2)
                                    }
                                }
                            }
                            .frame(width: 60)
                            .background(ChartBackground(price: viewModel.currentPrice))
                        }
                    }
                    .frame(height: chartHeight)
                    
                    // Time Frame Selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(timeFrames, id: \.self) { timeFrame in
                                Text(timeFrame)
                                    .font(.headline)
                                    .frame(height: 30)
                                    .foregroundColor(selectedTimeFrame == timeFrame ? .white : .gray)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .frame(height: 40)
                                            .foregroundStyle(selectedTimeFrame == timeFrame ? greenColor : Color.clear)
                                    )
                                    .onTapGesture {
                                        selectedTimeFrame = timeFrame
                                        let limit = viewModel.calculateCandleLimit(zoomLevel: zoomLevel)
                                        viewModel.fetchCandles(symbol: symbol, timeFrame: timeFrame, limit: limit)
                                    }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .background(Color.black)
                }
            }
            .onAppear {
                viewModel.connectToWebSocket(symbol: symbol)
                let limit = viewModel.calculateCandleLimit(zoomLevel: zoomLevel)
                viewModel.fetchCandles(symbol: symbol, timeFrame: selectedTimeFrame, limit: limit)
            }
            .onDisappear {
                viewModel.disconnectToWebSocket()
            }
        }
    }
}

public struct Minus1CandleStickChart_Previews: PreviewProvider {
    public static var previews: some View {
        Group {
            Minus1CandleStickChart(zoomLevel: .constant(1.0), chartHeight: 400, selectedTimeFrame: .constant("1m"), greenColor: Color.green, symbol: "ETHUSDT")
                .previewDevice("iPhone 16")
                .previewDisplayName("iPhone 16")
            
            Minus1CandleStickChart(zoomLevel: .constant(1.0), chartHeight: 400, selectedTimeFrame: .constant("1m"), greenColor: Color.green, symbol: "ETHUSDT")
                .previewDevice("iPhone SE")
                .previewDisplayName("iPhone SE")
        }
    }
}
