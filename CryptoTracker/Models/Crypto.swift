//
//  Crypto.swift
//  CryptoTracker
//
//  Created by Javier Martin on 22/12/24.
//

import Foundation


struct Cryptocurrency: Identifiable, Codable, Hashable {
    let id: String
    let symbol: String
    let name: String
    let image: String
    let currentPrice: Double
    let marketCap: Double
    let priceChangePercentage24h: Double
    var isFavorite: Bool = false
    

    
    enum CodingKeys: String, CodingKey {
        case id, symbol, name, image
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case priceChangePercentage24h = "price_change_percentage_24h"
    }
}
