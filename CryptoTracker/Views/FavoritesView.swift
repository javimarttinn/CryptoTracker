//
//  FavoritesView.swift
//  CryptoTracker
//
//  Created by Javier Martin on 25/12/24.
//
///
import SwiftUI

struct FavoritesView: View {
    @ObservedObject var viewModel: CryptoListViewModel
    @State private var selectedCrypto: Cryptocurrency?
    @State private var showDetail = false
    @State private var selectedCurrency = "eur"

    var body: some View {
        NavigationView {
            VStack {
                List(viewModel.favoriteCryptocurrencies) { crypto in
                    Button {
                        selectedCrypto = crypto
                        showDetail = true
                    } label: {
                        CryptoRowView(crypto: crypto, currencySymbol: selectedCurrency == "eur" ? "€" : "$")
                    }
                }
            }
            .navigationTitle("Favoritos")
            .sheet(isPresented: $showDetail) {
                if let selectedCrypto = selectedCrypto {
                    CryptoDetailView(crypto: selectedCrypto)
                }
            }
        }
    }
}

#Preview {
    FavoritesView(viewModel: CryptoListViewModel())
}

