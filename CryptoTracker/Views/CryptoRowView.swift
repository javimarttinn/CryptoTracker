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
        CryptoRowView(
            crypto: Cryptocurrency(
                id: "1",
                symbol: "btc",
                name: "Bitcoin",
                image: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png",
                currentPrice: 42900.55,
                marketCap: 800000000000,
                priceChangePercentage24h: +2.5
            ),
            currencySymbol: "$" // Simulación para dólares
        )
        
        CryptoRowView(
            crypto: Cryptocurrency(
                id: "1",
                symbol: "btc",
                name: "Bitcoin",
                image: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png",
                currentPrice: 42900.55,
                marketCap: 800000000000,
                priceChangePercentage24h: +2.5
            ),
            currencySymbol: "€" // Simulación para euros
        )
    }
    .padding()
}
