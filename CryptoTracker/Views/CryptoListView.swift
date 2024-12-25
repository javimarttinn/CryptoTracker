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
    @State private var selectedCurrency = "eur"
    @State private var selectedCrypto: Cryptocurrency?// Guarda la criptomoneda seleccionada
    @State private var showDetail = false // Controla la navegación a la vista de detalle

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
                    Button {
                        selectedCrypto = crypto
                        showDetail = true
                    } label: {
                        CryptoRowView(crypto: crypto)
                    }
                }
                .listStyle(PlainListStyle())
                .onAppear {
                    viewModel.fetchTopCryptocurrencies(vsCurrency: selectedCurrency)
                }
                .onChange(of: selectedCurrency) {
                    viewModel.fetchTopCryptocurrencies(vsCurrency: selectedCurrency)
                }
            }
            .navigationTitle("Top Cryptos")
            .alert(item: $viewModel.errorMessage) { errorMessage in
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage.message),
                    dismissButton: .default(Text("OK"))
                )
            }
            // Navegación a la Vista de Detalle
            .sheet(isPresented: $showDetail) {
                if let selectedCrypto = selectedCrypto {
                    CryptoDetailView(crypto: selectedCrypto)
                }
            }
        }
    }
}

#Preview {
    CryptoListView()
        .modelContainer(for: Item.self, inMemory: true)
}
