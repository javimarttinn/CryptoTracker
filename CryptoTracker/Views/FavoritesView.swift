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

    var body: some View {
        NavigationView {
            VStack {
                List(viewModel.favoriteCryptocurrencies) { crypto in
                    Button {
                        selectedCrypto = crypto
                        showDetail = true
                    } label: {
                        CryptoRowView(crypto: crypto)
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

