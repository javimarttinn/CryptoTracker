//
//  FavoritesView.swift
//  CryptoTracker
//
//  Created by Javier Martin on 25/12/24.
//

import SwiftUI

struct FavoritesView: View {
    @ObservedObject var viewModel: FavoritesViewModel
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationView {
            Group {
                if viewModel.favoriteCryptocurrencies.isEmpty {
                   
                    VStack {
                        Text("No tienes criptomonedas en favoritos.")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding()
                        Image(systemName: "star.slash.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.7))
                    }
                } else {
                    // Mostrar lista favs
                    List(viewModel.favoriteCryptocurrencies) { crypto in
                        NavigationLink(
                            destination: CryptoDetailView(
                                crypto: crypto,
                                currencySymbol: viewModel.selectedCurrency == "eur" ? "€" : "$",
                                favoritesViewModel: viewModel,
                                viewModel: CryptoDetailViewModel()
                            )
                        ) {
                            CryptoRowView(
                                crypto: crypto,
                                currencySymbol: viewModel.selectedCurrency == "eur" ? "€" : "$"
                            )
                        }
                    }
                }
            }
            .navigationTitle("Favoritos")
            .onAppear {
                viewModel.loadFavoriteCryptocurrencies(modelContext: modelContext)
            }
        }
    }
}

#Preview {
    FavoritesView(viewModel: FavoritesViewModel())
}
