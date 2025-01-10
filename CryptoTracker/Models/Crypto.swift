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
    let marketCapRank: Int?
    let fullyDilutedValuation: Double?
    let totalVolume: Double       // Volumen de mercado 24h
    let high24h: Double?          // Máximo en las últimas 24h
    let low24h: Double?           // Mínimo en las últimas 24h
    let priceChange24h: Double?   // Cambio de precio en 24h
    let priceChangePercentage24h: Double
    let marketCapChange24h: Double?
    let marketCapChangePercentage24h: Double?
    let circulatingSupply: Double // Suministro circulante
    let totalSupply: Double?      // Suministro total
    let maxSupply: Double?        // Suministro máximo
    let ath: Double?              // Precio más alto de la historia
    let athChangePercentage: Double? // Cambio de porcentaje respecto al ATH
    let athDate: String?          // Fecha del ATH
    let atl: Double?              // Precio más bajo de la historia
    let atlChangePercentage: Double? // Cambio de porcentaje respecto al ATL
    let atlDate: String?          // Fecha del ATL
    let roi: ROI?                 // Retorno de la inversión
    let lastUpdated: String?      // Última actualización
    var isFavorite: Bool = false  // Para marcar como favorito
    
    enum CodingKeys: String, CodingKey {
        case id, symbol, name, image
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case marketCapRank = "market_cap_rank"
        case fullyDilutedValuation = "fully_diluted_valuation"
        case totalVolume = "total_volume"
        case high24h = "high_24h"
        case low24h = "low_24h"
        case priceChange24h = "price_change_24h"
        case priceChangePercentage24h = "price_change_percentage_24h"
        case marketCapChange24h = "market_cap_change_24h"
        case marketCapChangePercentage24h = "market_cap_change_percentage_24h"
        case circulatingSupply = "circulating_supply"
        case totalSupply = "total_supply"
        case maxSupply = "max_supply"
        case ath
        case athChangePercentage = "ath_change_percentage"
        case athDate = "ath_date"
        case atl
        case atlChangePercentage = "atl_change_percentage"
        case atlDate = "atl_date"
        case roi
        case lastUpdated = "last_updated"
    }
}


struct ROI: Codable, Hashable {
    let times: Double?
    let currency: String?
    let percentage: Double?
}
