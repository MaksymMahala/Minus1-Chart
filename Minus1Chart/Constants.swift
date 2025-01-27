//
//  Constants.swift
//  Minus1Chart
//
//  Created by Max on 21.01.2025.
//

import Foundation

enum Constants {
    static func getCandles(symbol: String /* For example BTCUSDT */, timeFrame: String, limit: Int) -> String {
        return "https://minus1-asp-net-c45d1500aed6.herokuapp.com/api/Binance/candlesticks?symbol=\(symbol)&interval=\(timeFrame)&limit=\(limit)"
    }
    
    static func tickerPrice(symbol: String /* For example btcusdt */) -> String {
        return "wss://minus1-asp-net-c45d1500aed6.herokuapp.com/ws/ticker?symbol=\(symbol)"
    }
}
