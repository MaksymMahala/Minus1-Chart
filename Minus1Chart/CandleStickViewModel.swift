//
//  CandleStickViewModel.swift
//  Minus1Chart
//
//  Created by Max on 21.01.2025.
//

import SwiftUI
import Combine

class CandleStickViewModel: ObservableObject {
    @Published var candles: [Candle] = []
    @Published var currentPrice: CGFloat = 0.0
    private var maxPrice: Double = 0
    private var minPrice: Double = 0
    private var lastUpdateTime: Date?
    private var webSocketTask: URLSessionWebSocketTask?
    private var cancellables = Set<AnyCancellable>()
    
    let maxCandlesToFetch = 1000

    func calculateCandleLimit(zoomLevel: CGFloat) -> Int {
        let baseLimit: CGFloat = 100
        let adjustedLimit = Int(baseLimit * zoomLevel)
        return min(adjustedLimit, maxCandlesToFetch)
    }
    
    func fetchCandles(symbol: String, timeFrame: String, limit: Int) {
        guard let url = URL(string: Constants.getCandles(symbol: symbol, timeFrame: timeFrame, limit: limit)) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode([APIResponse].self, from: data)
                    DispatchQueue.main.async {
                        let candles = decodedData.map {
                            Candle(open: $0.open, high: $0.high, low: $0.low, close: $0.close)
                        }
                        self.candles = candles
                        self.maxPrice = candles.map { $0.high }.max() ?? 1
                        self.minPrice = candles.map { $0.low }.min() ?? 0
                    }
                } catch {
                    print("Error decoding: \(error)")
                }
            }
        }.resume()
    }
    
    func normalizePrice(_ price: Double, chartHeight: CGFloat) -> CGFloat {
        guard maxPrice > minPrice else { return 0 }
        return CGFloat((maxPrice - price) / (maxPrice - minPrice)) * chartHeight
    }
    
    func connectToWebSocket(symbol: String) {
        let url = URL(string: Constants.tickerPrice(symbol: symbol))!
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        
        webSocketTask?.resume()
        listenToWebSocket()
    }
    
    func disconnectToWebSocket() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        print("WebSocket disconnected.")
    }
    
    private func listenToWebSocket() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("Error receiving WebSocket data: \(error)")
            case .success(let message):
                if case .string(let text) = message {
                    self?.handleWebSocketData(text: text)
                }
            }
            
            self?.listenToWebSocket()
        }
    }
    
    private func handleWebSocketData(text: String) {
        if let data = text.data(using: .utf8),
           let decoded = try? JSONDecoder().decode(TickerResponse.self, from: data) {
            DispatchQueue.main.async {
                self.currentPrice = CGFloat(decoded.closePrice)
//                print("Price: \(self.currentPrice)")
                
                let currentTime = Date()
                if let lastUpdateTime = self.lastUpdateTime {
                    let timeDifference = currentTime.timeIntervalSince(lastUpdateTime)
                    
                    // Check if 1 minute has passed
                    if timeDifference >= 60 {
                        self.createNewCandle(openPrice: decoded.closePrice)
                        self.lastUpdateTime = currentTime // Update last update time
                    }
                } else {
                    // First update
                    self.lastUpdateTime = currentTime
                    self.createNewCandle(openPrice: decoded.closePrice)
                }
                
                // Update last candle data
                if !self.candles.isEmpty {
                    var lastCandle = self.candles.removeLast()
                    lastCandle.close = decoded.closePrice
                    lastCandle.high = max(lastCandle.high, decoded.closePrice)
                    lastCandle.low = min(lastCandle.low, decoded.closePrice)
                    lastCandle.open = lastCandle.open // Open price stays the same for the current minute
                    self.candles.append(lastCandle)
                    
                    // Optionally update max and min prices for normalization
                    self.maxPrice = self.candles.map { $0.high }.max() ?? 1
                    self.minPrice = self.candles.map { $0.low }.min() ?? 0
                }
            }
        }
    }
    
    private func createNewCandle(openPrice: Double) {
        let newCandle = Candle(open: openPrice, high: openPrice, low: openPrice, close: openPrice)
        self.candles.append(newCandle)
        self.maxPrice = max(self.maxPrice, openPrice)
        self.minPrice = min(self.minPrice, openPrice)
//        print("New candle created with open price: \(openPrice)")
    }
}

extension CandleStickViewModel {
    func calculatePriceLevels(chartHeight: CGFloat, levels: Int) -> [Double] {
        guard let maxPrice = candles.max(by: { $0.high < $1.high })?.high,
              let minPrice = candles.min(by: { $0.low < $1.low })?.low else {
            return []
        }

        let step = (maxPrice - minPrice) / Double(levels) // Крок для рівнів
        return stride(from: minPrice, through: maxPrice, by: step).map { $0 }
    }
}

struct TickerResponse: Codable {
    var event: String
    var symbol: String
    var priceChange: Double
    var priceChangePercent: Double
    var weightedAvgPrice: Double
    var previousClosePrice: Double
    var closePrice: Double
    var closeQuantity: Double
    var bestBidPrice: Double
    var bestBidQuantity: Double
    var bestAskPrice: Double
    var bestAskQuantity: Double
    var openPrice: Double
    var highPrice: Double
    var lowPrice: Double
    var volume: Double
    var quoteVolume: Double
    var openTime: Double
    var closeTime: Double
    var firstTradeId: Double
    var lastTradeId: Double
    var numberOfTrades: Int

    private enum CodingKeys: String, CodingKey {
        case event = "Event"
        case symbol = "Symbol"
        case priceChange = "PriceChange"
        case priceChangePercent = "PriceChangePercent"
        case weightedAvgPrice = "WeightedAvgPrice"
        case previousClosePrice = "PreviousClosePrice"
        case closePrice = "ClosePrice"
        case closeQuantity = "CloseQuantity"
        case bestBidPrice = "BestBidPrice"
        case bestBidQuantity = "BestBidQuantity"
        case bestAskPrice = "BestAskPrice"
        case bestAskQuantity = "BestAskQuantity"
        case openPrice = "OpenPrice"
        case highPrice = "HighPrice"
        case lowPrice = "LowPrice"
        case volume = "Volume"
        case quoteVolume = "QuoteVolume"
        case openTime = "OpenTime"
        case closeTime = "CloseTime"
        case firstTradeId = "FirstTradeId"
        case lastTradeId = "LastTradeId"
        case numberOfTrades = "NumberOfTrades"
    }
}

