# Candlestick Chart in Swift

A **Candlestick Chart** is a financial chart used to represent price movements of an asset, such as stocks, over a specified time period. Each candlestick consists of four key components:
- **Open**: The price at the start of the time period.
- **Close**: The price at the end of the time period.
- **High**: The highest price during the time period.
- **Low**: The lowest price during the time period.

This chart is popular in trading applications as it provides detailed insights into market trends and price action.

## Features
- **Visual Representation**:
  - Green candles for price increases (Close > Open).
  - Red candles for price decreases (Close < Open).
- **Interactive**: Zoom and pan support to explore historical data.
- **Customizable**: Configure colors, candle width, and axis styles.
- **Real-Time Updates**: Support for live market data integration.

## Implementation in Swift
### Libraries
To simplify candlestick chart creation, consider using third-party chart libraries like:
1. [Charts](https://github.com/danielgindi/Charts) - A powerful data visualization library for iOS.
2. [SwiftUI Charts](https://developer.apple.com/documentation/charts) - Built-in charting framework for iOS 16+.

### Steps to Create a Candlestick Chart
1. **Import the Library**:
   ```swift
   import Charts
