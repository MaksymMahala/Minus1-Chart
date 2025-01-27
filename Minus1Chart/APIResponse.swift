//
//  APIResponse.swift
//  Minus1Chart
//
//  Created by Max on 21.01.2025.
//

import Foundation

struct APIResponse: Decodable {
    let open: Double
    let high: Double
    let low: Double
    let close: Double
}
