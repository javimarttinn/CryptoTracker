//
//  CryptoDetailViewModel.swift
//  CryptoTracker
//
//  Created by Javier Martin on 22/12/24.
//
// logica para la vista en detalle de la cryptomoneda selecionada incluyendo los graficos


import SwiftUI
import Combine

class CryptoDetailViewModel: ObservableObject {
    @Published var historicalPrices: [HistoricalPrice] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedDays: Int = 7 // Valor por defecto
    @Published var crypto: Cryptocurrency?
    @Published var favoriteCryptocurrencies: [Cryptocurrency] = []

    
    
    init(crypto: Cryptocurrency? = nil) {
           self.crypto = crypto
       }

    func fetchHistoricalPrices(for id: String, vsCurrency: String) {
        isLoading = true
        API.shared.fetchHistoricalPrices(for: id, vsCurrency: vsCurrency, days: selectedDays) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let prices):
                    self?.historicalPrices = prices
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    
    
    
    
    
}
