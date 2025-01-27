//
//  ChartBackground.swift
//  Minus1Chart
//
//  Created by Max on 21.01.2025.
//

import SwiftUI

struct ChartBackground: View {
    var price: CGFloat
    
    var body: some View {
        ZStack {
            Color.black
            
            GeometryReader { geometry in
                let totalLines: Int = 6
                let lineSpacing = geometry.size.height / CGFloat(totalLines)
                
                ForEach(0..<totalLines) { index in
                    Path { path in
                        let y = lineSpacing * CGFloat(index)
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                    .stroke(Color.gray.opacity(0.5), style: StrokeStyle(lineWidth: 0.5, dash: [5, 5]))
                }
                
                // Price Ticker Line
                let priceYPosition = (geometry.size.height - price)
                
                Path { path in
                    path.move(to: CGPoint(x: 0, y: priceYPosition))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: priceYPosition))
                }
                .stroke(Color.red, style: StrokeStyle(lineWidth: 2, dash: [2, 5]))
            }
        }
    }
}
