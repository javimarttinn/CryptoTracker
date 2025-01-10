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
    @State private var showFavorites = false
    @State private var showSearch = false
    @Environment(\.modelContext) private var modelContext
    @StateObject private var detailViewModel = CryptoDetailViewModel()
    @StateObject var favoritesViewModel = FavoritesViewModel()



    var body: some View {
        NavigationView {
            VStack {
                HStack(spacing: 12) {
                    Button(action: {
                        selectedCurrency = "eur"
                        viewModel.switchCurrency(to: selectedCurrency)
                    }) {
                        Text("EUR")
                            .font(.subheadline)
                            .foregroundColor(selectedCurrency == "eur" ? .white : .blue)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 12)
                            .background(selectedCurrency == "eur" ? Color.blue : Color.white)
                            .clipShape(Capsule())
                            .shadow(color: selectedCurrency == "eur" ? .blue.opacity(0.3) : .clear, radius: 2, x: 0, y: 1)
                    }

                    Button(action: {
                        selectedCurrency = "usd"
                        viewModel.switchCurrency(to: selectedCurrency)
                    }) {
                        Text("USD")
                            .font(.subheadline) 
                            .foregroundColor(selectedCurrency == "usd" ? .white : .blue)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 12)
                            .background(selectedCurrency == "usd" ? Color.blue : Color.white)
                            .clipShape(Capsule())
                            .shadow(color: selectedCurrency == "usd" ? .blue.opacity(0.3) : .clear, radius: 2, x: 0, y: 1)
                    }
                }
                .padding(6)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                    
                    Divider()
                        .padding(.vertical, 4)
                    
                    // Botón para ver favoritos
                    Button(action: {
                        showFavorites = true
                    }) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("Ver Favoritos")
                                .font(.headline)
                                .foregroundColor(.black)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .sheet(isPresented: $showFavorites) {
                        FavoritesView(viewModel: favoritesViewModel)
                    }
                
                .background(Color.white.edgesIgnoringSafeArea(.top))

                // Lista de criptomonedas
                List {
                    ForEach(viewModel.cryptocurrencies) { crypto in
                        Button {
                            selectedCrypto = crypto
                            showDetail = true
                        } label: {
                            CryptoRowView(crypto: crypto, currencySymbol: selectedCurrency == "eur" ? "€" : "$")
                        }
                    }
                    .onDelete { indexSet in
                        viewModel.removeCryptocurrency(at: indexSet, modelContext: modelContext)
                    }
                    
                }
                .onAppear {
                    viewModel.loadInitialData(modelContext: modelContext)
                    favoritesViewModel.loadFavoriteCryptocurrencies(modelContext: modelContext)
                   

                }
            }
            .navigationTitle("Crypto Tracker💰🪙")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showSearch = true
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showSearch) {
                CryptoSearchView(viewModel: viewModel)
            }
            .alert(item: $viewModel.errorMessage) { errorMessage in
                Alert(
                    title: Text("Error"),
                    message: Text("Se ha alcanzado el límite de solicitudes. Por favor, inténtalo de nuevo más tarde."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $showDetail) {
                if let selectedCrypto = selectedCrypto {
                    CryptoDetailView(
                        crypto: selectedCrypto,
                        currencySymbol: selectedCurrency == "eur" ? "€" : "$",
                        favoritesViewModel: favoritesViewModel,
                        viewModel: CryptoDetailViewModel(crypto: selectedCrypto)
                    )

                }
            }
        }
    }
}

#Preview {
    CryptoListView()
        .modelContainer(for: Item.self, inMemory: true)
}
