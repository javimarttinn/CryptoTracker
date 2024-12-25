//
//  CryptoListViewModel.swift
//  CryptoTracker
//
//  Created by Javier Martin on 22/12/24.
//

// Logica e interacion con los datos
import Foundation
import Combine


struct ErrorMessage: Identifiable {
    let id = UUID()
    let message: String
}

class CryptoListViewModel: ObservableObject {
    @Published var cryptocurrencies: [Cryptocurrency] = []
    @Published var errorMessage: ErrorMessage?
    @Published var isDataLoaded = false
    

    func fetchTopCryptocurrencies(vsCurrency: String) {
        API.shared.fetchTopCryptocurrencies(vsCurrency: vsCurrency) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let cryptos):
                    self?.cryptocurrencies = cryptos
                    self?.isDataLoaded = true
                case .failure(let error):
                    self?.errorMessage = ErrorMessage(message: error.localizedDescription)
                    self?.isDataLoaded = true
                }
            }
        }
    }
}
