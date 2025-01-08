//
//  CryptoRow.swift
//  CryptoTracker
//
//  Created by Javier Martin on 22/12/24.
//

import SwiftUI

struct CryptoRowView: View {
    let crypto: Cryptocurrency
    let currencySymbol: String // Añadido para mostrar el símbolo de la divisa

    var body: some View {
        HStack {
            // Imagen de la criptomoneda
            AsyncImage(url: URL(string: crypto.image)) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            .shadow(radius: 4)

            // Información de la criptomoneda
            VStack(alignment: .leading) {
                Text(crypto.name)
                    .font(.headline)
                Text(crypto.symbol.uppercased())
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            // Precio actual y variación
            VStack(alignment: .trailing) {
                Text("\(currencySymbol)\(crypto.currentPrice, specifier: "%.2f")")
                    .font(.headline)
                Text("\(crypto.priceChangePercentage24h >= 0 ? "+" : "")\(crypto.priceChangePercentage24h, specifier: "%.2f")%")
                    .font(.subheadline)
                    .foregroundColor(crypto.priceChangePercentage24h >= 0 ? .green : .red)
            }
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    VStack {
        // 🔹 Vista en Dólares ($)
        CryptoRowView(
            crypto: Cryptocurrency(
                id: "1",
                symbol: "BTC",
                name: "Bitcoin",
                image: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png",
                currentPrice: 42900.55,
                marketCap: 800000000000,
                marketCapRank: 1,
                fullyDilutedValuation: 850000000000,
                totalVolume: 35000000000,
                high24h: 43500.00,
                low24h: 42000.00,
                priceChange24h: 150.50,
                priceChangePercentage24h: 2.5,
                marketCapChange24h: 2000000000,
                marketCapChangePercentage24h: 0.5,
                circulatingSupply: 19000000,
                totalSupply: 21000000,
                maxSupply: 21000000,
                ath: 69000.00,
                athChangePercentage: -37.8,
                athDate: "2021-11-10T14:24:11.849Z",
                atl: 65.53,
                atlChangePercentage: 65345.2,
                atlDate: "2013-07-06T00:00:00.000Z",
                roi: nil,
                lastUpdated: "2025-01-08T16:16:52.307Z",
                isFavorite: false
            ),
            currencySymbol: "$"
        )
        
        Divider().padding(.vertical)
        
        // 🔹 Vista en Euros (€)
        CryptoRowView(
            crypto: Cryptocurrency(
                id: "1",
                symbol: "BTC",
                name: "Bitcoin",
                image: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png",
                currentPrice: 42900.55,
                marketCap: 800000000000,
                marketCapRank: 1,
                fullyDilutedValuation: 850000000000,
                totalVolume: 35000000000,
                high24h: 43500.00,
                low24h: 42000.00,
                priceChange24h: 150.50,
                priceChangePercentage24h: 2.5,
                marketCapChange24h: 2000000000,
                marketCapChangePercentage24h: 0.5,
                circulatingSupply: 19000000,
                totalSupply: 21000000,
                maxSupply: 21000000,
                ath: 69000.00,
                athChangePercentage: -37.8,
                athDate: "2021-11-10T14:24:11.849Z",
                atl: 65.53,
                atlChangePercentage: 65345.2,
                atlDate: "2013-07-06T00:00:00.000Z",
                roi: nil,
                lastUpdated: "2025-01-08T16:16:52.307Z",
                isFavorite: false
            ),
            currencySymbol: "€"
        )
    }
    .padding()
}
