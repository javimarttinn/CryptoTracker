//
//  ContentView.swift
//  CryptoTracker
//
//  Created by Javier Martin on 22/12/24.
//

import SwiftUI
import SwiftData


struct CryptoListView: View {
    @StateObject private var viewModel = CryptoListViewModel()
    @State private var selectedCurrency = "usd"

    var body: some View {
        NavigationView {
            VStack {
                // Selector de moneda (USD / EUR)
                Picker("Currency", selection: $selectedCurrency) {
                    Text("USD").tag("usd")
                    Text("EUR").tag("eur")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                // Lista de criptomonedas
                List(viewModel.cryptocurrencies) { crypto in
                    CryptoRowView(crypto: crypto)
                }
                .listStyle(PlainListStyle())
                .onAppear {
                    viewModel.fetchTopCryptocurrencies(vsCurrency: selectedCurrency)
                }
                .onChange(of: selectedCurrency) {
                    viewModel.fetchTopCryptocurrencies(vsCurrency: selectedCurrency)
                }
            }
            .navigationTitle("Top 10 Cryptos")
            .alert(item: $viewModel.errorMessage) { errorMessage in
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

#Preview {
    CryptoListView()
        .modelContainer(for: Item.self, inMemory: true)
}
