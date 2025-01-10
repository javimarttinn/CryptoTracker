//
//  FavouritesViewModel.swift
//  CryptoTracker
//
//  Created by Javier Martin on 25/12/24.
//

import SwiftData
import Foundation
import Combine

class FavoritesViewModel: ObservableObject {
    @Published var favoriteCryptocurrencies: [Cryptocurrency] = []
    @Published var errorMessage: ErrorMessage?

    var selectedCurrency: String = "eur"

    func toggleFavorite(for crypto: Cryptocurrency, from cryptocurrencies: [Cryptocurrency], modelContext: ModelContext) {
        let fetchDescriptor = FetchDescriptor<CryptoFavorite>(predicate: #Predicate { $0.id == crypto.id })
        do {
            if let existingFavorite = try modelContext.fetch(fetchDescriptor).first {
                // Eliminar favorito
                modelContext.delete(existingFavorite)
                favoriteCryptocurrencies.removeAll { $0.id == crypto.id }
                print("Eliminado de favoritos: \(crypto.name)")
            } else {
                // Añadir favorito desde el array `cryptocurrencies`
                if let cryptoToAdd = cryptocurrencies.first(where: { $0.id == crypto.id }) {
                    let newFavorite = CryptoFavorite(id: crypto.id)
                    modelContext.insert(newFavorite)
                    favoriteCryptocurrencies.append(cryptoToAdd)
                    print("Añadido a favoritos: \(cryptoToAdd.name)")
                } else {
                    print("Criptomoneda no encontrada en el array de criptomonedas.")
                }
            }
            try modelContext.save()
        } catch {
            errorMessage = ErrorMessage(message: "Error al modificar favoritos: \(error.localizedDescription)")
        }
    }


    // argar fvs al Iniciar
    func loadFavoriteCryptocurrencies(modelContext: ModelContext) {
        let fetchDescriptor = FetchDescriptor<CryptoFavorite>()
        do {
           
            let favoriteIDs = try modelContext.fetch(fetchDescriptor).map { $0.id }
            
         
            guard !favoriteIDs.isEmpty else {
                DispatchQueue.main.async {
                    self.favoriteCryptocurrencies = []
                }
                return
            }
            
            // realizar una única solicitud con todos los IDs favoritos (prueba)
            API.shared.fetchCryptocurrencyDetails(ids: favoriteIDs, vsCurrency: selectedCurrency) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let cryptos):
                        self.favoriteCryptocurrencies = cryptos
                    case .failure(let error):
                        self.errorMessage = ErrorMessage(message: "Error al cargar favoritos: \(error.localizedDescription)")
                    }
                }
            }
        } catch {
            errorMessage = ErrorMessage(message: "Error al cargar favoritos: \(error.localizedDescription)")
        }
    }
    // cargar favoritos al Abrir la Vista
    func refreshFavorites(from cryptocurrencies: [Cryptocurrency], modelContext: ModelContext) {
        let fetchDescriptor = FetchDescriptor<CryptoFavorite>()
        do {
            // Obtener los IDs de favoritos desde SwiftData
            let favoriteIDs = try modelContext.fetch(fetchDescriptor).map { $0.id }
            
            // Filtrar las criptomonedas existentes en el array global `cryptocurrencies`
            let updatedFavorites = cryptocurrencies.filter { favoriteIDs.contains($0.id) }
            DispatchQueue.main.async {
                self.favoriteCryptocurrencies = updatedFavorites
            }
        } catch {
            errorMessage = ErrorMessage(message: "Error al cargar favoritos: \(error.localizedDescription)")
        }
    }

    // verificar si es Favorito
    func isFavorite(_ id: String) -> Bool {
        favoriteCryptocurrencies.contains { $0.id == id }
    }


    func removeFavorite(for crypto: Cryptocurrency, modelContext: ModelContext) {
        let fetchDescriptor = FetchDescriptor<CryptoFavorite>(predicate: #Predicate { $0.id == crypto.id })
        do {
            if let existingFavorite = try modelContext.fetch(fetchDescriptor).first {
                modelContext.delete(existingFavorite)
                try modelContext.save()
                favoriteCryptocurrencies.removeAll { $0.id == crypto.id }
                print("Eliminado de favoritos: \(crypto.name)")
            }
        } catch {
            errorMessage = ErrorMessage(message: "Error al eliminar de favoritos: \(error.localizedDescription)")
        }
    }


    func addFavorite(for crypto: Cryptocurrency, modelContext: ModelContext) {
        let newFavorite = CryptoFavorite(id: crypto.id)
        modelContext.insert(newFavorite)
        do {
            try modelContext.save()
            if !favoriteCryptocurrencies.contains(where: { $0.id == crypto.id }) {
                favoriteCryptocurrencies.append(crypto)
            }
            print("Añadido a favoritos: \(crypto.name)")
        } catch {
            errorMessage = ErrorMessage(message: "Error al añadir a favoritos: \(error.localizedDescription)")
        }
    }
}
