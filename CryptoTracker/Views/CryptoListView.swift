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
    @State private var selectedCrypto: Cryptocurrency?
    @State private var showDetail = false
    @State private var showFavorites = false // Controla la navegación a la vista de favoritos
    

    var body: some View {
        NavigationView {
            VStack {
                // 🔹 Selector de moneda (EUR / USD) con botones
                HStack(spacing: 16) {
                    Button(action: {
                        selectedCurrency = "eur"
                        viewModel.fetchTopCryptocurrencies(vsCurrency: selectedCurrency)
                    }) {
                        Text("EUR")
                            .font(.headline)
                            .foregroundColor(selectedCurrency == "eur" ? .white : .blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedCurrency == "eur" ? Color.blue : Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }

                    Button(action: {
                        selectedCurrency = "usd"
                        viewModel.fetchTopCryptocurrencies(vsCurrency: selectedCurrency)
                    }) {
                        Text("USD")
                            .font(.headline)
                            .foregroundColor(selectedCurrency == "usd" ? .white : .blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedCurrency == "usd" ? Color.blue : Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                
                // 🔹 Botón para ver favoritos
                Button(action: {
                    showFavorites = true
                }) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Ver Favoritos")
                            .font(.headline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.top, 4)

                // 🔹 Lista de criptomonedas
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
            }
            .navigationTitle("Top Cryptos")
            .alert(item: $viewModel.errorMessage) { errorMessage in
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage.message),
                    dismissButton: .default(Text("OK"))
                )
            }
            // 🔹 Navegación a la Vista de Detalle
            .sheet(isPresented: $showDetail) {
                if let selectedCrypto = selectedCrypto {
                    CryptoDetailView(crypto: selectedCrypto)
                }
            }
            // 🔹 Navegación a la Vista de Favoritos
            //.sheet(isPresented: $showFavorites) {
                //FavoritesView()
            //}
        }
    }
}

#Preview {
    CryptoListView()
        .modelContainer(for: Item.self, inMemory: true)
}
